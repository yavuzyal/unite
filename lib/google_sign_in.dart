

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInProvider extends ChangeNotifier{

  final googleSignIn = GoogleSignIn();

  GoogleSignInAccount ? _user;

  GoogleSignInAccount get user => _user!;

  Future googleLogin() async{
    final googleUser = await googleSignIn.signIn();

    if(googleUser == null)return;
    _user = googleUser;

    final googleAuth = await googleUser.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    await FirebaseAuth.instance.signInWithCredential(credential);

    QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').get();

    final currentUserId = FirebaseAuth.instance.currentUser!.uid;

    if(!snap.docs.contains(currentUserId)){

      List<String> indexList = [];

      String name = FirebaseAuth.instance.currentUser!.displayName.toString().toLowerCase();

      name = name.replaceAll(' ', '');

      for(int i = 1; i <= name.length; i++){
        indexList.add(name.substring(0, i));
      }

      await FirebaseFirestore.instance.collection('users').doc(currentUserId).set({
        'username' : name,
        'searchKey': indexList,
        'userId': currentUserId,
        'isPrivate': 'public',
        'followers': [],
        'followerCount': 0,
        'following': [],
        'followingCount': 0,
        "school" : '',
        "major" : '',
        "age" : '',
        "interest": '',
        "bio": '',
        "profile_pic": '',
        'follow_requests': '',
        'bookmarks' : []
      });
    }

    notifyListeners();
  }

  Future googleLogout() async {
    await googleSignIn.disconnect();
    await FirebaseAuth.instance.signOut();
  }
}