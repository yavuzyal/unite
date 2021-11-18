import 'package:flutter/material.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';

import 'Greeting.dart';


void main() {
  runApp(MaterialApp(
    //home: ProfileView(),
    debugShowCheckedModeBanner: false,
    initialRoute: '/greeting',
    routes: {
      '/login': (context) => LoginPage(),
      '/main': (context) => MainPage(),
      '/register': (context) => RegisterPage(),
      '/greeting': (context) => Greeting(),
    },
  ));
}

class MainPage extends StatefulWidget {
  @override
  State<MainPage> createState() => _MainPage2();
}

class _MainPage2 extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return Scaffold(
      appBar: AppBar(
        title: Text("Main Page"), centerTitle: true, backgroundColor: Colors.lightBlueAccent, automaticallyImplyLeading: true,
        leading: IconButton(icon: Icon(Icons.email), onPressed: () {  },), backwardsCompatibility: true,
      ),
      body: PageView(
        scrollDirection: Axis.horizontal,
        controller: controller,
        children: const <Widget>[
          Center(
            child: Text('First Page'),
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
