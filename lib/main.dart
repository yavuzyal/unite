import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
<<<<<<< Updated upstream
=======
import 'package:unite/usables/config.dart' as globals;
import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
>>>>>>> Stashed changes
import 'package:unite/profile.dart';
import 'package:unite/utils/post_page.dart';
import 'utils/post.dart';
import 'Greeting.dart';


void main() {
  runApp(MaterialApp(
    //home: ProfileView(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/profile',
    routes: {
      '/login': (context) => LoginPage(),
      '/main': (context) => MainPage(),
      '/register': (context) => RegisterPage(),
      '/greeting': (context) => Greeting(),
<<<<<<< Updated upstream
=======
      '/settings': (context) => Settings(),
      '/pageOne': (context) => LoginPage(),
>>>>>>> Stashed changes
      '/profile': (context) => Profile(),
    },
  ));
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPage2();
}

<<<<<<< Updated upstream
class _MainPage2 extends State<MainPage> {
=======
/// This is the private State class that goes with MyStatefulWidget.
class _MainPageState extends State<MainPage> {

  static _MainPageState instance = new _MainPageState();
  _MainPageState();

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

>>>>>>> Stashed changes
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"), centerTitle: true, backgroundColor: Colors.lightBlueAccent, automaticallyImplyLeading: true,
        leading: IconButton(icon: Icon(Icons.email), onPressed: () {  },), backwardsCompatibility: true,
      ),
<<<<<<< Updated upstream
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        children: const <Widget>[
          Center(
            child: Text('First Page'),
=======
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.shifting,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Profile',
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
>>>>>>> Stashed changes
          ),
          Center(
            child: Text('Second Page'),
          ),
          Center(
            child: Text('Third Page'),
          )
        ],
      )
    );
  }
}
