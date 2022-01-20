import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:unite/ChatPage.dart';
import 'package:unite/Chat_Main.dart';
import 'package:unite/Login.dart';
import 'package:unite/Notifications.dart';
import 'package:unite/PostScreen.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/Search.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:unite/utils/colors.dart';
import 'feedPage.dart';
import 'package:http/http.dart' as http;
import 'package:unite/bookmarkPage.dart';
import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/profile.dart';
import 'package:unite/utils/post_page.dart';
import 'Walkthrough.dart';
import 'utils/post.dart';

import 'Greeting.dart';
import 'Settings.dart';



class LoggedIn extends StatefulWidget {
  const LoggedIn({Key? key}) : super(key: key);

  @override
  State<LoggedIn> createState() => _LoggedIn();

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);
}

class _LoggedIn extends State<LoggedIn> {

  final _user = FirebaseAuth.instance.currentUser;

  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Profile(),
    Search(),
    feedPage(),
    PostScreen(),
    ChatMain(),
    Settings(),
  ];

  static List<String> page_names = [
    "Account", "Search", "Feed", "Add_post", "Messages", "Settings"
  ];
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    FirebaseAnalytics.instance.logScreenView(screenClass: page_names[_selectedIndex], screenName: page_names[_selectedIndex]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.bookmarks),
          color: globals.light ? AppColors.postTextColor : darkAppColors.appTextColor,
          onPressed: (){
            Navigator.push(context, MaterialPageRoute(builder: (context) => bookmarkPage()),);
          },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.notifications),
            color: globals.light ? AppColors.postTextColor : darkAppColors.appTextColor,
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Notifications()),);
            },),
        ],
        automaticallyImplyLeading: false,
        backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
        title: const Text('UNIte'), centerTitle: true,
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.account_circle,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Account',
            backgroundColor: globals.light ? Colors.lightBlueAccent: Colors.blue[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.search,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Search',
            backgroundColor: globals.light ? Colors.green : Colors.green[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.home,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Feed',
            backgroundColor: globals.light ? Colors.redAccent: Colors.red[900],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.add_box,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Add Post',
            backgroundColor: globals.light ? Colors.purple : Colors.purple[700],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.email,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.email,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Messages',
            backgroundColor: globals.light ?  Colors.orange : Colors.orange[900],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings,
              color: globals.light ? AppColors.appTextColor : darkAppColors.postTextColor,
            ),
            activeIcon: Icon(Icons.settings,
              color: globals.light ? AppColors.postTextColor : Colors.white,
            ),
            label: 'Settings',
            backgroundColor: globals.light ?  Colors.pink : Colors.pink[900],
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
