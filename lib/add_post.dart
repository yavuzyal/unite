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
import 'package:unite/utils/dimensions.dart';



final Color green = Colors.brown;
final Color orange = Colors.brown;

class UploadingImageToFirebaseStorage extends StatefulWidget {
  @override
  _UploadingImageToFirebaseStorageState createState() =>
      _UploadingImageToFirebaseStorageState();
}

class _UploadingImageToFirebaseStorageState extends State {

  File? _imageFile = null;
  final _user = FirebaseAuth.instance.currentUser;
  String post_message = '';

  ///NOTE: Only supported on Android & iOS
  ///Needs image_picker plugin {https://pub.dev/packages/image_picker}
  final _picker = ImagePicker();

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

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;
    //late StorageUploadTask uploadTask = firebaseStorageRef.putFile(_imageFile);
    uploadTask = ref.putFile(io.File(_imageFile!.path)!, metadata);

    firebase_storage.UploadTask task= await Future.value(uploadTask);
    Future.value(uploadTask).then((value) => {
      print("Upload file path ${value.ref.fullPath}"),ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text("Post Uploaded :)"),
    )),
    }).onError((error, stackTrace) => {
      print("Upload file path error ${error.toString()} ")
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 20),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Text(
                      "Select an image to add",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 28,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.0),
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        height: double.infinity,
                        margin: const EdgeInsets.only(
                            left: 30.0, right: 30.0, top: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(30.0),
                          child: _imageFile != null ?
                              InkWell(onTap: pickImage, child: Image.file(_imageFile!)  ,)
                              : FlatButton(
                            child: Icon(
                              Icons.add_a_photo,
                              color: Colors.lightBlueAccent,
                              size: 50,
                            ),
                            onPressed: pickImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Padding(
                  padding: AppDimensions.padding20,
                child: Expanded(
                  child: TextFormField(
                    textAlign: TextAlign.center,
                    decoration: new InputDecoration(
                      hintText: "Write a caption...",
                      fillColor: Colors.black,
                      border: new OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(0.0),
                        borderSide: new BorderSide(),
                      ),
                    ),
                    validator: (String? value) {
                      if (value == '' || value == null) {
                        return 'Please enter some text';
                      }
                      else {
                        post_message = value;
                      }
                      return null;
                    },
                  ),
                ),),

                addPostButton(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addPostButton(BuildContext context) {
    return Container(
      child: Stack(
        children: [
          Container(
            padding:
            const EdgeInsets.symmetric(vertical: 5.0, horizontal: 16.0),
            margin: const EdgeInsets.only(
                top: 0, left: 20.0, right: 20.0, bottom: 20.0),
            decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [orange, green],
                ),
                borderRadius: BorderRadius.circular(30.0)),
            child: FlatButton(
              onPressed: () => uploadImageToFirebase(context),
              child: Text(
                "Add Post",
                style: TextStyle(fontSize: 20,color: Colors.white),
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