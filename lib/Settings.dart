import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:unite/utils/styles.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';

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

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";

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
    return Scaffold(
      backgroundColor: globals.light ? Colors.white: Colors.black,
      body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
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
                    SizedBox(height: 10.0,),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(minimumSize: Size(150, 50), primary: Colors.lightBlue),
                      //ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck), ),
                      onPressed: () {
                        setLogOut();
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LoginPage()),
                        );
                      },
                      child: Text('Log Out', style: TextStyle(fontSize: 20, ),),
                    ),
                  ],
                ),
              ),
            ),
          )
      ),
    );

  }
}
