import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:unite/LoggedIn.dart';
import 'package:unite/SearchedProfile.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'usables/config.dart' as globals;
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'utils/post_tile_feed.dart';
import 'utils/post.dart';

class Search extends StatefulWidget {
  @override
  _Search createState() => _Search();
}

class _Search extends State<Search> with TickerProviderStateMixin{
  String name = "";
  String loc = "";
  String cap = "";
  String tag = "";
  late TabController _tabController = new TabController(length: 4, vsync: this);

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

  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: globals.light ? Colors.white: Colors.grey[700],
        body: Column(
          children: [
            TabBar(
              isScrollable: true,
              unselectedLabelColor: globals.light ? AppColors.appTextColor :darkAppColors.appTextColor,
              unselectedLabelStyle: AppStyles.profileText,
              labelColor: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor,
              labelStyle: AppStyles.profileText,
              indicatorColor: globals.light ? AppColors.logoColor : darkAppColors.logoColor,
              indicatorWeight: 3,
              tabs: [
                Tab(
                  text: 'User',
                ),
                Tab(
                  text: 'Location',
                ),
                Tab(
                  text: 'Caption',
                ),
                Tab(
                  text: 'Tags',
                ),
              ],
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
            ),
            Expanded(
              child: TabBarView(
                children: [SingleChildScrollView(
                  child: Column(
                    children:
                    [Padding(padding: AppDimensions.padding20,
                    child: TextField(
                      style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                      enableSuggestions: true,
                      cursorColor: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor,
                      onChanged: (val) => initiateSearch(val),
                    ),
                  ),
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
                        return new Text('Loading...', style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,);
                      default:
                        return SingleChildScrollView(
                          child: ListView(
                          padding: AppDimensions.padding20,
                          shrinkWrap: true,
                          children:
                          snapshot.data!.docs.map((DocumentSnapshot document) {
                            return  ListTile(
                              leading: document['isPrivate'] == 'private' ?  Icon(Icons.lock, color: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor) : Icon(Icons.account_circle, color: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor),
                              //trailing: Icon(Icons.arrow_forward),
                              //selectedTileColor: Colors.yellow,
                              horizontalTitleGap: 0,
                              onTap: (){
                                //print(document['userId']);
                                document['userId'] != _user!.uid ?
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    SearchedProfile(userId: document['userId'])),) :
                                Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                    LoggedIn()));
                              },
                              title: name != "" && name != null ? new Text(document['username'], style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,) : Text(document['username'], style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,),
                            );
                          }).toList(),
                        ),);
                    }
                  },
              ),
                    ],
              ),
                ),
                  Column(
                    children:
                    [Padding(padding: AppDimensions.padding20,
                      child: TextField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        enableSuggestions: true,
                        cursorColor: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor,
                        onChanged: (val) => initiateSearch(val),
                      ),
                    ),
                      //SizedBox(height: 20,),
                      StreamBuilder<QuerySnapshot>(
                        stream: loc != "" && loc != null
                            ?
                        FirebaseFirestore.instance.collectionGroup('posts').where("location_array", arrayContains: loc).snapshots()
                            : FirebaseFirestore.instance.collectionGroup('posts').where("location_array", isNull: true).snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          print(snapshot.error);
                          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return new Text('Loading...', style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,);
                            default:
                              return Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                    snapshot.data!.docs.map((DocumentSnapshot document) {

                                      Post post = Post(text: document['caption'].toString(),
                                          image_url: document['image_url'].toString() ,
                                          date: document['datetime'].toDate().toString().substring(0,10),
                                          likeCount: document['likeCount'],
                                          commentCount: document['comment'].length,
                                          comments: document['comment'],
                                          postId: document.id,
                                          owner: document['owner']);

                                      return PostTileFeed(
                                        //userId: _user!.uid,
                                          post: post,
                                          delete: () {
                                            //myPosts.remove(post);
                                          },
                                          like: () {},
                                          searched: true);
                                    }
                                    ).toList(),
                                ),
                              ),
                                );
                          }
                        },
                      ),
                    ],
                  ),

                  Column(
                    children:
                    [Padding(padding: AppDimensions.padding20,
                      child: TextField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        enableSuggestions: true,
                        cursorColor: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor,
                        onChanged: (val) => initiateSearch(val),
                      ),
                    ),
                      //SizedBox(height: 20,),
                      StreamBuilder<QuerySnapshot>(
                        stream: cap != "" && cap != null
                            ?
                        FirebaseFirestore.instance.collectionGroup('posts').where("text_array", arrayContains: cap).snapshots()
                            : FirebaseFirestore.instance.collectionGroup('posts').where("text_array", isNull: true).snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          print(snapshot.error);
                          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return new Text('Loading...', style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,);
                            default:
                              return Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                    snapshot.data!.docs.map((DocumentSnapshot document) {

                                      print(document.id);

                                      Post post = Post(text: document['caption'].toString(),
                                          image_url: document['image_url'].toString() ,
                                          date: document['datetime'].toDate().toString().substring(0,10),
                                          likeCount: document['likeCount'],
                                          commentCount: document['comment'].length,
                                          comments: document['comment'],
                                          postId: document.id,
                                          owner: document['owner']);

                                      return PostTileFeed(
                                        //userId: _user!.uid,
                                          post: post,
                                          delete: () {
                                            //myPosts.remove(post);
                                          },
                                          like: () {},
                                          searched: true);
                                    }
                                    ).toList(),
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    ],
                  ),

                  Column(
                    children:
                    [Padding(padding: AppDimensions.padding20,
                      child: TextField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        enableSuggestions: true,
                        cursorColor: globals.light ? AppColors.appTextColor : darkAppColors.appTextColor,
                        onChanged: (val) => initiateSearch(val),
                      ),
                    ),
                      //SizedBox(height: 20,),
                      StreamBuilder<QuerySnapshot>(
                        stream: tag != "" && tag != null
                            ?
                        FirebaseFirestore.instance.collectionGroup('posts').where("tags", arrayContains: tag).snapshots()
                            : FirebaseFirestore.instance.collectionGroup('posts').where("tags", isNull: true).snapshots(),
                        builder:
                            (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          print(snapshot.error);
                          if (snapshot.hasError) return new Text('Error: ${snapshot.error}');
                          switch (snapshot.connectionState) {
                            case ConnectionState.waiting:
                              return new Text('Loading...', style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,);
                            default:
                              return Expanded(
                                child: SingleChildScrollView(
                                  child: Column(
                                    children:
                                    snapshot.data!.docs.map((DocumentSnapshot document) {

                                      print(document.id);

                                      Post post = Post(text: document['caption'].toString(),
                                          image_url: document['image_url'].toString() ,
                                          date: document['datetime'].toDate().toString().substring(0,10),
                                          likeCount: document['likeCount'],
                                          commentCount: document['comment'].length,
                                          comments: document['comment'],
                                          postId: document.id,
                                          owner: document['owner']);

                                      return PostTileFeed(
                                          post: post,
                                          delete: () {
                                          },
                                          like: () {},
                                          searched: true);
                                    }
                                    ).toList(),
                                  ),
                                ),
                              );
                          }
                        },
                      ),
                    ],
                  ),
              ],
                controller: _tabController,
              ),
            ),
          ],
        )
    );
  }

  void initiateSearch(String val) {
    setState(() {
      name = val.toLowerCase().trim();
      loc = val.toLowerCase().trim();
      cap = val.toLowerCase().trim();
      tag = val.toLowerCase().trim();
    });
  }
}

