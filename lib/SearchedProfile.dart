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

class SearchedProfile extends StatefulWidget {

  final String userId;

  const SearchedProfile({Key? key, required this.userId}) : super(key: key);

  @override
  _SearchedProfile createState() => _SearchedProfile(userId: userId);
}

class User_info {
  String school = '';
  String major = '';
  String age = '';
  String interest = '';
  String bio = '';
  String profile_pic = '';

  User_info(this.school, this.major, this.age, this.interest, this.bio, this.profile_pic);
}

class _SearchedProfile extends State<SearchedProfile> {

  final String userId;

  _SearchedProfile({Key? key, required this.userId});

  User_info user_profile = new User_info('','','','','', '');

  //final _user = FirebaseAuth.instance.currentUser;

  Future getPosts() async{

    print(userId);

    QuerySnapshot profile_info = await FirebaseFirestore.instance.collection('users').doc(userId).collection('profile_info').get();

    for(var mes in profile_info.docs){
      user_profile = User_info(mes.get('school'), mes.get('major'), mes.get('age'), mes.get('interest'), mes.get('bio'), mes.get('profile_pic'));
    }

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').orderBy('datetime', descending: true).get();

    for(var message in snapshot.docs){
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);

      Post post = Post(text: message.get('caption').toString(), image_url: message.get('image_url').toString() , date: date, likeCount: 0, commentCount: 0, comments: {});
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
          if( snapshot.connectionState == ConnectionState.waiting){
            return  Center(child: CircularProgressIndicator());}
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
                              child:
                              user_profile.profile_pic == '' ?
                              Image.asset('assets/usericon.png') :
                              Image.network(user_profile.profile_pic),
                              //Image.network('https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg', fit: BoxFit.cover,),
                            ),
                            radius: 70,
                          ),
                          SizedBox(height : 15),
                          Text("Deneme", style: AppStyles.profileName,),
                          //user!.displayName!

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text(user_profile.school == '' ?
                                "No information was given!" :
                                user_profile.school
                                  , style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),
                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text(user_profile.major == '' ?
                                "No information was given!" :
                                user_profile.major, style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text(user_profile.age == '' ?
                                "No information was given!" :
                                user_profile.age, style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text(user_profile.interest == '' ?
                                "No information was given!" :
                                user_profile.interest, style: AppStyles.profileText, textAlign: TextAlign.left,))
                              ],
                            ),
                          ),

                          Padding(
                            padding: AppDimensions.paddingltrb,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                                Expanded(child: Text(user_profile.bio == '' ?
                                "No information was given!" :
                                user_profile.bio, style: AppStyles.profileText, textAlign: TextAlign.left,))
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