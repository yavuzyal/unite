import 'package:flutter/material.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/utils/styles.dart';
import 'package:unite/usables/config.dart' as globals;
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'package:flutter/material.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/utils/styles.dart';
import 'package:unite/profile.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'package:unite/main.dart';

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPage2();
}

class _LoginPage2 extends State<LoginPage> {

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
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Email",
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
                        else {
                          email = value;
                        }
                        return null;
                      },

                    ),
                    SizedBox(height: 20.0,),
                    TextFormField(
                      obscureText: true,
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Password",
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
                        else if (value.length < 6){
                          return 'Password length cannot be less than 6 characters';
                        }
                        else if(RegExp("r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}\$").hasMatch(value)){
                          return 'error';
                        }
                        else{
                          password = value;
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20.0,),
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pushReplacement(new PageRouteBuilder(
                          maintainState: true,
                          opaque: true,
                          pageBuilder: (context, _, __) => new MainPage(),
                          transitionDuration: const Duration(milliseconds: 30),
                          transitionsBuilder: (context, anim1, anim2, child) {
                          return new FadeTransition(
                          child: child,
                          opacity: anim1,
                          );
                          }));
                          }
                      },
                      child: const Text('Login', style: TextStyle(fontSize: 16),),
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
    );

  }
}