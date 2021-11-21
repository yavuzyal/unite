import 'package:flutter/material.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/usables/config.dart';
import 'package:unite/utils/styles.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';

class Settings extends StatefulWidget {
  @override
  State<Settings> createState() => _LoginPage2();
}

class _LoginPage2 extends State<Settings> {

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
                    ElevatedButton(
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith(buttonColorCheck)),
                      onPressed: () {
                        setState(() {
                          currentTheme.switchTheme();
                        });
                      },
                      child: const Text('Dark Mode', style: TextStyle(fontSize: 20, ),),
                    ),
                    SizedBox(height: 10.0,),
                  ],
                ),
              ),
            ),
          )
      ),
    );

  }
}
