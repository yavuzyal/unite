import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unite/LoggedIn.dart';
import 'package:unite/utils/dimensions.dart';
import 'ShowImageFullSlider.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'utils/post_tile.dart';
import 'utils/post.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'SearchedProfile.dart';
import 'utils/post_tile_feed.dart';
import 'usables/config.dart' as globals;
import 'package:unite/valueListenables.dart';

class feedPage extends StatefulWidget {
  const feedPage({Key? key}) : super(key: key);

  @override
  _feedPageState createState() => _feedPageState();

}

class _feedPageState extends State<feedPage> with TickerProviderStateMixin{

  late TabController _tabController = new TabController(length: 2, vsync: this);
  final _user = FirebaseAuth.instance.currentUser;
  List posts = [];
  int likeCount = 0;
  int dummy = 0;
  List<Post> bookmarks = [];

  Future getBookmarks() async {

    bookmarks = [];

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('bookmarks').get();

    for(var message in snapshot.docs){

      String id = message.get('postId');

      String owner = message.get('owner');

      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(owner).collection('posts').doc(id).get();

      int likeCount = snapshot.get('likeCount');

      List comment = snapshot.get('comment');
      String date = snapshot.get('datetime').toDate().toString().substring(0,10);

      Post post = Post(text: snapshot.get('caption').toString(), image_url: snapshot.get('image_url').toString() , date: date, likeCount: likeCount, commentCount: comment.length, comments: comment, postId: id, owner: owner);
      bookmarks.add(post);
    }
  }

  Future getPosts(String id) async{

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(id).collection('posts').orderBy('datetime', descending: true).get();

    DocumentSnapshot snapshot2 = await FirebaseFirestore.instance.collection('users').doc(id).get();

    String name = snapshot2.get('username');

    for(var message in snapshot.docs){

      likeCount = message.get('likeCount');
      List comment = message.get('comment');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);

      Post post = Post(text: message.get('caption').toString(), image_url: message.get('image_url').toString() , date: date, likeCount: likeCount, commentCount: comment.length, comments: comment, postId: message.id, owner_name: name, owner: id);
      posts.add(post);
    }
  }

  Future getFollowing() async{

    posts = [];

    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    List following = snapshot.get('following');

    for(var id in following){
      await getPosts(id);
    }
  }

  @override
  Widget build(BuildContext context) {
        return Column(
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
              text: 'Feed',
            ),
            Tab(
              text: 'Bookmarks',
            ),
            ],
            controller: _tabController,
            indicatorSize: TabBarIndicatorSize.tab,
        ),
            Expanded(
              child: TabBarView(
                children: [
                  FutureBuilder(
    future: getFollowing(),
    builder: (context, snapshot) {
    posts.sort(
    (a,b){
    DateTime dt1 = DateTime.parse(a.date);
    DateTime dt2 = DateTime.parse(b.date);
    return dt2.compareTo(dt1);
    }
    );
    if( snapshot.connectionState == ConnectionState.waiting){
    return Scaffold(
    backgroundColor: globals.light ? Colors.white: Colors.grey[700],
    body: Center(
    child: CircularProgressIndicator(color: globals.light ? AppColors.logoColor: darkAppColors.postTextColor),
    ),
    );
    }
    return Container(
    color: globals.light ? Colors.white: Colors.grey[700],
    child: SingleChildScrollView(
    child: Center(child: Container(
    child: Column(
    children: posts.map(
    (post) =>
    PostTileFeed(
    //userId: _user!.uid,
    post: post,
    delete: () {
    setState(() async {
    //myPosts.remove(post);
    await FirebaseFirestore.instance.collection(
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
    },
                  ),
                  ValueListenableBuilder(
                    valueListenable: valueListenables.bookmarkedPost,
                    builder: (context, bookmarkedPost, snapshot) {
                      return FutureBuilder(
                          future: getBookmarks(),
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
                ],
                controller: _tabController,
              ),
            ),
          ],
        );
  }
}
