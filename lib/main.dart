import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/LoggedIn.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/Search.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/colors.dart';
import 'package:unite/utils/post_page.dart';
import 'Walkthrough.dart';
import 'feedPage.dart';
import 'utils/post.dart';

import 'Greeting.dart';
import 'Settings.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<FirebaseApp> _fbapp = Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  globals.light = prefs.getBool('isLight') ?? true;
  runApp(
    ChangeNotifierProvider(
      create: (context) => GoogleSignInProvider(),
      child: MaterialApp(
        home: FutureBuilder(
          future: _fbapp,
          builder: (context, snapshot){
            if(snapshot.hasError){
              print('You have an error ${snapshot.error.toString()}');
            }
            else if(snapshot.hasData){
              return Greeting();
            }
            else{
              return Scaffold(
                backgroundColor: globals.light ? Colors.white: Colors.grey[700],
                body: Center(
                  child: CircularProgressIndicator(color: globals.light ? AppColors.logoColor: darkAppColors.postTextColor),
                ),
              );
            }
            throw "You have thrown something";
          },
        ),
        theme: globals.light ? globals.lightTheme : globals.darkTheme,
        debugShowCheckedModeBanner: false,
        //initialRoute: '/greeting',
        routes: {
          '/login': (context) => LoginPage(),
          '/main': (context) => MainPage(),
          '/register': (context) => RegisterPage(),
          '/greeting': (context) => Greeting(),
          '/settings': (context) => Settings(),
          '/pageOne': (context) => LoginPage(),
          '/profile': (context) => Profile(),
          '/walkthrough': (context) => WalkthroughScreen(),
          '/feed': (context) => feedPage()
        },
      ),
    ),
  );
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

}

class _MainPageState extends State<MainPage> {

  Future loggedInScreen() async{
    return LoggedIn();
  }

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Profile(),
    Search(),
    Text(
      'Add Post',
      style: optionStyle,
    ),
    Text(
      'Messages',
      style: optionStyle,
    ),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            print("problem");
            return Scaffold(
              backgroundColor: globals.light ? Colors.white: Colors.grey[700],
              body: Center(
                child: CircularProgressIndicator(color: globals.light ? AppColors.logoColor: darkAppColors.postTextColor),
              ),
            );
          }
          else if(snapshot.hasData) {
            print(snapshot);
            print("logged in");
            return LoggedIn();
          }
          else if(snapshot.hasError) {
            print("error");
            return Center(
              child: Text("Something Went Wrong"),
            );
          }
          else{
            print("en son");
            return LoginPage();
          }
        },
      ),

    );
  }
}
