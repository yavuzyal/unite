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

class feedPage extends StatefulWidget {
  const feedPage({Key? key}) : super(key: key);

  @override
  _feedPageState createState() => _feedPageState();
}

class _feedPageState extends State<feedPage> {

  final _user = FirebaseAuth.instance.currentUser;
  List posts = [];
  int likeCount = 0;
  int dummy = 0;

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
    return FutureBuilder(
      future: getFollowing(),
      builder: (context, snapshot) {
        posts.sort(
                (a,b){
              DateTime dt1 = DateTime.parse(a.date);
              DateTime dt2 = DateTime.parse(b.date);
              return dt2.compareTo(dt1);
            }
        );
        return Container(
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
                              FirebaseFirestore.instance.collection("users")
                                  .doc(_user!.uid).collection('notifications')
                                  .add(
                                  {
                                    'message': 'You deleted a post!',
                                    'datetime': DateTime.now(),
                                    'url': post.image_url,
                                    'uid': _user!.uid,
                                    'follow_request': 'no',
                                  });
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
  }
}
