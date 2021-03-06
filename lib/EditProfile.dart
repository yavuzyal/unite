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
import 'package:unite/profile.dart';
import 'package:unite/utils/colors.dart';
import 'package:unite/utils/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usables/config.dart' as globals;
import 'utils/styles.dart';
import 'utils/colors.dart';
import 'Settings.dart';

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
  String username = '';
  final _formKey = GlobalKey<FormState>();

  final _picker = ImagePicker();
  File? _imageFile = null;

  Future pickImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      pickedFile != null ? _imageFile = File(pickedFile!.path) : _imageFile = null;
    });
  }

  Future<bool> alreadyTaken(String username) async{
    QuerySnapshot snap = await FirebaseFirestore.instance.collection('users').where('username', isEqualTo: username).get();

    if(snap.docs.isNotEmpty){
      return true;
    }

    return false;
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_imageFile!.path);
    firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance.ref().child('posts').child(_user!.uid).child('/$fileName');

    var url;

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;

    uploadTask =  ref.putFile(io.File(_imageFile!.path)!, metadata);

    firebase_storage.UploadTask task = await Future.value(uploadTask);
    Future.value(uploadTask).then((value) async => {
      url = await value.ref.getDownloadURL(), print(url), uploadProfile(username, school, major, age, interest, bio, url),//addUserId(),
      print("Upload file path ${value.ref.fullPath}"),ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Uploaded to storage"),
      )),
    }).onError((error, stackTrace) => {
      print("Upload file path error ${error.toString()} ")
    });
  }

  User_info user_profile = new User_info('','','','','','');

  Future uploadProfile(String username, school, major, age, interest, bio, profile_pic) async {

    final firestoreInstance = FirebaseFirestore.instance;

    DocumentSnapshot mes = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

    List<String> indexList = [];
    for(int i = 1; i <= username.length; i++){
      indexList.add(username.substring(0, i).toLowerCase());
    }

    String name = mes.get('username');
    List key = mes.get('searchKey');

    user_profile = User_info(mes.get('school'), mes.get('major'), mes.get('age'), mes.get('interest'), mes.get('bio'), mes.get('profile_pic'));

    await FirebaseFirestore.instance.collection("users").doc(_user!.uid ).update(
        {
          'username' : username == "" ? name : username,
          'searchKey': indexList.isEmpty ? key : indexList,
          'userId': _user!.uid,
          "school" : (school == '') ? user_profile.school : school,
          "major" : (major == '') ? user_profile.major : major,
          "age" : (age == '') ? user_profile.age : age,
          "interest": (interest == '') ? user_profile.interest : interest,
          "bio": (bio == '') ? user_profile.bio : bio,
          "profile_pic": (profile_pic == '') ? user_profile.profile_pic : profile_pic,
        }).then((value){
      //print(value.id);
    });

    QuerySnapshot query = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('messages').get();

    List userIds = [];

    for(var i in query.docs){
      userIds.add(i.id);
    }

    for(int i=0; i < userIds.length; i++){
      await FirebaseFirestore.instance.collection('users').doc(userIds[i]).collection('messages').doc(_user!.uid).update({
        'userName' : username == "" ? name : username,
        "profile_pic": (profile_pic == '') ? user_profile.profile_pic : profile_pic,
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.light ? Colors.white: Colors.grey[700],
      appBar: AppBar(
        backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
        title: const Text('Edit profile'), centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Padding(
                padding: AppDimensions.padding20,
                child:SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: (){
                          pickImage();
                        },
                        child: CircleAvatar(
                          backgroundColor: globals.light ? AppColors.logoColor : darkAppColors.logoColor,
                          child: ClipOval(
                            child: _imageFile == null ? Image.asset('assets/usericon.png') : Image.file(_imageFile!),
                          ),
                          radius: 70,
                        ),
                      ),
                      SizedBox(height: 20,),
                      TextFormField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Username",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(0.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                          if(value!.isEmpty || value == ''){
                            username = '';
                          }
                          else
                            username = value!;
                        },
                      ),
                      SizedBox(height: 10,),
                      TextFormField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Your University",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
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
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Your Major",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
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
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Your Age",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
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
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Your Interests",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
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
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Your Bio",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
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
                        style: ButtonStyle(
                          backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                        ),
                        onPressed: () {
                          if(_formKey.currentState!.validate()){

                            alreadyTaken(username).then((res) async {
                              if(res){
                                return showDialog(
                                    context: context,
                                    builder: (context){
                                      return AlertDialog(
                                        title: Text('Username already taken!'),
                                        content: Text('Please select another one!'),
                                      );
                                    });
                              }
                              else {
                                if(_imageFile == null){
                                  uploadProfile(username,school,major,age,interest,bio,'');
                                  Navigator.pop(context);
                                }
                                else{
                                  uploadImageToFirebase(context);
                                  Navigator.pop(context);
                                }

                                setState(() {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Profile Updated')),
                                  );
                                }
                                );
                              }
                            });
                          }
                        },
                        child: Text(
                          "Update Profile",
                          style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,
                        ),
                      ),
                      //addPostButton(context, post_message),
                    ],
                  ),
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