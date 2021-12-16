import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unite/utils/dimensions.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'utils/post_tile.dart';
import 'utils/post.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class post {
  String ? caption;
  int ? likes;
  String ? date;
  int ? likeCount;
  int ? commentCount;
  List ? comments;


}

class _ProfileState extends State<Profile> {

  final _user = FirebaseAuth.instance.currentUser;

  Future getPosts() async{
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').get();
    List docs = snapshot.docs;

    for(var message in snapshot.docs){
      Post post = Post(text: message.get('caption').toString(), image_url: message.get('image_url').toString() , date: '22.10.2019', likeCount: 0, commentCount: 0, comments: {});
      myPosts.add(post);
    }
  }

  //firebase_storage.FirebaseStorage.instance.ref().child('posts').child(_user!.uid).child('/$fileName');

  List<Post> myPosts = [];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getPosts(),
        builder: (context, snapshot){
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: (){FirebaseCrashlytics.instance.crash();},
              backgroundColor: AppColors.logoColor,
              child: Icon(Icons.close, color: AppColors.postTextColor,),
            ),
            body:
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Center(
                    child: Padding(
                      padding: AppDimensions.padding8,
                      child: Column(
                        children: [
                          Image.asset('assets/unite_logo.png', height: 50, width: 50,),
                          SizedBox(height: 30.0,),
                          CircleAvatar(
                            backgroundColor: AppColors.logoColor,
                            child: ClipOval(
                              child: Image.network(_user!.photoURL == null ?
                              'https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg': _user!.photoURL!, fit: BoxFit.fitWidth,),
                              //Image.network('https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg', fit: BoxFit.cover,),
                            ),
                            radius: 70,
                          ),
                          SizedBox(height : 15),
                          Text(_user!.displayName==null ? "Barış Altop" : _user!.displayName!, style: AppStyles.profileName,),
                          //user!.displayName!

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text("Sabancı University", style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),
                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text("Computer Science", style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text("30", style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text("Hacking, coding, travelling, interest4, interest5", style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text("Hi there, I am using UNIte!", style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          SizedBox(height: 20),
                          Container(
                            child: Column(
                              children: myPosts.map(
                                      (post) =>
                                      PostTile(
                                        post: post,
                                        delete: () {
                                          setState(() {
                                            myPosts.remove(post);
                                          });
                                        },
                                        like: () {
                                          setState(() {
                                            post.likeCount++;
                                          });
                                        },)
                              ).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

    );
  }
}