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

class Profile extends StatefulWidget {

  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
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

class _ProfileState extends State<Profile> with TickerProviderStateMixin{

  late TabController _tabController = new TabController(length: 2, vsync: this);

  User_info user_profile = new User_info('','','','','', '');
  String displayName = '';

  final _user = FirebaseAuth.instance.currentUser;
  int likeCount = 0;
  int dummy = 0;

  Future getPosts() async{

    DocumentSnapshot mes = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    displayName = mes.get('username');
    print(displayName);


    user_profile = User_info(mes.get('school'), mes.get('major'), mes.get('age'), mes.get('interest'), mes.get('bio'), mes.get('profile_pic'));

    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').orderBy('datetime', descending: true).get();

    for(var message in snapshot.docs){

      likeCount = message.get('likeCount');
      List comment = message.get('comment');
      Timestamp t = message.get('datetime');
      DateTime d = t.toDate();
      String date = d.toString().substring(0,10);

      Post post = Post(text: message.get('caption').toString(), image_url: message.get('image_url').toString() , date: date, likeCount: likeCount, commentCount: comment.length, comments: comment, postId: message.id);
      myPosts.add(post);

      if(post.image_url != '') {
        myImages.add(Image.network(post.image_url));
      }

    }
  }

  Future ifPrivate() async {

    followers = [];
    following = [];

    DocumentSnapshot info = await FirebaseFirestore.instance.collection("users").doc(_user!.uid).get();

    isPrivate = info.get('isPrivate');
    List list_followers = info.get('followers');

    for(var i = 0; i < list_followers.length; i++) {
      var follower = list_followers[i];
      DocumentSnapshot info = await FirebaseFirestore.instance.collection("users").doc(follower).get();
      List details = [info['username'], info['profile_pic'], info['userId']];
      followers.add(details);
    }

    List list_following = info.get('following');

    for(var i = 0; i < list_following.length; i++) {
      var follower = list_following[i];
      DocumentSnapshot info = await FirebaseFirestore.instance.collection(
          "users").doc(follower).get();
      List details = [info['username'], info['profile_pic'], info['userId']];
      following.add(details);
    }
  }

