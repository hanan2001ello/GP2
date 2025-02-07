import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pnustudenthousing/helpers/Design.dart';

class SuperVisitorReqList extends StatefulWidget {
  const SuperVisitorReqList({super.key});

  @override
  State<SuperVisitorReqList> createState() => _SuperVisitorReqListState();
}

class _SuperVisitorReqListState extends State<SuperVisitorReqList> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> visitorData = [];
  List<QueryDocumentSnapshot<Map<String, dynamic>>> overnightData = [];
  TextEditingController _searchController = TextEditingController();

  void _performSearch() {
    String searchTerm = _searchController.text;

    print("Searching for: $searchTerm");
  }

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<List<Map<String, dynamic>>> fetchRequests() async {
    print("Fetching visitor requests..."); // Print a message before fetching

    try {
      List<Map<String, dynamic>> requests = [];
      final snapshot = await _firestore
          .collection('VisitorRequest')
          .where('status', isEqualTo: 'pending')
          .get();
      visitorData = snapshot.docs;

      print(
          "Number of requests found: ${snapshot.docs.length}"); // Print number of requests
      for (var doc in snapshot.docs) {
        DocumentReference studentinfo = doc['studentInfo'];
        DocumentSnapshot studentSnapshot = await studentinfo.get();

        String firstName = studentSnapshot['firstName'] ?? 'N/A';
        String lastName = studentSnapshot['lastName'] ?? 'N/A';
        String status = doc['status'];

        print(
            "Processing request: ${doc.id}"); // Print ID of request being processed

        requests.add({
          'fullName': '$firstName $lastName',
          'requestId': doc.id,
          'status': status
        });
      }
      print("Successfully fetched requests!"); // Print success message

      return requests;
    } catch (e) {
      ErrorDialog(
        'Error fetching requests: $e',
        context,
        buttons: [
          {
            "Ok": () => context.pop(),
          },
        ],
      );
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: fetchRequests(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: OurLoadingIndicator());
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: OurAppBar(title: 'Overnight Requests'),
            body: Center(
                child: Text("An error occurred while fetching requests")),
          );
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Scaffold(
            appBar: OurAppBar(title: 'Overnight Requests'),
            body: Center(child: Text("No requests found")),
          );
        }
        List<Map<String, dynamic>> requests = snapshot.data!;

        return Scaffold(
          appBar: OurAppBar(title: 'Visitor Requests'),
          body: Column(
            children: [
             
              Expanded(
                child: OurListView(
                  data: requests, // changed from 'combinedData'
                  leadingWidget: (item) => text(
                    t: '0${requests.indexOf(item) + 1}', // changed from 'combinedData'
                    color: dark1,
                    align: TextAlign.start,
                  ),
                  trailingWidget: (item) => Dactionbutton(
                    height: 0.044,
                    width: 0.19,
                    text: 'View',
                    padding: 0,
                    background: dark1,
                    fontsize: 0.03,
                    onPressed: () {
                      context.pushNamed(
                        '/supervisitorview',
                        extra: visitorInfo(requestId: item['requestId']),
                      );
                    },
                  ),
                  title: (item) => item['fullName'],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class visitorInfo {
  //List<QueryDocumentSnapshot<Map<String, dynamic>>>
  String requestId;

  visitorInfo({
    required this.requestId,
  });
}
