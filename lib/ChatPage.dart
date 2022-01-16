import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:unite/utils/dimensions.dart';

class ChatPage extends StatefulWidget {

  String userId;

  ChatPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPage();
}

class _ChatPage extends State<ChatPage> {

  final _user = FirebaseAuth.instance.currentUser;
  String message = '';
  final _formKey = GlobalKey<FormState>();

  Future sendMessages(String message) async {

    List messagedBefore = [];

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(widget.userId).collection('messages').add({
      'message': message,
      'userId': widget.userId,
      'from': _user!.uid,
      'to': widget.userId,
      'datetime': DateTime.now(),
    });
    await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('messages').doc(_user!.uid).collection('messages').add({
      'message': message,
      'userId': widget.userId,
      'from': _user!.uid,
      'to': widget.userId,
      'datetime': DateTime.now(),
    });
    QuerySnapshot messaged = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messagedBefore').get();

    if(!messaged.docs.contains(widget.userId)){
      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messagedBefore').doc(widget.userId);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('USERNAME'),
      ),
        body: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(widget.userId).collection('messages').orderBy('datetime', descending: false).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return new Text('Loading...');
                  default:
                    return SingleChildScrollView(
                      child: ListView(
                        padding: AppDimensions.padding8,
                        shrinkWrap: true,
                        children:
                        snapshot.data!.docs.map((DocumentSnapshot document) {
                          return ListTile(
                            title: document['from'] == widget.userId ?
                            Container(
                              padding: AppDimensions.padding20,
                              decoration: BoxDecoration(
                                color: Colors.pinkAccent,
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(40.0),
                                    bottomRight: Radius.circular(40.0),
                                    topLeft: Radius.circular(40.0),
                                    bottomLeft: Radius.circular(0.0)),
                              ),
                              child: Text(document['message'], style: TextStyle(color: Colors.white, fontSize: 16),),
                            ) :
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(''),Container(
                                padding: AppDimensions.padding20,
                            decoration: BoxDecoration(
                              color: Colors.lightBlue,
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(40.0),
                                  bottomRight: Radius.circular(0.0),
                                  topLeft: Radius.circular(40.0),
                                  bottomLeft: Radius.circular(40.0)),
                            ),
                            child: Text(document['message'],style: TextStyle(color: Colors.white, fontSize: 16),),
                              ),
                            ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                }
              },
            ),
            Form(
              key: _formKey,
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Add a message...",
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(0.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                            message = value!;
                        },
                      ),
                    ),
                    FloatingActionButton(
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            sendMessages(message!);
                          }
                        },
                        child: Text('Send'))
                  ],
                ),
            ),
          ],
        )
    );
  }

}