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
import 'package:unite/utils/dimensions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'usables/config.dart' as globals;
import 'utils/colors.dart';
import 'utils/styles.dart';

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

class PostScreen extends StatefulWidget {
  @override
  _PostScreen createState() => _PostScreen();
}

class _PostScreen extends State {

  File? _imageFile = null;
  final _user = FirebaseAuth.instance.currentUser;
  String post_message = '';
  String location = '';
  String tags = '';
  final _formKey = GlobalKey<FormState>();
  final _textFormController = TextEditingController();
  final _textFormController2 = TextEditingController();
  final _textFormController3 = TextEditingController();

  final _picker = ImagePicker();

  Future pickImage() async {
    // ignore: deprecated_member_use
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    setState(() {
      _imageFile = File(pickedFile!.path);
    });
  }

  Future uploadPost(uid, like, comment, url, caption) async {

    List tags_list = tags.toLowerCase().split(",");

    final firestoreInstance = FirebaseFirestore.instance;

    List<String> indexList = [];

    for(int i = 1; i <= location.length; i++){
      indexList.add(location.substring(0, i).toLowerCase());
    }

    List<String> indexListCaption = [];

    for(int i = 1; i <= caption.length; i++){
      indexListCaption.add(caption.substring(0, i).toLowerCase());
    }

    firestoreInstance.collection("users").doc(_user!.uid).collection('posts').add(
        {
          "image_url" : url,
          "likeCount" : like,
          "comment" : [],
          "caption": caption,
          "datetime": DateTime.now(),
          "location": location,
          "likedBy": [],
          "sharedFrom": '',
          'location_array' : indexList,
          "owner" : _user!.uid,
          "text_array" : indexListCaption,
          'tags' : tags_list
        }).then((value){
      print(value.id);
    });

  }

  Future uploadImageToFirebase(BuildContext context, caption) async {
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
      url = await value.ref.getDownloadURL(), print(url), uploadPost(_user!.uid, 0, 0, url, caption),
      print("Upload file path ${value.ref.fullPath}"),ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Uploaded to storage"),
      )),
    }).onError((error, stackTrace) => {
      print("Upload file path error ${error.toString()} ")
    });
  }

  BoxDecoration myBoxDecoration() {
    return BoxDecoration(
      border: Border.all(
          width: 3.0
      ),
      borderRadius: BorderRadius.all(
          Radius.circular(30.0) //                 <--- border radius here
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: globals.light ? Colors.white: Colors.grey[700],
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: Stack(
                      children: [
                        Container(
                          decoration: myBoxDecoration(),
                          height: double.infinity,
                          width: double.infinity,
                          margin: const EdgeInsets.only(
                              left: 30.0, right: 30.0, top: 15.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30.0),
                            child: _imageFile != null ?
                            InkWell(onTap: pickImage, child: Image.file(_imageFile!)  ,)
                                : FlatButton(
                              child: Icon(
                                Icons.add_a_photo,
                                color: globals.light ? Colors.lightBlueAccent : Colors.black,
                                size: 50,
                              ),
                              onPressed: pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Expanded(
                      child: TextFormField(
                        controller: _textFormController,
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Write a caption...",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return 'Please enter some text';
                          }
                          else {
                            post_message = value;
                            print(post_message);
                            print('post message yazdirma yeri');
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Expanded(
                      child: TextFormField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        controller: _textFormController2,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Location...",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return null;
                          }
                          else {
                            location = value;
                            //print(post_message);
                            //print('post message yazdirma yeri');
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                    child: Expanded(
                      child: TextFormField(
                        style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                        controller: _textFormController3,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter tags...",
                          hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(5.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == '' || value == null) {
                            return null;
                          }
                          else {
                            tags = value;
                          }
                        },
                      ),
                    ),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                    ),
                    onPressed: () {
                      if(_formKey.currentState!.validate()){
                        if(_imageFile == null){
                          uploadPost(_user!.uid, 0, 0, '', post_message);
                        }
                        else{
                          uploadImageToFirebase(context, post_message);
                        }

                      }
                      _textFormController.clear();
                      _textFormController2.clear();
                      _textFormController3.clear();

                    },
                    child: Text(
                      "Add Post",
                      style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,
                    ),
                  ),
                  SizedBox(height: 15,),
                  //addPostButton(context, post_message),
                ],
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