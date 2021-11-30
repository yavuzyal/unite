import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/main.dart';
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
    await prefs.setBool('loggedIn', true);
    await prefs.setString('email', email!);
    await prefs.setString('password', password!);
  }

  final _formKey = GlobalKey<FormState>();
  String? email = "";
  String? password = "";
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$');


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
    return new WillPopScope(
        onWillPop: () async => false,
        child: Scaffold(
          body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
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
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            hintText: "Enter Email",
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
                          style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck)),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Login Successful')),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => MainPage()),
                              );
                              setLoggedIn();
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
        ),
    );
  }
}