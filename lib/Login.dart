import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_login_facebook/flutter_login_facebook.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/LoggedIn.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/main.dart';
import 'package:unite/setUsername.dart';
import 'package:unite/utils/authentication_service.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:unite/utils/styles.dart';
import 'package:unite/usables/config.dart' as globals;
import 'utils/colors.dart';
import 'utils/styles.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage2();
}

class _LoginPage2 extends State<LoginPage> {

  Future setLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();    //TO CHECK THE FIRST TIME OPENING
    //await prefs.setBool('loggedIn', true);
    //await prefs.setString('email', email!);
    //await prefs.setString('password', password!);
  }

  Future ?noUser()  {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Email or password is wrong!')),
    );
  }

  Future <String?> facebookSignUp(profile)async {

    final _user = FirebaseAuth.instance.currentUser;

    List<String> indexList = [];

    String name = profile!.firstName.toString().toLowerCase().trim();

    for(int i = 1; i <= name.length; i++){
      indexList.add(name.substring(0, i).toLowerCase());
    }

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
      'username' : profile!.name,
      'searchKey': indexList,
      'userId': _user!.uid,
      'isPrivate': 'public',
      'followers': [],
      'followerCount': 0,
      'following': [],
      'followingCount': 0,
      "school" : '',
      "major" : '',
      "age" : '',
      "interest": '',
      "bio": '',
      "profile_pic": '',
      'follow_requests': [],
      'bookmarks' : []
    });

    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('notifications').add({});
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').add({});
    await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('bookmarks').add({});

  }


  signInWithFacebook() async {
    final fb = FacebookLogin();
    // Log in
    final res = await fb.logIn(permissions: [
      FacebookPermission.publicProfile,
      FacebookPermission.email,
    ]);
    // Check result status
    switch (res.status) {
      case FacebookLoginStatus.success:
      // The user is suceessfully logged in
      // Send access token to server for validation and auth
        final FacebookAccessToken accessToken = res.accessToken!;
        final AuthCredential authCredential = FacebookAuthProvider.credential(accessToken.token);
        final result = await FirebaseAuth.instance.signInWithCredential(authCredential);
        // Get profile data from facebook for use in the app
        final profile = await fb.getUserProfile();
        print('Hello, ${profile!.name}! You ID: ${profile.userId}');
        // Get user profile image url
        final imageUrl = await fb.getProfileImageUrl(width: 100);
        print('Your profile image: $imageUrl');
        // fetch user email
        final email = await fb.getUserEmail();
        // But user can decline permission
        if (email != null) print('And your email is $email');

        final _user = FirebaseAuth.instance.currentUser;

        QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').where("userId", isEqualTo: _user!.uid).get();

        if (snapshot.docs.isEmpty){
          facebookSignUp(profile);
        }

        facebooklogin();
        break;

      case FacebookLoginStatus.cancel:
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()),);
        break;
      case FacebookLoginStatus.error:
      // Login procedure failed
        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()),);
        break;
    }
  }

  Future GoogleLogin() async {

    //DocumentSnapshot profile_info = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    Navigator.push(context, MaterialPageRoute(builder: (context) => LoggedIn()),);

    //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful')),);
    //FirebaseAnalytics.instance.logScreenView(screenName: "Profile");
  }

  Future facebooklogin() async {

    //DocumentSnapshot profile_info = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    Navigator.push(context, MaterialPageRoute(builder: (context) => LoggedIn()),);

    //ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful')),);
    //FirebaseAnalytics.instance.logScreenView(screenName: "Profile");
  }


  User? _user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  //String? email = "";
  //String? password = "";
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$');


  Color buttonColorCheck(Set<MaterialState> states){
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.dragged,
    };
    if (states.any(interactiveStates.contains)) {
      return globals.light ? AppColors.buttonColorPressed : darkAppColors.buttonColorPressed;
    }
    return globals.light ? AppColors.buttonColor : darkAppColors.buttonColor;
  }

  Widget build(BuildContext context) {

    String email = "";
    String password = "";

    return ChangeNotifierProvider(
        create: (context) => GoogleSignInProvider(),
        child: WillPopScope(
          onWillPop: () async => false,
          child: Scaffold(
            body: Center(
                child: Padding(
                  padding: AppDimensions.padding20,
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children:[
                          Image.asset('assets/unite_logo.png', height: 150, width: 150,),
                          SizedBox(height: 20.0,),
                          Text("UNIte", style: AppStyles.appNameMainPage,),
                          SizedBox(height: 20.0,),
                          TextFormField(
                            style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                            textAlign: TextAlign.center,
                            decoration: new InputDecoration(
                              hintText: "Enter Email",
                              hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                              fillColor: Colors.black,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              else if(!EmailValidator.validate(value)){
                                return 'Please enter a valid email address';
                              }
                              else {
                                email = value;
                              }
                              return null;
                            },

                          ),
                          SizedBox(height: 20.0,),
                          TextFormField(
                            style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                            obscureText: true,
                            textAlign: TextAlign.center,
                            decoration: new InputDecoration(
                              hintText: "Enter Password",
                              hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                              fillColor: Colors.black,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }
                              else if (value.length < 8){
                                return 'Password length cannot be less than 8 characters';
                              }
                              else if(!regex.hasMatch(value)){
                                return 'Password should include an uppercase letter, a lowercase\n  letter, one digit and a special character';
                              }
                              else{
                                password = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 20.0,),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                            ),                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {

                                await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password).then((currentUser) => {
                                  setState(() {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Successful')),);
                                    FirebaseAnalytics.instance.logScreenView(screenName: "Profile");
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => MainPage()),);
                                  })
                                }).catchError((onError)=>{
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email or password is wrong!')),)
                                });;
                                //setLoggedIn();
                              }
                            },
                            child: const Text('Sign In', style: TextStyle(fontSize: 16),),
                          ),
                          SizedBox(height: 5.0,),
                          Row(
                              children: <Widget>[
                                Expanded(
                                    child: Divider()
                                ),

                                Text("OR"),

                                Expanded(
                                    child: Divider()
                                ),
                              ]
                          ),
                          SizedBox(height: 5.0,),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                            ),
                            onPressed: () async{

                                final provider = Provider.of<GoogleSignInProvider>(context, listen: false);
                                provider.googleLogin().then((value) => GoogleLogin());

                                //GoogleLogin();
                              },
                            label: Text("Sign In with Google", style: TextStyle(fontSize: 16),),
                            icon: FaIcon(FontAwesomeIcons.google),
                          ),
                          SizedBox(height: 5.0,),
                          ElevatedButton.icon(
                            style: ButtonStyle(
                              backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                            ),                            onPressed: () {
                              signInWithFacebook();
                            },
                            label: Text("Sign In with Facebook", style: TextStyle(fontSize: 16),),
                            icon: FaIcon(FontAwesomeIcons.facebook),
                          ),
                          SizedBox(height: 10.0,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("New to Unite? ", style: TextStyle(fontSize: 16),),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RegisterPage()),
                                  );
                                },
                                child: new Text("Sign Up", style: AppStyles.signUp, ),
                              )
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ),
          ),
        ));
  }
}



