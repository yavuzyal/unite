import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:unite/ChatPage.dart';
import 'package:unite/SearchedProfile.dart';
import 'package:unite/utils/dimensions.dart';
import 'usables/config.dart' as globals;
import 'package:unite/utils/colors.dart';
import 'package:unite/utils/styles.dart';


//EDIT PROFILE ICINDEN USERNAME VE PP UPDATE ETMEYI UNUTMA!!!!!!
//SEARCHPROFILE ICINDEN MESSAGE KISMINA CHATPAGE ATAN KODU EKLE
//MESSAGE ATINCA NOTIF GITSIN
//MESSAGE PRIV PROFILDE GITMESIN

class ChatMain extends StatefulWidget {
  @override
  _ChatMain createState() => _ChatMain();
}

class _ChatMain extends State<ChatMain> {
  String name = "";
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: globals.light ? Colors.white: Colors.grey[700],
        body: Column(
          children: [
            //SizedBox(height: 20,),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').snapshots(),
              builder:
                  (BuildContext context, snapshot) {
                if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return Center(child: CircularProgressIndicator(),);
                  default:

                    print(snapshot.data!.docs.cast());

                    return ListView(
                      padding: AppDimensions.padding20,
                      shrinkWrap: true,
                      children:
                      snapshot.data!.docs.map((DocumentSnapshot document) {
                        return  ListTile(
                          leading: document['profile_pic'] == '' ?
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            child: CircleAvatar(
                              radius: 25,
                              child: Image.asset('assets/usericon.png'),
                            ),
                          ) :
                          ClipRRect(
                            borderRadius: BorderRadius.all(Radius.circular(40)),
                            child: CircleAvatar(
                              radius: 25,
                              child: Image.network(document['profile_pic']),
                            ),
                          ),
                          onTap: (){
                            //print(document['userId']);
                            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                ChatPage(userId: document.id)),);
                          },
                          title: Text(document['userName'], style: globals.light ? AppStyles.profileText : AppStyles.postText),
                        );
                      }).toList(),
                    );
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