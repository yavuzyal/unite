import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'post.dart';
import 'styles.dart';
import 'colors.dart';
import 'package:unite/usables/config.dart' as globals;

class PostPage extends StatefulWidget {

  final Post post;
  String userId;
  PostPage({required this.post, required this.userId});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  List<Card> CommentCards = [];
  Map<String, String> withUsername = {};
  Map<String, String> checkName = {};


  Future<bool> MappingOperation() async {

    for(int i = 0; i < widget.post.comments.length; i++){

      String user = widget.post.comments[i].toString().substring(0, 28);
      String comment = widget.post.comments[i].toString().substring(28);

      DocumentSnapshot thisUser =  await FirebaseFirestore.instance.collection('users').doc(user).get();

      String username = thisUser.get('username');

      if(checkName.containsKey(username)){
        Random random = new Random();
        int randomNumber = random.nextInt(900)+100;
        String newName = randomNumber.toString() + username;
        withUsername[newName] = comment;
      }
      else{
        String newName = '007' + username;
        checkName[username] = comment;
        withUsername[newName] = comment;
      }
    }

    withUsername.forEach((user,comment) => CommentCards.add(
      Card(
        color: AppColors.postBackgroundColor,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: Text(user.substring(3), style: AppStyles.commentName,)),
              SizedBox(width: 10),
              Expanded(child: Text(comment, style: AppStyles.commentName,)),
            ],
          ),
        ),
      ),
    ),
    );
    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();


    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');

    print("aaaa");

    tags = liked.get('tags');

    print(tags);

    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;

  }

  Future onPostComment() async{

    DocumentSnapshot<Map<String, dynamic>> comments = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfComments = [];

    //print(comments.data()!.cast().values.toList());

    print(comments.get('comment'));

    listOfComments = comments.get('comment');

    listOfComments.add(_user!.uid + comment);

    await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).update({
      'comment': listOfComments,
    });

    final firestoreInstance = FirebaseFirestore.instance;
    DocumentSnapshot info = await firestoreInstance.collection('users').doc(_user!.uid).get();

    firestoreInstance.collection("users").doc(widget.post.owner).collection('notifications').add(
        {
          'message' : 'You received a comment from ${info['username']}: \"${comment}\"',
          'datetime': DateTime.now(),
          'url' : widget.post.image_url,
          'uid': _user!.uid,
          'follow_request': 'no',
        });

  }

  Future <bool> alreadyLiked() async {


    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async{

    bool success = false;
    
    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      setState(() {
        widget.post.likeCount = widget.post.likeCount + 1;
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('notifications').add({
        'message' : 'You Received a Like!',
        'datetime': DateTime.now(),
        'url' : widget.post.image_url,
        'uid': _user!.uid,
        'follow_request': 'no',
      });
      return success;
    }

    else{
      listOfLikes.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount - 1,
        'likedBy': listOfLikes,
      }).then((value) => success = false);

      setState(() {
        widget.post.likeCount = widget.post.likeCount - 1;
      });

      return success;
    }
  }

  final _user = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();
  String comment = '';
  bool liked_already = false;
  final _textFormController = TextEditingController();
  List tags = [];

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.headline2!,
      child: FutureBuilder(
          future: MappingOperation().then((result) => liked_already = result),
          builder: (context, snaphot){
            return Scaffold(
              resizeToAvoidBottomInset: false,
              backgroundColor: globals.light ? Colors.white: Colors.grey[700],
              appBar: AppBar(
                backgroundColor: globals.light ? Colors.lightBlueAccent : Colors.black,
                centerTitle: true,
                title: Text('Post Page'),
              ),
              body:
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset('assets/unite_logo.png', height: 50, width: 50,),
                      SizedBox(height: 20.0,),
                      widget.post.image_url == '' ?
                      Text('') : Image.network(widget.post.image_url, height: 200, width: 200, fit: BoxFit.fitHeight),
                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(widget.post.owner_name, style: globals.light ? AppStyles.profileText : AppStyles.postText),
                          SizedBox(width: 20),
                          Text(widget.post.text, style: globals.light ? AppStyles.profileText : AppStyles.postText, overflow: TextOverflow.fade,),
                        ],
                      ),                      SizedBox(height: 10.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          LikeButton(
                            isLiked: liked_already,
                            onTap: (isLiked) async {
                              return onLikeButtonTapped(liked_already);
                            },
                          ),
                          SizedBox(width: 5),
                          Text('${widget.post.likeCount}', style: AppStyles.postText),
                          SizedBox(width: 15),
                          Icon(Icons.chat_bubble_outline, color: globals.light ? AppColors.appTextColor : AppColors.postTextColor),
                          SizedBox(width: 5),
                          Text('${widget.post.comments.length}', style: AppStyles.postText)

                        ],
                      ),
                      Wrap(
                          children: tags.map(
                                  (tag) => Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Chip(
                                  label:Text(tag),
                                  labelStyle: AppStyles.tagText,
                                  backgroundColor: globals.light ? AppColors.logoColor : Colors.deepPurple,
                                ),
                              )
                          ).toList()
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: CommentCards.length,
                          itemBuilder: (context, index) {
                            return CommentCards[index];
                          },
                        ),
                      ),
                      Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                style: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                                controller: _textFormController,
                                textAlign: TextAlign.center,
                                decoration: new InputDecoration(
                                  hintText: "Add a comment...",
                                  hintStyle: globals.light ? AppStyles.profileText : darkAppStyles.profileText,
                                  fillColor: Colors.black,
                                  border: new OutlineInputBorder(
                                    borderRadius: new BorderRadius.circular(0.0),
                                    borderSide: new BorderSide(),
                                  ),
                                ),
                                validator: (String? value) {
                                  print('Value: ');
                                  print(value);
                                  comment = value!;
                                },
                              ),
                            ),
                            FloatingActionButton(
                              backgroundColor: globals.light ? AppColors.logoColor : darkAppColors.logoColor,
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()){
                                    onPostComment();
                                  }
                                  _textFormController.clear();

                                },
                                child: Text('Post'))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );

          }
      ),
    );
  }
}