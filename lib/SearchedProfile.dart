import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:unite/utils/post_tile_searched.dart';
import 'LoggedIn.dart';
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

class Username {
  String username = '';
  Username(this.username);
}

class _SearchedProfile extends State<SearchedProfile> {

  final String userId;

  _SearchedProfile({Key? key, required this.userId});

  User_info user_profile = new User_info('','','','','', '');
  String user = '';
  int likeCount = 0;
  bool following = false;
  bool ispriv = true;

  Future getPosts() async{

    DocumentSnapshot mes = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    user = mes.get('username');

    user_profile = User_info(mes.get('school'), mes.get('major'), mes.get('age'), mes.get('interest'), mes.get('bio'), mes.get('profile_pic'));

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').orderBy('datetime', descending: true).get();

    for(var message in snapshot.docs){
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);
      likeCount = message.get('likeCount');
      List comments = message.get('comment');
      print('TYPE');
      print(comments.runtimeType);

      Post post = Post(text: message.get('caption').toString(), image_url: message.get('image_url').toString() , date: date, likeCount: likeCount, commentCount: 0, comments: comments, postId: message.id);
      myPosts.add(post);
    }
  }
  
  Future addFollower () async {

    if(following == false){
      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      List followerArray = [];

      followerArray = follower.get('followers');
      int followerCount = follower.get('followerCount');

      followerArray.add(_user!.uid);


      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'followers': followerArray,
        'followerCount': followerCount + 1,
      });

      setState(() {
        following = true;
      });

    }

    else if(following == true){
      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      List followerArray = [];

      followerArray = follower.get('followers');
      int followerCount = follower.get('followerCount');

      followerArray.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'followers': followerArray,
        'followerCount': followerCount - 1,
      });

      setState(() {
        following = false;
      });

    }
  }

  Future senFollowRequest() async {
    DocumentSnapshot followList = await FirebaseFirestore.instance.collection('users').doc(userId).get();

    List followRequests = [];
    followRequests = followList.get('follow_requests');

    if(!followRequests.contains(_user!.uid)){
      followRequests.add(_user!.uid);
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'follow_requests': followRequests,
      });

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('notifications').add({
        'uid': _user!.uid,
        'message' : 'Follow Request!',
        'datetime': DateTime.now(),
        'url' : '',
        'follow_request': 'yes',
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Follow request has been sent!"),
      ));

    }

    else{
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You have already sent a follow request!"),
      ));
    }

  }


  Future isFollowing() async {

    DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    List followerArray = [];

    followerArray = follower.get('followers');
    String private = follower.get('isPrivate');

    if(private == 'private'){
      ispriv = true;
    }
    else if(private == 'public'){
      ispriv = false;
    }

    if(followerArray.contains(_user!.uid)){
      following = true;
    }
    else if(!followerArray.contains(_user!.uid)){
      following = false;
    }

  }

  //firebase_storage.FirebaseStorage.instance.ref().child('posts').child(_user!.uid).child('/$fileName');

  List<Post> myPosts = [];
  final _user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isFollowing(),
        builder: (context, snapshot) {
          return FutureBuilder(
              future: getPosts(),
              builder: (context, snapshot){
                if( snapshot.connectionState == ConnectionState.waiting){
                  return  Center(child: CircularProgressIndicator());}
                return Scaffold(
                  appBar: AppBar(
                    title: Text(user),
                    centerTitle: true,
                  ),
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
                                Text(user, style: AppStyles.profileName,),
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

                                SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        following == true ? addFollower() : senFollowRequest();
                                      },
                                      child: following==true ? Text('Unfollow', style: TextStyle(fontSize: 20),) : Text('Follow', style: TextStyle(fontSize: 20),),
                                      style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                                    ),
                                    ElevatedButton(
                                      onPressed: (){

                                      },
                                      child: Text('Message', style: TextStyle(fontSize: 20),),
                                      style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),
                                ispriv == true && following == false ?
                                    Container(
                                      child: Center(
                                        child: Column(
                                          children: [
                                            SizedBox(height: 25,),
                                            Icon(Icons.lock, size: 200, color: Colors.blueAccent,),
                                            Text('Private Account!', style: TextStyle(fontSize: 25),),
                                            SizedBox(height: 50,),
                                          ],
                                        ),
                                      ),
                                    )
                                    : Container(
                                  child: Column(
                                    children: myPosts.map(
                                            (post) =>
                                            PostTileSearched(
                                              userId: userId,
                                              post: post,
                                              delete: () {
                                                setState(() {
                                                  myPosts.remove(post);
                                                });
                                              },
                                              like: () {
                                                setState(() async {
                                                  //post.likeCount++;

                                                  await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).update({
                                                    'like': likeCount + 1,
                                                  });

                                                  setState(() {
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                                        LoggedIn()),);
                                                  });

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
        });
  }
}