  Widget _buildPopupDialogFollowing(BuildContext context) {

    return new AlertDialog(
      title: const Text('Following'),
      content: new Container(child: SingleChildScrollView(
        child: Center(child: Container(
          child: Column(
            children: following.map(
                    (follower) =>
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextButton(child: Row(
                              children: [
                                follower[1] != '' ?
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.network(follower[1], width: 50),
                                )
                                    :
                                Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Image.asset('assets/usericon.png', width: 50),
                                ),

                                Container(
                                  width: MediaQuery.of(context).size.width*0.4,
                                  child: Text(follower[0],
                                    style: AppStyles.profileText,
                                  ),
                                ),
                              ],
                            ),
                                onPressed: (){
                                  follower[2] != _user!.uid ?
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      SearchedProfile(userId: follower[2])),) :
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      LoggedIn()));
                                }),
                          ],
                        ),
                      ),
                    )
            ).toList(),
          ),
        ),
        ),
      ),
      ),
    );
  }


  Widget _buildPopupDialogFollowers(BuildContext context) {

    return new AlertDialog(
      title: const Text('Followers'),
      content: new Container(child: SingleChildScrollView(
        child: Center(child: Container(
          child: Column(
            children: followers.map(
                    (follower) =>
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                            TextButton(child: Row(
                                children: [
                                  follower[1] != '' ?
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.network(follower[1], width: 50),
                                  )
                                  :
                                  Padding(
                                    padding: const EdgeInsets.all(6.0),
                                    child: Image.asset('assets/usericon.png', width: 50),
                                  ),

                                  Container(
                                    width: MediaQuery.of(context).size.width*0.4,
                                    child: Text(follower[0],
                                      style: AppStyles.profileText,
                                    ),
                                  ),
                                ],
                            ),
                                onPressed: (){
                                  follower[2] != _user!.uid ?
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      SearchedProfile(userId: follower[2])),) :
                                  Navigator.push(context, MaterialPageRoute(builder: (context) =>
                                      LoggedIn()));
                                }),
                          ],
                        ),
                      ),
                    )
            ).toList(),
          ),
        ),
        ),
      ),
      ),
    );
  }

  Widget getFollowers(){

    if(isPrivate == "private"){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 20),
          TextButton(onPressed: (){showDialog(
        context: context,
        builder: (BuildContext context) => _buildPopupDialogFollowers(context),
      );
      },
        child: Text("${followers.length} followers", style: AppStyles.profileText),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoColor),
        ),
      ),

      SizedBox(width: 20),

      TextButton(onPressed: (){showDialog(
        context: context,
        builder: (BuildContext context) => _buildPopupDialogFollowing(context),
      );},
        child: Text("${following.length} following", style: AppStyles.profileText),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoColor),
        ),
      ),
          SizedBox(height: 20),
        ],
      );
  };
    return SizedBox.shrink();
  }
  //firebase_storage.FirebaseStorage.instance.ref().child('posts').child(_user!.uid).child('/$fileName');

  List<Post> myPosts = [];
  List<Image> myImages = [];
  String isPrivate = '';
  List followers = [];
  List following = [];

  @override
  Widget build(BuildContext context) {

    return FutureBuilder(
        future: Future.wait([ifPrivate(), getPosts()]),
        builder: (context, snapshot){
          if( snapshot.connectionState == ConnectionState.waiting){
            return  Center(child: CircularProgressIndicator());
          }
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              onPressed: (){FirebaseCrashlytics.instance.crash();},
              backgroundColor: AppColors.logoColor,
              child: Icon(Icons.close, color: AppColors.postTextColor,),
            ),
            body:
              RefreshIndicator(
                onRefresh: getPosts,
                child:  SingleChildScrollView(
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
                            ClipRRect(
                              child: InkWell(
                                onTap: () {
                                  if (user_profile.profile_pic != '') {
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) =>
                                            SliderShowFullmages(listImagesModel: [user_profile.profile_pic])));
                                  }
                                },
                                child: CircleAvatar(
                                  backgroundColor: AppColors.logoColor,
                                  child: ClipOval(
                                    child:
                                    user_profile.profile_pic == '' ?
                                    Image.asset('assets/usericon.png') :
                                    Image.network(user_profile.profile_pic),
                                    //Image.network('https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg', fit: BoxFit.cover,),
                                  ),
                                  radius: 60,
                                ),
                              ),
                            ),
                            SizedBox(height : 15),
                            Text(displayName , style: AppStyles.profileName, textAlign: TextAlign.center),
                            //Text(_user!.displayName==null ? displayName : _user!.displayName!, style: AppStyles.profileName,),
                            //user!.displayName!

                            Padding(
                              padding: AppDimensions.paddingltrb,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.school, color: AppColors.appTextColor),
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
                                  Icon(Icons.note, color: AppColors.appTextColor),
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
                                  Icon(Icons.family_restroom, color: AppColors.appTextColor),
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
                                  Icon(Icons.check_circle, color: AppColors.appTextColor),
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
                                  Icon(Icons.add_box_rounded, color: AppColors.appTextColor),
                                  Expanded(child: Text(user_profile.bio == '' ?
                                  "No information was given!" :
                                  user_profile.bio, style: AppStyles.profileText, textAlign: TextAlign.left,))
                                ],
                              ),
                            ),

                            getFollowers(),

                            TabBar(
                              isScrollable: true,
                              unselectedLabelColor: AppColors.appTextColor,
                              unselectedLabelStyle: AppStyles.profileText,
                              labelColor: AppColors.appTextColor,
                              labelStyle: AppStyles.profileText,
                              indicatorColor: AppColors.logoColor,
                              indicatorWeight: 3,

                              tabs: [
                                Tab(
                                  text: 'Posts',
                                ),
                                Tab(
                                  text: 'Media',
                                )
                              ],
                              controller: _tabController,
                              indicatorSize: TabBarIndicatorSize.tab,
                            ),

                            SizedBox(
                              height: 500,
                              child: TabBarView(
                                children: [
                                  Container(child: SingleChildScrollView(
                                    child: Center(child: Container(
                                      child: Column(
                                        children: myPosts.map(
                                                (post) =>
                                                PostTile(
                                                  //userId: _user!.uid,
                                                  post: post,
                                                  delete: () {
                                                    setState(() async {
                                                      //myPosts.remove(post);
                                                      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(post.postId).delete();
                                                      FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('notifications').add(
                                                          {
                                                          'message' : 'You deleted a post!',
                                                          'datetime': DateTime.now(),
                                                          'url': post.image_url,
                                                          'uid': _user!.uid,
                                                          'follow_request': 'no',
                                                          });
                                                    });
                                                  },
                                                  like: () {
                                                    setState(()  {
                                                      //post.likeCount++;
                                                      dummy = dummy + 1;
                                                    });
                                                  },)
                                        ).toList(),
                                      ),
                                    ),
                                    ),
                                  ),
                                  ),
                                  CustomScrollView(
                                    primary: false,
                                    slivers: <Widget>[
                                      SliverPadding(
                                        padding: const EdgeInsets.all(3.0),
                                        sliver: SliverGrid.count(
                                            mainAxisSpacing: 1, //horizontal space
                                            crossAxisSpacing: 1, //vertical space
                                            crossAxisCount: 3, //number of images for a row
                                            children: myImages
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                controller: _tabController,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              ),
          );
        }

    );
  }
}

/*
'message' : 'You deleted a post!',
'datetime': DateTime.now(),
'url': post.image_url,
'uid': _user!.uid,
'follow_request': 'no',*/
