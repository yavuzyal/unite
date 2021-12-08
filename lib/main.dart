import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/usables/config.dart' as globals;

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/post_page.dart';
import 'Walkthrough.dart';
import 'utils/post.dart';

import 'Greeting.dart';
import 'Settings.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final Future<FirebaseApp> _fbapp = Firebase.initializeApp();

  runApp(MaterialApp(
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
          return Center(
            child: CircularProgressIndicator(),
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
    },
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();

  static final ValueNotifier<ThemeMode> themeNotifier =
  ValueNotifier(ThemeMode.light);
}

/// This is the private State class that goes with MyStatefulWidget.
class _MainPageState extends State<MainPage> {

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Profile(),
    Text(
      'Location',
      style: optionStyle,
    ),
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
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.blue[700],
        title: const Text('UNIte'), centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
            backgroundColor: globals.light ? Colors.lightBlueAccent: Colors.blue[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Location',
            backgroundColor: Colors.green,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box),
            label: 'Add Post',
            backgroundColor: Colors.purple,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.email),
            label: 'Messages',
            backgroundColor: Colors.orange,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Colors.pink,
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
