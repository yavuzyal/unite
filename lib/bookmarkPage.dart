import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'valueListenables.dart';
import 'package:unite/SearchedProfile.dart';
import 'usables/config.dart' as globals;
import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/post_page.dart';
import 'package:unite/utils/post_tile_feed.dart';
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

class bookmarkPage extends StatefulWidget {
  const bookmarkPage({Key? key}) : super(key: key);

  @override
  State<bookmarkPage> createState() => _bookmarkPage();

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);
}

class _bookmarkPage extends State<bookmarkPage> {

  final _user = FirebaseAuth.instance.currentUser;
  List<Post> bookmarks = [];

  Future getBookmarks() async {

    bookmarks = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('bookmarks').get();

    for(var message in snapshot.docs){

      String id = message.id;
      String owner = message.get('owner');

      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(owner).collection('posts').doc(id).get();

      int likeCount = snapshot.get('likeCount');

      List comment = snapshot.get('comment');
      String date = snapshot.get('datetime').toDate().toString().substring(0,10);

      Post post = Post(text: snapshot.get('caption').toString(), image_url: snapshot.get('image_url').toString() , date: date, likeCount: likeCount, commentCount: comment.length, comments: comment, postId: id, owner: owner);
      bookmarks.add(post);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: globals.light ? Colors.white: Colors.grey[700],
        appBar: AppBar(
          backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
          title: Text('Bookmarked posts'),
          centerTitle: true,
        ),
        body: ValueListenableBuilder(
          valueListenable: valueListenables.bookmarkedPost,
          builder: (context, bookmarkedPost, snapshot) {
            return FutureBuilder(
                future: Future.wait([getBookmarks()]),
                builder: (context, snapshot) {
                  bookmarks.sort(
                          (a, b) {
                        DateTime dt1 = DateTime.parse(a.date);
                        DateTime dt2 = DateTime.parse(b.date);
                        return dt2.compareTo(dt1);
                      }
                  );
                  return Container(
                    child: SingleChildScrollView(
                      child: Center(child: Container(
                        child: Column(
                          children: bookmarks.map(
                                  (post) =>
                                  PostTileFeed(
                                    //userId: _user!.uid,
                                      post: post,
                                      delete: () {
                                        setState(() async {
                                          //myPosts.remove(post);
                                          await FirebaseFirestore.instance
                                              .collection(
                                              'users').doc(_user!.uid)
                                              .collection('posts')
                                              .doc(post.postId)
                                              .delete();
                                        });
                                      },
                                      like: () {},
                                      searched: false)
                          ).toList(),
                        ),
                      ),
                      ),
                    ),
                  );
                }
            );
          },
        )
    );
  }
}
