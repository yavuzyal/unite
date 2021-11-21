import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/usables/config.dart';

import 'Greeting.dart';
import 'Settings.dart';


void main() {
  runApp(MaterialApp(
    //home: ProfileView(),
    theme: ThemeData.light(),
    darkTheme: ThemeData.dark(),
    themeMode: currentTheme.currentTheme(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/greeting',
    routes: {
      '/login': (context) => LoginPage(),
      '/main': (context) => MainPage(),
      '/register': (context) => RegisterPage(),
      '/greeting': (context) => Greeting(),
      '/settings': (context) => Settings(),
    },
  ));
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

/// This is the private State class that goes with MyStatefulWidget.
class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;
  static const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Home',
      style: optionStyle,
    ),
    Text(
      'Index 1: Business',
      style: optionStyle,
    ),
    Text(
      'Index 2: School',
      style: optionStyle,
    ),
    Text(
      'Index 3: Settings',
      style: optionStyle,
    ),
    Settings(),
  ];

  void initState(){
    super.initState();
    currentTheme.addListener(() {
      print("Changes");
      setState(() {
        currentTheme.switchTheme();
      });
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UNIte'), centerTitle: true, actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.email,
            color: Colors.white,
          ),
          onPressed: () {
            // do something
          },
        )
      ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Account',
            backgroundColor: Colors.lightBlueAccent,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Bu ne yaw',
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
