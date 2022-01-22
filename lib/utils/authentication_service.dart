import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthenticationService{

  final FirebaseAuth _firebaseAuth;

  AuthenticationService(this._firebaseAuth);

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future <String?> signIn({required String email, required String password}) async{
    try{
      await _firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
      return "Signed In";
    }
    on FirebaseAuthException catch(e){
      return e.message;
    }
  }


  Future <String?> signUp({required String email, required String password})async {
    try{
      await _firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);

      final _user = _firebaseAuth.currentUser;

      List<String> indexList = [];

      String name = _user!.displayName.toString().toLowerCase().trim();

      for(int i = 1; i <= name.length; i++){
        indexList.add(name.substring(0, i).toLowerCase());
      }

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).set({
        'username' : name,
        'searchKey': indexList,
        'userId': _user!.uid,
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

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('bookmarks').add({});


      return "Signed In";
    }
    on FirebaseAuthException catch(e){
      return e.message;
    }
  }

}


class Authentication {
  Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
    await googleSignIn.signIn();

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
      await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
        await auth.signInWithCredential(credential);

        user = userCredential.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        }
        else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }

    return user;
  }
}