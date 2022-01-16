import 'dart:io';
import 'dart:io' as io;
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart' as firebase_core;
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:unite/LoggedIn.dart';
import 'package:unite/utils/colors.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class changePassword extends StatefulWidget {
  const changePassword({Key? key}) : super(key: key);

  @override
  _changePasswordState createState() => _changePasswordState();
}

Future validate(String email, String currentPass, String newPass, context) async{

  final cred = await EmailAuthProvider.credential(email: email, password: currentPass);

  _user!.reauthenticateWithCredential(cred).then((value) {
    _user!.updatePassword(newPass).then((_) {
      error_text = "Password successfully updated";
    }).catchError((error) {
      error_text = "Password could not be updated";
    });
  }).catchError((err) {
    print("AAA");
    error_text = "Incorrect email or password";
  });
  error_text = "Password successfully updated";
}

final _formKey = GlobalKey<FormState>();
final _user = FirebaseAuth.instance.currentUser;
String current_pass = '';
String email = '';
String new_pass = '';
RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$');
String error_text = '';

class _changePasswordState extends State<changePassword> {
  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar:
        AppBar(
        ),
        body: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 20),
              child: Form(
                key: _formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: [Flexible(
                    child: Padding(
                      padding: AppDimensions.padding20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 20,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            decoration: new InputDecoration(
                              hintText: "Enter email",
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
                          SizedBox(height: 10,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            obscureText: true,
                            decoration: new InputDecoration(
                              hintText: "Enter your current password",
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
                              else if (value.length < 8){
                                return 'Password length cannot be less than 8 characters';
                              }
                              else if(!regex.hasMatch(value)){
                                return 'Password should include an uppercase letter, a lowercase\n  letter, one digit and a special character';
                              }
                              else{
                                current_pass = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            obscureText: true,
                            decoration: new InputDecoration(
                              hintText: "Enter new password",
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
                              else if (value.length < 8){
                                return 'Password length cannot be less than 8 characters';
                              }
                              else if(!regex.hasMatch(value)){
                                return 'Password should include an uppercase letter, a lowercase\n  letter, one digit and a special character';
                              }
                              else{
                                new_pass = value;
                              }
                            },
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            obscureText: true,
                            decoration: new InputDecoration(
                              hintText: "Enter new password again",
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
                              else if (value != new_pass){
                                return 'Passwords don\'t match';
                              }
                            },
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {

                                await validate(email, current_pass, new_pass, context);
                                SnackBar snack = SnackBar(content: Text(error_text));
                                ScaffoldMessenger.of(context).showSnackBar(snack);

                              }
                            },
                            child: Text(
                              "Update Profile",
                              style: TextStyle(fontSize: 20, color: Colors.white),
                            ),
                          ),
                          //addPostButton(context, post_message),
                        ],
                      ),
                    ),
                  ),
                ],
                ),
              ),
            ),
          ],
        ),
      );
  }
}
