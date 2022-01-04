import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:unite/Login.dart';
import 'package:unite/PostScreen.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/Search.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:firebase_analytics/firebase_analytics.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/post_page.dart';
import 'Walkthrough.dart';
import 'utils/post.dart';

import 'Greeting.dart';
import 'Settings.dart';

class NotificationCard{
  String message = '';
  String date = '';
  String url = '';

  NotificationCard({required this.message, required this.date, required this.url});
}

class Notifications extends StatefulWidget {
  const Notifications({Key? key}) : super(key: key);

  @override
  State<Notifications> createState() => _Notifications();

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);
}

class _Notifications extends State<Notifications> {

  List<NotificationCard> notifications = [];

  Future<bool> getNotifications() async {

    final _user = FirebaseAuth.instance.currentUser;

    QuerySnapshot snapshot =  await FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('notifications').orderBy('datetime').get();

    for(var not in snapshot.docs){

      Timestamp t = not.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);

      NotificationCard notify = NotificationCard(message: not.get('message').toString(), date: date, url: not.get('url').toString());
      notifications.add(notify);
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightBlueAccent,
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getNotifications(),
        builder: (context, snapshot){
          if(!snapshot.hasData) return CircularProgressIndicator();
          else{
            print('SNAPSHOT: ');
            print(notifications[0].message);
            return ListView.builder(
                reverse: true,
                itemCount: notifications.length,
                itemBuilder: (context, index){
                  return Card(
                    color: Colors.lightBlueAccent,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          notifications[index].url != "" ?
                          Image.network(notifications[index].url, height: 80, width: 80, fit: BoxFit.cover) :
                          Text(''),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(notifications[index].message, style: TextStyle(fontSize: 22),),
                              SizedBox(height: 5,),
                              Text(notifications[index].date, style: TextStyle(fontSize: 15),),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          }
        },
      )
    );
  }
}
