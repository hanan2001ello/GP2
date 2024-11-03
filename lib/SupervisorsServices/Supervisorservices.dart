import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(FirstScreenSu());}

class FirstScreenSu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: _FirstScreenSu(),
    );
  }
}

class _FirstScreenSu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Center(
            child: Text(
              'Supervisor services',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w500,
                color: Color(0xFF339199),
              ),
            )),
      ),
      body: Padding(
        padding: const EdgeInsets.all(34.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              Row(children: [
                DashboardOption(
                  icon: Icons.search,
                  label: 'Search for Student',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchScreen()),
                    );
                  },
                  width: 180.0,
                  height: 180.0,
                ),
                SizedBox(width: 20,),
                DashboardOption(
                  icon: Icons.list_alt,
                  label: 'View Daily Attendance',
                  onTap: () {
                    //View Daily Attendance
                  },
                  width: 180.0,
                  height: 180.0,
                ),
              ]),
              SizedBox(height: 20,),
              Row(children: [
                DashboardOption(
                  icon: Icons.vpn_key,
                  label: 'Room Key Management',
                  onTap: () {
                    //Room Key Management
                  },
                  width: 180.0,
                  height: 180.0,
                ),
                SizedBox(width: 20,),
                DashboardOption(
                  icon: Icons.description,
                  label: 'Permission Request',
                  onTap: () {
                    //Permission Request
                  },
                  width: 180.0,
                  height: 180.0,
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double width; // Add width property
  final double height; // Add height property

  const DashboardOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.width = 150.0, // Default width
    this.height = 100.0, // Default height
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width, // Set the width
        height: height, // Set the height
        decoration: BoxDecoration(
          color: Color(0xFF339199),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          children: [
            SizedBox(height: 10,),
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF007580),
              ),
              child: Icon(
                icon,
                size: 48.0,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10,),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22.0,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _searchController = TextEditingController();
  void _performSearch() {
    String searchTerm = _searchController.text;
    print("Searching for: $searchTerm");

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Search for Student",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Color(0xFF339199),
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Color(0xFF339199)),
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    _performSearch();
                  },
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF339199), width: 2.0),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            SizedBox(height: 40),
            Container(
              height: 70,
              width: 380,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BuildingsScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF339199),
                ),
                child: Text(
                  "By building location",
                  style: TextStyle(fontSize: 30, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BuildingsScreen extends StatelessWidget {
  final CollectionReference buildingCollection =
  FirebaseFirestore.instance.collection("Buildings");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            " Buildings",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w500,
              color: Color(0xFF339199),
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: StreamBuilder<QuerySnapshot>(
          stream: buildingCollection.snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (streamSnapshot.hasError) {
              return Center(child: Text('Error: ${streamSnapshot.error}'));
            } else if (!streamSnapshot.hasData ||
                streamSnapshot.data!.docs.isEmpty) {
              return Center(child: Text('No buildings found.'));
            } else {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  final buildingName = documentSnapshot.id;

                  return Card(
                    color: Color(0xFFF1F0F0),
                    margin: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                    child: ListTile(
                      title: Text(
                        buildingName,
                        style:
                        TextStyle(fontSize: 25, color: Color(0xFF339199)),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          size: 30,
                          Icons.arrow_forward,
                          color: Color(0xFF006064),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FloorsScreen(
                                    buildingId: documentSnapshot.id),
                              ));
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class FloorsScreen extends StatelessWidget {
  final String buildingId; // ID of the selected building

  FloorsScreen({required this.buildingId});

  @override
  Widget build(BuildContext context) {
    final CollectionReference floorsCollection = FirebaseFirestore.instance
        .collection("Buildings")
        .doc(buildingId)
        .collection("Floors");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Center(
          child: Text(
            "Floors",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w500,
              color: Color(0xFF339199),
            ),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40),
        child: StreamBuilder<QuerySnapshot>(
          stream: floorsCollection.snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (streamSnapshot.hasError) {
              return Center(child: Text('Error: ${streamSnapshot.error}'));
            } else if (!streamSnapshot.hasData ||
                streamSnapshot.data!.docs.isEmpty) {
              return Center(child: Text('No floors found.'));
            } else {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  final floorName = documentSnapshot.id;

                  return Card(
                    color: Color(0xFFF1F0F0),
                    margin: EdgeInsets.symmetric(vertical: 7, horizontal: 15),
                    child: ListTile(
                      title: Text(
                        floorName,
                        style:
                        TextStyle(fontSize: 25, color: Color(0xFF339199)),
                      ),
                      trailing: IconButton(
                        icon: Icon(
                          size: 30,
                          Icons.arrow_forward,
                          color: Color(0xFF006064),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomsScreen(
                                buildingId: buildingId, // Pass the building ID
                                floorId:
                                documentSnapshot.id, // Pass the floor ID
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class RoomsScreen extends StatelessWidget {
  final String buildingId; // ID of the selected building
  final String floorId; // ID of the selected floor

  RoomsScreen({required this.buildingId, required this.floorId});

  @override
  Widget build(BuildContext context) {
    final CollectionReference roomsCollection = FirebaseFirestore.instance
        .collection("Buildings")
        .doc(buildingId)
        .collection("Floors")
        .doc(floorId)
        .collection("Rooms");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Rooms",
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
            color: Color(0xFF339199),
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: StreamBuilder<QuerySnapshot>(
          stream: roomsCollection.snapshots(),
          builder: (context, streamSnapshot) {
            if (streamSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (streamSnapshot.hasError) {
              return Center(child: Text('Error: ${streamSnapshot.error}'));
            } else if (!streamSnapshot.hasData ||
                streamSnapshot.data!.docs.isEmpty) {
              return Center(child: Text('No rooms found.'));
            } else {
              return ListView.builder(
                itemCount: streamSnapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final DocumentSnapshot documentSnapshot =
                  streamSnapshot.data!.docs[index];
                  final roomName = documentSnapshot.id;
                  return Card(
                    color: Color(0xFFF1F0F0),
                    margin: EdgeInsets.symmetric(vertical: 7),
                    child: ListTile(
                      title: Text(
                        roomName,
                        style:
                        TextStyle(fontSize: 25, color: Color(0xFF339199)),),
                      trailing: IconButton(
                        icon: Icon(
                          size: 30,
                          Icons.arrow_forward,
                          color: Color(0xFF006064),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoomDetailsScreen(
                                buildingId: buildingId,
                                floorId: floorId,
                                roomId: roomName, // Use the room name as the ID
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
class RoomDetailsScreen extends StatefulWidget {
  final String buildingId; // ID of the building
  final String floorId;   // ID of the floor
  final String roomId;    // ID of the room

  RoomDetailsScreen({
    required this.buildingId,
    required this.floorId,
    required this.roomId,
  });

  @override
  _RoomDetailsScreenState createState() => _RoomDetailsScreenState();
}

class _RoomDetailsScreenState extends State<RoomDetailsScreen> {

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.roomId}"),
        backgroundColor: Colors.white,
        titleTextStyle: TextStyle(
          color: Color(0xFF339199),
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: 40),
            Text(
              "STUDENT NAME",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF339199)),
            ),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}