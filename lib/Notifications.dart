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
import 'package:unite/SearchedProfile.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:unite/utils/colors.dart';
import 'profile.dart';
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
  String uid = '';
  String followReq  = '';

  String notificationId = '';

  NotificationCard({required this.message, required this.date, required this.url, required this.uid, required this.notificationId, required this.followReq});
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
  final _user = FirebaseAuth.instance.currentUser;
  bool answered = false;

  Future<bool> getNotifications() async {

    notifications = [];

    final _user = FirebaseAuth.instance.currentUser;

    QuerySnapshot snapshot =  await FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('notifications').orderBy('datetime').get();

    for(var not in snapshot.docs){

      Timestamp t = not.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);

      NotificationCard notify = NotificationCard(message: not.get('message').toString(), date: date, url: not.get('url').toString(), uid: not.get('uid'), notificationId: not.id, followReq: not.get('follow_request'));
      notifications.add(notify);
    }

    notifications = notifications.reversed.toList();

    return true;
  }

  Future accept(uid, notifId) async {
    DocumentSnapshot followList = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    List followRequests = [];
    followRequests = followList.get('follow_requests');

    List followers = [];
    followers = followList.get('followers');

    int followerCount = followList.get('followerCount');

    followRequests.remove(uid);
    followers.add(uid);

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
      'follow_requests': followRequests,
      'followers' : followers,
      'followerCount': followerCount+1,
    });

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('notifications').doc(notifId).update({
      'follow_request': 'accepted',
    });

    DocumentSnapshot followList2 = await FirebaseFirestore.instance.collection('users').doc(uid).get();

    List following2 = followList2.get('following');

    int followingCount2 = followList2.get('followingCount');

    following2.add(_user!.uid);

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'following' : following2,
      'followingCount': followingCount2+1,
    });

    setState(() {
      answered = true;
    });

  }

  Future reject(uid, notifId) async {
    DocumentSnapshot followList = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    List followRequests = [];
    followRequests = followList.get('follow_requests');

    followRequests.remove(uid);

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
      'follow_requests': followRequests,
    });

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('notifications').doc(notifId).update({
      'follow_request': 'rejected',
    });

    setState(() {
      answered = true;
    });

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: globals.light ? Colors.white: Colors.grey[700],
        appBar: AppBar(
          backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
        title: Text('Notifications'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: getNotifications(),
        builder: (context, snapshot){
          if(!snapshot.hasData) return CircularProgressIndicator();
          else{
            return ListView.builder(
                reverse: false,
                itemCount: notifications.length,
                itemBuilder: (context, index){
                  return Card(
                    color: globals.light ? AppColors.postBackgroundColor : darkAppColors.postBackgroundColor,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          notifications[index].url != '' ?
                          IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) =>
                              SearchedProfile(userId: notifications[index].uid)),), icon: Image.network(notifications[index].url, width: 80, fit: BoxFit.fill,), iconSize: 100,) :
                          SizedBox.shrink(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Container(
                                  width: notifications[index].url != '' ? MediaQuery.of(context).size.width*0.4 : MediaQuery.of(context).size.width*0.8,
                                  child: Text(notifications[index].message, style: TextStyle(fontSize: 22, color: globals.light ? AppColors.postTextColor : darkAppColors.postTextColor),)),
                              SizedBox(height: 5,),
                              Text(notifications[index].date, style: TextStyle(fontSize: 15, color: globals.light ? AppColors.postTextColor : darkAppColors.postTextColor),),
                              notifications[index].followReq == 'yes' ? Row(
                                children: [
                                  SizedBox(height: 5,),
                                  ElevatedButton(
                                      onPressed: () async {
                                        accept(notifications[index].uid, notifications[index].notificationId);
                                      },
                                    child: Text('Accept', style: TextStyle(fontSize: 20, color: globals.light ? AppColors.postTextColor : darkAppColors.postTextColor),),
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(10),
                                      backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                    ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      reject(notifications[index].uid, notifications[index].notificationId);
                                    },
                                    child: Text('Reject', style: TextStyle(fontSize: 20, color: globals.light ? AppColors.postTextColor : darkAppColors.postTextColor),),
                                    style: ButtonStyle(
                                      elevation: MaterialStateProperty.all(10),
                                      backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                    ),
                                  ),
                                  SizedBox(height: 5,),
                                ],
                              ) : SizedBox.shrink(),
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
