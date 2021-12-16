// ignore_for_file: non_constant_identifier_names

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unite/Login.dart';
import 'package:unite/RegisterPage.dart';
import 'package:unite/google_sign_in.dart';
import 'package:unite/usables/config.dart' as globals;
import 'package:unite/utils/dimensions.dart';
import 'package:unite/utils/styles.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class Message extends StatefulWidget {
  @override
  State<Message> createState() => _Message();
}



class _Message extends State<Message> {

  final _formKey = GlobalKey<FormState>();
  String message = "";


  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.light ? Colors.white: Colors.black,
      body: Center(
          child: Padding(
            padding: AppDimensions.padding20,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height / 2,
                    child: SingleChildScrollView(

                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: TextFormField(
                          textAlign: TextAlign.center,
                          decoration: new InputDecoration(
                            hintText: "Enter Your Message",
                            fillColor: Colors.black,
                            border: new OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(0.0),
                              borderSide: new BorderSide(),
                            ),
                          ),
                          validator: (String? value) {
                            if (value == null || value.isEmpty || value == '') {
                              return 'Cannot send empty message :(';
                            }
                            else {
                              message = value;
                            }
                            return null;
                          },

                        ),),
                      ElevatedButton.icon(
                          onPressed: () async {

                          },
                          icon: Icon(Icons.local_post_office),
                          label: Text('Send Message'))
                    ],
                  ),
                ],
              ),
            ),
          )
      ),
    );

  }
}
