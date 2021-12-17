import 'dart:io';
import 'dart:io' as io;
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

class Post {
  late final image;
  late final uid;
  late final likes;
  late final num_of_comments;

  constructor (uid, image, likes, num_of_comments ) {
    this.uid = uid;
    this.image = image;
    this.likes = likes;
    this.num_of_comments = num_of_comments;
  }
  toString() {
    return this.uid + ', ' + this.image + ', ' + this.likes + ', ' + this.num_of_comments;
  }
}

final Color green = Colors.brown;
final Color orange = Colors.brown;

class EditProfile extends StatefulWidget {
  @override
  _EditProfile createState() => _EditProfile();
}

class User_info {
  String school = '';
  String major = '';
  String age = '';
  String interest = '';
  String bio = '';
  String profile_pic = '';

  User_info(this.school, this.major, this.age, this.interest, this.bio, this.profile_pic);
}

class _EditProfile extends State {

  final _user = FirebaseAuth.instance.currentUser;
  String school = '';
  String major = '';
  String age = '';
  String interest = '';
  String bio = '';
  final _formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();
  File? _imageFile = null;

  Future pickImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_imageFile!.path);
    firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance
        .ref().child('posts').child(_user!.uid).child('/$fileName');

    var url;

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;
    //late StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);

    //TaskSnapshot taskSnapshot = await ref.putFile(io.File(_imageFile!.path)!, metadata);

    //final String downloadUrl = await taskSnapshot.ref.getDownloadURL();

    uploadTask =  ref.putFile(io.File(_imageFile!.path)!, metadata);

    firebase_storage.UploadTask task = await Future.value(uploadTask);
    Future.value(uploadTask).then((value) async => {
      url = await value.ref.getDownloadURL(), print(url), uploadProfile(school, major, age, interest, bio, url),
      print("Upload file path ${value.ref.fullPath}"),ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Uploaded to storage"),
      )),
    }).onError((error, stackTrace) => {
      print("Upload file path error ${error.toString()} ")
    });
  }

  User_info user_profile = new User_info('','','','','','');

  Future uploadProfile(school, major, age, interest, bio, profile_pic) async {

    final firestoreInstance = FirebaseFirestore.instance;

    QuerySnapshot profile_info = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('profile_info').get();

    if(profile_info.docs.isEmpty){
      firestoreInstance.collection("users").doc(_user!.uid ).collection('profile_info').add(    //.add(
          {
            "school" : school,
            "major" : major,
            "age" : age,
            "interest": interest,
            "bio": bio,
            "profile_pic": profile_pic,
          }).then((value){
        //print(value.id);
      });
    }

    else{
      for(var mes in profile_info.docs){
          user_profile = User_info(mes.get('school'), mes.get('major'), mes.get('age'), mes.get('interest'), mes.get('bio'), mes.get('profile_pic'));

          firestoreInstance.collection("users").doc(_user!.uid ).collection('profile_info').doc(mes.id).update(    //.add(
              {
                "school" : (school == '') ? user_profile.school : school,
                "major" : (major == '') ? user_profile.major : major,
                "age" : (age == '') ? user_profile.age : age,
                "interest": (interest == '') ? user_profile.interest : interest,
                "bio": (bio == '') ? user_profile.bio : bio,
                "profile_pic": (profile_pic == '') ? user_profile.profile_pic : profile_pic,
              }).then((value){
            //print(value.id);
          });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: AppDimensions.padding20,
                child:Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: (){
                        pickImage();
                      },
                      child: CircleAvatar(
                        backgroundColor: AppColors.logoColor,
                        child: ClipOval(
                          child: _imageFile == null ? Image.asset('assets/usericon.png') : Image.file(_imageFile!),
                          //Image.network('https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg', fit: BoxFit.cover,),
                        ),
                        radius: 70,
                      ),
                    ),
                    SizedBox(height: 20,),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Your University",
                        fillColor: Colors.black,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(0.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty || value == ''){
                          school = '';
                        }
                        else
                          school = value!;
                      },
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Your Major",
                        fillColor: Colors.black,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(0.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty || value == ''){
                          major = '';
                        }
                        else
                          major = value!;
                      },
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Your Age",
                        fillColor: Colors.black,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(0.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty || value == ''){
                          age = '';
                        }
                        else
                          age = value!;
                      },
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Your Interests",
                        fillColor: Colors.black,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(0.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty || value == ''){
                          interest = '';
                        }
                        else
                          interest = value!;
                      },
                    ),
                    SizedBox(height: 10,),
                    TextFormField(
                      textAlign: TextAlign.center,
                      decoration: new InputDecoration(
                        hintText: "Enter Your Bio",
                        fillColor: Colors.black,
                        border: new OutlineInputBorder(
                          borderRadius: new BorderRadius.circular(0.0),
                          borderSide: new BorderSide(),
                        ),
                      ),
                      validator: (String? value) {
                        if(value!.isEmpty || value == ''){
                          bio = '';
                        }
                        else
                          bio = value!;
                      },
                    ),
                    SizedBox(height: 10,),
                    ElevatedButton(
                      onPressed: () {
                        if(_formKey.currentState!.validate()){

                          if(_imageFile == null){
                            uploadProfile(school,major,age,interest,bio,'');
                          }
                          else{
                            uploadImageToFirebase(context);
                          }
                          
                          setState(() {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Profile Updated')),
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => LoggedIn()),
                            );
                          });
                        }
                      },
                      child: Text(
                        "Update Profile",
                        style: TextStyle(fontSize: 20,color: Colors.white),
                      ),
                    ),
                    //addPostButton(context, post_message),
                  ],
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}
/*
if request.auth != null*/