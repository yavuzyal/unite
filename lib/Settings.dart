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
      await FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('account_info').doc('isPrivate').set({
        'isPrivate': 'private',
      });

      setState(() {
        priv = true;
      });

    }

    else if(isPrivate == 'private'){
      await FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('account_info').doc('isPrivate').set({
        'isPrivate': 'public',
      });

      setState(() {
        priv = false;
      });

    }

  }

  Future ifPrivate() async {

    DocumentSnapshot info = await FirebaseFirestore.instance.collection("users").doc(_user!.uid).collection('account_info').doc('isPrivate').get();

    isPrivate = info.get('isPrivate');

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
            backgroundColor: globals.light ? Colors.white: Colors.black,
            body: Center(
                child: Padding(
                  padding: AppDimensions.padding20,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/unite_logo.png', height: 150, width: 150,),
                          SizedBox(height: 20.0,),
                          Text("UNIte", style: AppStyles.appNameMainPage,),
                          SizedBox(height: 20.0,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                            //ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck)),
                            onPressed: () {
                              setState(() {
                                globals.light = !globals.light;
                              });
                            },
                            child: globals.light ? Text('Dark Mode', style: TextStyle(fontSize: 20, ),) : Text('Light Mode', style: TextStyle(fontSize: 20, ),),
                          ),

                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                            onPressed: () {
                              setState(() {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => EditProfile()),
                                );
                                //FirebaseAnalytics.instance.logScreenView(screenClass: "LoginPage", screenName: "LoginPage");
                              });
                            },
                            child: Text('Edit Profile', style:  TextStyle(fontSize: 20),),),

                          SizedBox(height: 10.0,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                            //ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck), ),
                            onPressed: () async{

                              await FirebaseAuth.instance.signOut();

                              final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                              provider.googleLogout();

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

                              //setLogOut();

                            },
                            child: Text('Log Out', style: TextStyle(fontSize: 20, ),),
                          ),

                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                            onPressed: () {
                              setState(() async {
                                makePrivate();
                              });
                            },
                            child: Text(isPrivate == 'public' ? 'Make Private' : 'Make Public', style:  TextStyle(fontSize: 20),),
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
