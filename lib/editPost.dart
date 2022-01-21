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
import 'package:unite/utils/styles.dart';
import 'usables/config.dart' as globals;
import 'utils/post.dart';

class editPost extends StatefulWidget {

  editPost({Key? key, required this.post}) : super(key: key);

  Post post;

  @override
  _editPostState createState() => _editPostState();
}



Future validate(String new_caption, String new_location, String new_image_url, String new_tags, Post post, context) async{

  final firestoreInstance = FirebaseFirestore.instance;

  DocumentSnapshot info1 = await firestoreInstance.collection('users').doc(post.owner).collection('posts').doc(post.postId).get();

  String caption = info1.get('caption');
  String image_url = info1.get('image_url');
  String location = info1.get('location');
  List tags_list = info1.get('tags');

  if(new_caption != '' && new_caption != caption){

    List<String> indexListCaption = [];

    for(int i = 1; i <= new_caption.length; i++){
      indexListCaption.add(new_caption.substring(0, i).toLowerCase());
    }
    await FirebaseFirestore.instance.collection('users').doc(
        post.owner).collection('posts').doc(post.postId).update(
        {
          'caption' : new_caption,
          'text_array' : indexListCaption,
        });

    error_text = "Post edited";
  }

  if(new_location != '' && new_location != location){

    List<String> indexList = [];

    for(int i = 1; i <= new_location.length; i++){
      indexList.add(new_location.substring(0, i).toLowerCase());
    }

    await FirebaseFirestore.instance.collection('users').doc(
        post.owner).collection('posts').doc(post.postId).update(
        {
          'location' : new_location,
          'location_array' : indexList,
        });
    error_text = "Post edited";

  }

  if(new_image_url != '' && new_image_url != image_url){

    await FirebaseFirestore.instance.collection('users').doc(
        post.owner).collection('posts').doc(post.postId).update(
        {
          'image_url' : new_image_url,
        });
    error_text = "Post edited";
  }

  List new_tags_list = new_tags.toLowerCase().split(",");

  if(new_tags_list.isNotEmpty && new_tags_list != tags_list){

    await FirebaseFirestore.instance.collection('users').doc(
        post.owner).collection('posts').doc(post.postId).update(
        {
          'tags' : new_tags_list,
        });
    error_text = "Post edited";
  }
}

final _formKey = GlobalKey<FormState>();
final _user = FirebaseAuth.instance.currentUser;
final _picker = ImagePicker();
File? _imageFile = null;
String new_caption = '';
String new_location = '';
String new_image_url = '';
String error_text = '';
String new_tags = '';

class _editPostState extends State<editPost> {
  Future pickImage() async {

    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      pickedFile != null ? _imageFile = File(pickedFile!.path) : _imageFile = null;
    });
  }

  Future uploadImageToFirebase(BuildContext context) async {
    String fileName = basename(_imageFile!.path);
    firebase_storage.Reference ref =
    firebase_storage.FirebaseStorage.instance.ref().child('posts').child(_user!.uid).child('/$fileName');

    var new_image_url;

    final metadata = firebase_storage.SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {'picked-file-path': fileName});
    firebase_storage.UploadTask uploadTask;

    uploadTask =  ref.putFile(io.File(_imageFile!.path)!, metadata);

    firebase_storage.UploadTask task = await Future.value(uploadTask);
    Future.value(uploadTask).then((value) async => {
      new_image_url = await value.ref.getDownloadURL(), print(new_image_url), validate(new_caption, new_location, new_image_url, new_tags, widget.post, context),
        print("Upload file path ${value.ref.fullPath}"),ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Uploaded to storage"),
      )),
    }).onError((error, stackTrace) => {
      print("Upload file path error ${error.toString()} ")
    });
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: globals.light ? Colors.white: Colors.grey[700],
        appBar:
        AppBar(
          backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
          title: const Text('Edit post'), centerTitle: true,
        ),
        body: Stack(
          children: [
            Container(
              child: Form(
                key: _formKey,
                child: Flex(
                  direction: Axis.vertical,
                  children: [Flexible(
                    child: Padding(
                      padding: EdgeInsets.all(8),
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
                            textAlign: TextAlign.center,
                            style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                            decoration: new InputDecoration(
                              hintText: "Enter new caption",
                              hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                              fillColor: Colors.black,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                            validator: (String? value) {
                                 value != null ? new_caption = value : new_caption = '';
                              return null;
                            },
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            obscureText: false,
                            style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                            decoration: new InputDecoration(
                              hintText: "Enter new location",
                              hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                              fillColor: Colors.black,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                            validator: (String? value) {
                              value != null ? new_location = value : new_location = '';
                              return null;
                            },
                          ),
                          SizedBox(height: 10,),
                          TextFormField(
                            textAlign: TextAlign.center,
                            style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                            decoration: new InputDecoration(
                              hintText: "Enter new tags",
                              hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                              fillColor: Colors.black,
                              border: new OutlineInputBorder(
                                borderRadius: new BorderRadius.circular(0.0),
                                borderSide: new BorderSide(),
                              ),
                            ),
                            validator: (String? value) {
                              value != null ? new_tags = value : new_tags = '';
                              return null;
                            },
                          ),
                          SizedBox(height: 10,),
                          ElevatedButton(
                            style: ButtonStyle(
                              backgroundColor: globals.light ? MaterialStateProperty.all<Color>(AppColors.logoColor) : MaterialStateProperty.all<Color>(darkAppColors.logoColor),
                            ),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                if(_imageFile == null){
                                  validate(new_caption, new_location, new_image_url, new_tags, widget.post, context);
                                  Navigator.pop(context);
                                }
                                else{
                                  uploadImageToFirebase(context);
                                  Navigator.pop(context);
                                }
                                SnackBar snack = SnackBar(content: Text(error_text));
                                ScaffoldMessenger.of(context).showSnackBar(snack);
                              }
                            },
                            child: Text(
                              "Edit post",
                              style: globals.light ? AppStyles.buttonText :  darkAppStyles.buttonText,
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
