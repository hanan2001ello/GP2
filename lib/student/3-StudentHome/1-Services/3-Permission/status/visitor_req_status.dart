import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:pnustudenthousing/helpers/Design.dart';
import 'package:timeline_tile/timeline_tile.dart';

class VisitorReqStatus extends StatefulWidget {
  const VisitorReqStatus({super.key});

  @override
  State<VisitorReqStatus> createState() => _VisitorReqStatusState();
}

class _VisitorReqStatusState extends State<VisitorReqStatus> {
  String? fieldValue;

  @override
  void initState() {
    super.initState();
    fetchReferencedDocValue();
  }

  void fetchReferencedDocValue() async {
    try {
      // Step 1: Get the current user's UID
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        print("No user is signed in");
        return;
      }

      String userUid = currentUser.uid;

      // Step 2: Get the user's document (assuming it's stored in a 'users' collection)
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('student').doc(userUid);

      // Fetch the user's document
      DocumentSnapshot userSnapshot = await userDocRef.get();

      if (userSnapshot.exists) {
        // Step 3: Get the document reference from a specific field (e.g., 'linkedDocRef')
        DocumentReference? linkedDocRef = userSnapshot.get('VisitorRequest');

        // Step 4: Fetch the referenced document
        if (linkedDocRef != null) {
          DocumentSnapshot linkedSnapshot = await linkedDocRef.get();

          if (linkedSnapshot.exists) {
            // Step 5: Access a specific field in the referenced document (e.g., 'someField')
            fieldValue = linkedSnapshot.get('status');
            setState(() {});

            // Update the UI
            print('Value from referenced document: $fieldValue');
          } else {
            ErrorDialog(
              'Referenced document does not exist',
              context,
              buttons: [
                {
                  "Ok": () => context.pop(),
                },
              ],
            );
          }
        } else {
          ErrorDialog(
            "Field 'linkedDocRef' is null or does not exist in the user document",
            context,
            buttons: [
              {
                "Ok": () => context.pop(),
              },
            ],
          );
        }
      } else {
        ErrorDialog(
          'User document does not exist',
          context,
          buttons: [
            {
              "Ok": () => context.pop(),
            },
          ],
        );
      }
    } catch (e) {
      ErrorDialog(
        'Error',
        context,
        buttons: [
          {
            "Ok": () => context.pop(),
          },
        ],
      );
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OurAppBar(
        title: "View Requests",
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 50),
        child: OurStatusContainer(
          requestStatus: TextCapitalizer.CtextS(fieldValue.toString()),
          labels: [
            'Awaiting',
            'Pending',
            'Accept',
          ],
          title: "Visitor status request",
          // StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          //   stream: FirebaseFirestore.instance
          //       .collection('VisitorRequest')
          //       .doc(currentUserId)
          //       .snapshots(),
          //   builder: (context, snapshot) {
          //     if (snapshot.hasError) {
          //       return Text('Error: ${snapshot.error}');
          //     }
          //
          //     if (!snapshot.hasData) {
          //       return Center(child: CircularProgressIndicator());
          //     }
          //
          //     final data = snapshot.data!.data();
          //     final String status = data?['status'] ??
          //         'pending'; // Handle potential null value with default 'Pending'
          //
          //     return ListView(
          //       children: [
          //         Center(
          //           child: Padding(
          //             padding: const EdgeInsets.all(20),
          //             child: Dtext(
          //               t: "Visitor status request",
          //               color: green1,
          //               align: TextAlign.center,
          //               size: 0.06,
          //             ),
          //           ),
          //         ),
          //         VisitorTrack(
          //           isLast: false,
          //           isFirst: true,
          //           isPast: true,
          //           eventCard: Dtext(
          //             t: "Waiting",
          //             size: 0.05,
          //             align: TextAlign.center,
          //             color: Colors.white,
          //           ),
          //         ),
          //         VisitorTrack(
          //           isLast: false,
          //           isFirst: false,
          //           isPast: true,
          //           eventCard: Dtext(
          //             t: "Proccessing request",
          //             align: TextAlign.center,
          //             size: 0.05,
          //             color: Colors.white,
          //           ),
          //         ),
          //         VisitorTrack(
          //           isLast: true,
          //           isFirst: false,
          //           isPast: status != 'pending', // Set isPast based on status
          //           eventCard: Dtext(
          //             t: status == 'accepted'
          //                 ? 'Approved'
          //                 : status == 'rejected'
          //                     ? 'Rejected'
          //                     : 'Pending', // Display appropriate text based on status
          //             color: Colors.white,
          //             size: 0.05,
          //             align: TextAlign.center,
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // ),
        ),
      ),
    );
  }
}
