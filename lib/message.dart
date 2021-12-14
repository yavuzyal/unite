import 'dart:html';

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

class Message extends StatefulWidget {
  @override
  State<Message> createState() => _Message();
}

class _Message extends State<Message> {

  String message = '';
  final _formKey = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Messages'),
        centerTitle: true,
      ),
      body: Center(
          child: Padding(
            padding: AppDimensions.padding20,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 500.0,  //buraya ekranın 3/4'ü gibi bir size koy
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
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
                            if (value != '' || value != null) {
                              message = value!;
                            }
                            else {
                              return 'Cannot send an empty message :(';
                            }
                            return null;
                          },

                        ),
                        SizedBox(width: 20.0,),
                        ElevatedButton.icon(
                            onPressed: (){
                              //send message implementation
                            },
                            icon: Icon(Icons.arrow_forward),
                            label: Text('Send Message'))
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
