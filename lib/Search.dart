import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:unite/SearchedProfile.dart';
import 'package:unite/utils/dimensions.dart';

class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}

class _Search extends State<Search> {
  String name = "";


  Future<void> getData() async {

    final _fireStore = FirebaseFirestore.instance;
    // Get docs from collection reference
    QuerySnapshot querySnapshot = await _fireStore.collection('users').get();;

    // Get data from docs and convert map to List
    final allData = querySnapshot.docs.map((doc) => doc.data()).toList();
    //for a specific field
    //final allData = querySnapshot.docs.map((doc) => doc.get('fieldName')).toList();

    print(allData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
          children: [
            Padding(
              padding: AppDimensions.padding20,
              child: TextField(
                enableSuggestions: true,
                onChanged: (val) => initiateSearch(val),
              ),
            ),
            //SizedBox(height: 20,),
            StreamBuilder<QuerySnapshot>(
              stream: name != "" && name != null
                  ?
              FirebaseFirestore.instance.collection('users').where("searchKey", arrayContains: name).snapshots()
                  : FirebaseFirestore.instance.collection('users').where("username", isNull: false).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return SingleChildScrollView(
                      child: ListView(
                      padding: AppDimensions.padding20,
                      shrinkWrap: true,
                      children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        return  ListTile(
                          leading: Icon(Icons.account_circle),
                          //trailing: Icon(Icons.arrow_forward),
                          //selectedTileColor: Colors.yellow,
                          horizontalTitleGap: 0,
                          onTap: (){
                            print(document['userId']);
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                SearchedProfile(userId: document['userId'])),);
                          },
                          title: name != "" && name != null ? new Text(document['username']) : Text(document['username']),
                        );
                      }).toList(),
                    ),);
                }
              },
            ),
          ],
        )
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
    });
  }
}

