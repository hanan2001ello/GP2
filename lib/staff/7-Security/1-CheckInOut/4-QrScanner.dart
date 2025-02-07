import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pnustudenthousing/helpers/Design.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QrScanner extends StatefulWidget {
  final DocumentReference? sturef;
  final String checkStatus;

  const QrScanner({super.key, required this.sturef, required this.checkStatus});

  @override
  State<StatefulWidget> createState() => _QrScannerState();
}

class _QrScannerState extends State<QrScanner> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OurAppBar(
        title: 'Scan',
      ),
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: Qr(context)),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  // if (result != null)
                  //   Text(
                  //       'Barcode Type: ${describeEnum(result!.format)}   Data: ${result!.code}')
                  // else
                  //   const Text('Scan a code'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                          margin: const EdgeInsets.all(8),
                          child: Dactionbutton(
                            text: 'pause',
                            background: dark1,
                            onPressed: () async {
                              await controller?.pauseCamera();
                            },
                          )),
                      Container(
                        margin: const EdgeInsets.all(8),
                        child: Dactionbutton(
                          text: 'resume',
                          background: dark1,
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  bool hasScanned = false;
  Widget Qr(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 300.0
        : 600.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: onScanned,
      overlay: QrScannerOverlayShape(
          borderColor: hasScanned ? green1 : red1,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => onPermissionSet(context, ctrl, p),
    );
  }

  void onScanned(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        hasScanned = true;
        result = scanData;
      });

      // Pause the camera
      controller.pauseCamera();

      try {
        // Extract the unique field value (assuming `scanData.code` has the value)
        String uniqueValue = scanData.code ?? "";

        // Query Firestore to find the document with the unique field value
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('student')
            .where('PNUID', isEqualTo: uniqueValue)
            .get();
        String currentStatus = '';
        String Status = '';
        bool isresident = false;
        if (querySnapshot.docs.isNotEmpty) {
          // Assuming there's only one document with the unique field value
          DocumentReference docRef = querySnapshot.docs.first.reference;
          DocumentSnapshot docSnapshot = await docRef.get();
          currentStatus = docSnapshot['checkStatus'];
          isresident = docSnapshot['resident'];
          bool updated = false;
          if (isresident) {
            if (widget.checkStatus == 'First Check-in') {
              await docRef.update({
                'checkStatus': 'Checked-in',
                'resident': true,
                'checkTime': FieldValue.serverTimestamp()
              });
              //
              Status = 'Checked-in for the first time';
              updated = true;
            } else if (widget.checkStatus == 'Last Check-out') {
              await docRef.update({
                'checkStatus': 'Checked-out',
                'resident': false,
                'checkTime': FieldValue.serverTimestamp()
              });
              //
              Status = 'Checked-out and not resident any more';
              updated = true;
            } else if (widget.checkStatus == 'Checked-in') {
              if (currentStatus == widget.checkStatus) {
                ErrorDialog("Student is already $currentStatus", context, buttons: [
                  {
                    "Ok": () {
                      context.pop();
                    }
                  }
                ]);
              } else {
                await docRef.update({
                  'checkStatus': 'Checked-in',
                  'checkTime': FieldValue.serverTimestamp()
                });
                //
                Status = 'Checked-in';
                updated = true;
              }
            } else if (widget.checkStatus == 'Checked-out') {
              if (currentStatus == widget.checkStatus) {
                ErrorDialog("Student is already $currentStatus", context, buttons: [
                  {
                    "Ok": () {
                      context.pop();
                    }
                  }
                ]);
              } else {
                await docRef.update({
                  'checkStatus': 'Checked-out',
                  'checkTime': FieldValue.serverTimestamp()
                });
                //
                Status = 'Checked-out';
                updated = true;
              }
            }
          } else {
            ErrorDialog("Student is not resident", context, buttons: [
              {
                "Ok": () {
                  context.pop();
                }
              }
            ]);
          }
          if (updated) {
            // Show a confirmation dialog
            InfoDialog("The Student $uniqueValue now is $Status ", context,
                buttons: [
                  {
                    "Ok": () {
                      context.pop();
                      context.goNamed('/checkinout');
                    }
                  }
                ]);
          }
        } else {
          ErrorDialog("No student found for this Barcode ", context, buttons: [
            {
              "Ok": () {
                context.pop();
              }
            }
          ]);
        }
      } catch (e) {
        // Handle errors
        ErrorDialog("Error in updating student status", context, buttons: [
          {
            "Ok": () {
              context.pop();
            }
          }
        ]);
      }
    });
  }

  void onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}

class QrData {
  late DocumentReference? sturef;
  late String Ceckstatus;
  QrData({
    required this.sturef,
    required this.Ceckstatus,
  });
}
