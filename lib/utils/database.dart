import 'dart:html';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService{

  final String uid;
  DatabaseService({required this.uid});

  final CollectionReference users = FirebaseFirestore .instance.collection('users');

  Future<void> addUser() {
    // Call the user's CollectionReference to add a new user
    return users
        .add({
      'uid': uid,
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

}