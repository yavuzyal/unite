import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:unite/utils/post_tile_searched.dart';
import 'LoggedIn.dart';
import 'ShowImageFullSlider.dart';
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

class _SearchedProfile extends State<SearchedProfile> with TickerProviderStateMixin{

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

      if(post.image_url != '') {
        myImages.add(Image.network(post.image_url));
      }

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
        'message' : 'Follow Request from ${_user!.displayName}!',
        'datetime': DateTime.now(),
        'url' : _user!.photoURL,
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

  Future ifPrivate() async {

    followersList = [];
    followingList = [];

    DocumentSnapshot info = await FirebaseFirestore.instance.collection("users").doc(userId).get();

    List list_followers = info.get('followers');

    for(var i = 0; i < list_followers.length; i++) {
      var follower = list_followers[i];
      DocumentSnapshot info = await FirebaseFirestore.instance.collection(
          "users").doc(follower).get();
      List details = [info['username'], info['profile_pic'], info['userId']];
      followersList.add(details);

    }
    List list_following = info.get('following');

    for(var i = 0; i < list_following.length; i++) {
      var follower = list_following[i];
      DocumentSnapshot info = await FirebaseFirestore.instance.collection(
          "users").doc(follower).get();
      List details = [info['username'], info['profile_pic'], info['userId']];
      followingList.add(details);

    }
  }

  Widget _buildPopupDialogFollowing(BuildContext context) {

    return new AlertDialog(
      title: const Text('Following'),
      content: new Container(child: SingleChildScrollView(
        child: Center(child: Container(
          child: Column(
            children: followingList.map(
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
            children: followersList.map(
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
    if(ispriv & following){
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
            child: Text("${followersList.length} followers", style: AppStyles.profileText),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoColor),
            ),
          ),

          SizedBox(width: 20),

          TextButton(onPressed: (){showDialog(
            context: context,
            builder: (BuildContext context) => _buildPopupDialogFollowing(context),
          );},
            child: Text("${followingList.length} following", style: AppStyles.profileText),
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
  List followersList = [];
  List followingList = [];
  final _user = FirebaseAuth.instance.currentUser;
  late TabController _tabController = new TabController(length: 2, vsync: this);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: Future.wait([ ifPrivate(), isFollowing()]),
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
                    RefreshIndicator(
                      onRefresh: getPosts,
                      child: SingleChildScrollView(
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
                                          radius: 70,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height : 15),
                                    Text(user, style: AppStyles.profileName, textAlign: TextAlign.center,),
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

                                    getFollowers(),

                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            following == true ? addFollower() : senFollowRequest();
                                          },
                                          child: following==true ? Text('Unfollow', style: AppStyles.profileText,) : Text('Follow', style: AppStyles.profileText,),
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoColor)),
                                        ),
                                        SizedBox(width: 20),
                                        ElevatedButton(
                                          onPressed: (){

                                          },
                                          child: Text('Message', style: AppStyles.profileText),
                                          style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(AppColors.logoColor)),
                                        ),
                                      ],
                                    ),

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
                                        : SizedBox(
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
                                                          }
                                                          ,)
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
                      ),),
                );
              }

          );
        });
  }
}


/*
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
},)*/
