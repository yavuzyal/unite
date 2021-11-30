import 'dart:async';
import 'package:after_layout/after_layout.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/main.dart';

import 'package:unite/profile.dart';
import 'Walkthrough.dart';

import 'utils/styles.dart';
import 'Login.dart';

class Greeting extends StatefulWidget {
  @override
  _GreetingState createState() => new _GreetingState();
}

class _GreetingState extends State<Greeting> {
  @override
  initState() {
    super.initState();
    new Timer(const Duration(seconds: 2), checkFirstSeen);
  }

  Future checkFirstSeen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //await prefs.clear();    //TO CHECK THE FIRST TIME OPENING
    bool _seen = (prefs.getBool('seen') ?? false);
    print(_seen);

    //await prefs.clear();    //TO CHECK THE FIRST TIME OPENING
    bool _loggedIn = (prefs.getBool('loggedIn') ?? false);
    print(_loggedIn);

    if (_seen) {
      if(!_loggedIn){
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      }
      else{
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MainPage()),
        );
      }
    } else {
      await prefs.setBool('seen', true);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => WalkthroughScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Align(
          alignment: FractionalOffset.center,
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Image.asset(
                'assets/unite_logo.png',
                height: 250.0,
                width: 250.0,
              ),
              SizedBox(height: 25,),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'UNIte',
                    textStyle: AppStyles.colorizeTextStyle,
                    colors: AppStyles.colorizeColors,
                  ),
                ],
                isRepeatingAnimation: false,
                onTap: () {
                  print("Tap Event");
                },
              ),
            ],
          )),
    );
  }

  void onClose() {

    Navigator.of(context).pushReplacement(new PageRouteBuilder(
        maintainState: true,
        opaque: true,
        pageBuilder: (context, _, __) => new MainPage(),
        transitionDuration: const Duration(seconds: 2),
        transitionsBuilder: (context, anim1, anim2, child) {
          return new FadeTransition(
            child: child,
            opacity: anim1,
          );
        }));


    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WalkthroughScreen()),
    );
  }
}