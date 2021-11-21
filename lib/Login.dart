import 'package:flutter/material.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/utils/styles.dart';
import 'package:unite/profile.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';

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
                      hintStyle: AppStyles.hintTextStyle,
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
                      hintStyle: AppStyles.hintTextStyle,
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
                      else if(RegExp("^(?=.{8,32}\$)(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$%^&*(),.?:{}|<>]).*").hasMatch(value)){
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
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All done')),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Profile()),
                        );
                      }
                    },
                    child: Text('Login', style: AppStyles.buttonText,),
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
