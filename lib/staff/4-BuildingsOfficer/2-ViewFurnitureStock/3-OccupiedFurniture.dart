import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pnustudenthousing/helpers/Design.dart';


class OccupiedFurniture extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: OurAppBar(
        title: 'Occupied Furniture',
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('furnitureStock').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: OurLoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Extract furniture details from Firestore documents
          final List<Map<String, dynamic>> remainingFurniture = snapshot.data!.docs.map((doc) {
            return {
              'furnitureName': doc['furnitureName'] as String,
              'occupiedQuantity': doc['occupiedQuantity'] as int,
            };
          }).toList();

          return OurListView(
            data: remainingFurniture,
            leadingWidget: (item) => text(t:'0${remainingFurniture.indexOf(item) + 1}',color: dark1 , align: TextAlign.start,),// Index number in a circle
            trailingWidget: (item) => CircleAvatar( backgroundColor: dark1,
            child:text(t:'${item['occupiedQuantity']}', color: Colors.white , align: TextAlign.start,),),
            title: (item)=>item['furnitureName'],
          );
        },
      ),
    );
  }
}
