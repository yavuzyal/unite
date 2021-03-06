import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:unite/utils/dimensions.dart';
import 'package:unite/utils/styles.dart';
import 'EditProfile.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'changePassword.dart';
import 'valueListenables.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _Settings2();
}

class _Settings2 extends State<Settings> {

  Future setLogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();    //TO CHECK THE FIRST TIME OPENING
    await prefs.setBool('loggedIn', false);
    await prefs.setString('email', '');
    await prefs.setString('password', '');
  }

  Future makePrivate() async{

    if(isPrivate == 'public'){
      await FirebaseFirestore.instance.collection("users").doc(_user!.uid).update({
        'isPrivate': 'private',
      });

      setState(() {
        priv = true;
      });

    }

    else if(isPrivate == 'private'){
      await FirebaseFirestore.instance.collection("users").doc(_user!.uid).update({
        'isPrivate': 'public',
      });

      setState(() {
        priv = false;
      });

    }

  }


  Future ifPrivate() async {

    DocumentSnapshot info = await FirebaseFirestore.instance.collection("users").doc(_user!.uid).get();

    isPrivate = info.get('isPrivate');

  }

  Future deactivateAccount() async {

    final _user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    String image = userInfo.get("profile_pic");
    String name = userInfo.get("username");

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).update({
      'username' : "UNIte user",
      'profile_pic' : "",
      'deactivated' : true,
      'old_username' : name,
      'old_profile_pic' : image,
      'isPrivate' : 'public'
    });

    List followers = userInfo.get('followers');
    List following = userInfo.get('following');

    for(int i = 0; i < followers.length; i++){

      String followerId = followers[i];

      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(followerId).get();

      List followingArray = [];

      followingArray = follower.get('following');
      int followingCount = follower.get('followingCount');

      followingArray.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(followerId).update({
        'following': followingArray,
        'followingCount': followingCount - 1,
      });
    }

    for(int i = 0; i < following.length; i++){

      String followerId = following[i];

      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(followerId).get();

      List followerArray = [];

      followerArray = follower.get('followers');
      int followerCount = follower.get('followerCount');

      followerArray.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(followerId).update({
        'followers': followerArray,
        'followerCount': followerCount - 1,
      });
    }

    }

  Future deleteAccount() async {

    final _user = FirebaseAuth.instance.currentUser;

    DocumentSnapshot userInfo = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    List followers = userInfo.get('followers');
    List following = userInfo.get('following');

    for(int i = 0; i < followers.length; i++){

      String followerId = followers[i];

      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(followerId).get();

      List followingArray = [];

      followingArray = follower.get('following');
      int followingCount = follower.get('followingCount');

      followingArray.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(followerId).update({
        'following': followingArray,
        'followingCount': followingCount - 1,
      });
    }

    for(int i = 0; i < following.length; i++){

      String followerId = following[i];

      DocumentSnapshot follower = await FirebaseFirestore.instance.collection('users').doc(followerId).get();

      List followerArray = [];

      followerArray = follower.get('followers');
      int followerCount = follower.get('followerCount');

      followerArray.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(followerId).update({
        'followers': followerArray,
        'followerCount': followerCount - 1,
      });
    }

    await FirebaseFirestore.instance.collection("users").doc(_user!.uid).delete().then((_){
      _user!.delete();

      setState(() {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      });
    });

  }

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  final _user = FirebaseAuth.instance.currentUser;
  String isPrivate = '';
  bool priv = true;

  Color buttonColorCheck(Set<MaterialState> states){
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.dragged,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.buttonColorPressed;
    }
    return AppColors.buttonColor;
  }

  Widget build(BuildContext context) {
    return FutureBuilder(
        future: ifPrivate(),
        builder: (context, snapshot){
          return Scaffold(
            backgroundColor: globals.light ? Colors.white: Colors.grey[700],
            body: Center(
                child: Padding(
                  padding: AppDimensions.padding20,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/unite_logo.png', height: 100, width: 100,),
                          SizedBox(height: 20.0,),
                          Text("UNIte", style: globals.light ? AppStyles.appNameMainPage : darkAppStyles.appNameMainPage,),
                          SizedBox(height: 20.0,),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),                            //ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck)),
                            onPressed: () async {
                              SharedPreferences prefs = await SharedPreferences.getInstance();
                              prefs.setBool('isLight', !globals.light);
                              setState(() {
                                globals.light = !globals.light;
                                valueListenables.theme.value= !valueListenables.theme.value;
                              });
                            },
                            child: globals.light ? Text('Dark Mode', style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,) : Text('Light Mode', style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),

                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),
                            onPressed: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfile()),
                                );
                                //FirebaseAnalytics.instance.logScreenView(screenClass: "LoginPage", screenName: "LoginPage");
                              });
                            },
                            child: Text('Edit Profile', style:  globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),),

                          SizedBox(height: 10.0,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),
                            onPressed: () {
                              setState(()  {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => changePassword()),
                                );
                              });
                            },
                            child: Text("Change password", style:  globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),                             onPressed: () {
                              setState(() async {
                                makePrivate();
                              });
                            },
                            child: Text(isPrivate == 'public' ? 'Make Private' : 'Make Public', style:  globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),
                          SizedBox(height: 10.0,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),                             //ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck), ),
                            onPressed: () async{

                              await FirebaseAuth.instance.signOut();

                              final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                              provider.googleLogout();

                              await FacebookLogin().logOut();

                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => LoginPage()),
                                );
                                //FirebaseAnalytics.instance.logScreenView(screenClass: "LoginPage", screenName: "LoginPage");
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Logged Out')),
                              );


                            },
                            child: Text('Log Out', style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),
                            onPressed: () async{
                              deactivateAccount();
                              await FirebaseAuth.instance.signOut();

                              final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                              provider.googleLogout();

                              await FacebookLogin().logOut();

                              setState(() {
                              Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                          }
                              );
                              },
                            child: Text("Deactivate account", style:  globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                                minimumSize: MaterialStateProperty.all(Size(200,50))
                            ),
                            onPressed: () {
                                deleteAccount();
                            },
                            child: Text("Delete account", style:  globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ),
          );
        }
        );

  }
}
