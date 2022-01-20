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
  var _controller = TextEditingController();
  var _scrollController = ScrollController();
  
  Future sendMessages(String message) async {

    List messagedBefore = [];

    final newId = widget.userId;

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(newId).set({});

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(newId).collection('messages').add({
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

    //Ben mesaj yollarken karsi kendi kismima eklenecek info
    DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();
    String name = snap.get('username');
    String pp = snap.get('profile_pic');

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(newId).set({
      'userName': name,
      'profile_pic': pp,
    });

    //Ben mesaj atinca karsiya da bir info eklenmeli

    await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('messages').doc(_user!.uid).set({});

    DocumentSnapshot snap2 = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    String name2 = snap2.get('username');
    String pp2 = snap2.get('profile_pic');

    await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('messages').doc(_user!.uid).set({
      'userName': name2,
      'profile_pic': pp2,
    });

  }

  Future<String> name_pp() async {
    DocumentSnapshot user = await FirebaseFirestore.instance.collection('users').doc(widget.userId).get();

    String name = user.get('username');
    print(name);

    return name;

  }

  @override
  Widget build(BuildContext context) {
    
    return FutureBuilder(
      future: name_pp(),
      builder: (context, snapshot){
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(snapshot.data.toString()),
          ),
          body: Padding(
            padding: AppDimensions.padding8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').doc(widget.userId).collection('messages').orderBy('datetime', descending: false).snapshots(),
                      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                        switch (snapshot.connectionState) {
                          case ConnectionState.waiting:
                            return Center(child: CircularProgressIndicator(),);
                          default:
                            //return SingleChildScrollView(
                              return ListView(
                                controller: _scrollController,
                                reverse: false,
                                scrollDirection: Axis.vertical,
                                padding: AppDimensions.padding8,
                                shrinkWrap: true,
                                clipBehavior: Clip.antiAlias,
                                children: snapshot.data!.docs.map((DocumentSnapshot document) {
                                  return ListTile(
                                    title: document['from'] == widget.userId ?
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Flexible(
                                                child: Container(
                                                  padding: AppDimensions.padding20,
                                                  decoration: BoxDecoration(
                                                    color: Colors.pinkAccent,
                                                    borderRadius: BorderRadius.only(
                                                        topRight: Radius.circular(40.0),
                                                        bottomRight: Radius.circular(40.0),
                                                        topLeft: Radius.circular(40.0),
                                                        bottomLeft: Radius.circular(0.0)
                                                    ),
                                                  ),
                                                  child: Text(document['message'], style: TextStyle(color: Colors.white, fontSize: 16),overflow: TextOverflow.clip,),
                                                ),
                                            ),
                                            Text(''),
                                          ],
                                        )
                                     :
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text(''),
                                      Flexible(
                                          child: Container(
                                            padding: AppDimensions.padding20,
                                            decoration: BoxDecoration(
                                              color: Colors.lightBlue,
                                              borderRadius: BorderRadius.only(
                                                  topRight: Radius.circular(40.0),
                                                  bottomRight: Radius.circular(0.0),
                                                  topLeft: Radius.circular(40.0),
                                                  bottomLeft: Radius.circular(40.0)
                                              ),
                                            ),
                                            child: Text(document['message'],style: TextStyle(color: Colors.white, fontSize: 16), overflow: TextOverflow.clip,),
                                          ),),
                                    ],
                                    ),
                                  );
                                }).toList(),
                                physics: BouncingScrollPhysics(),
                              );
                            //);
                        }
                      },
                    ),
                ),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
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
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        color: Colors.blue,
                        iconSize: 35,
                        onPressed: () async {
                          if(_formKey.currentState!.validate()){
                            sendMessages(message!).then((value) => _scrollController.jumpTo(_scrollController.position.maxScrollExtent+100.0));
                            print(_scrollController.position.maxScrollExtent.runtimeType);
                            _controller.clear();
                          }
                        },
                        //child: Text('Send')
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

}