import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'post.dart';
import 'styles.dart';
import 'colors.dart';
import 'post_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostTileSearched extends StatelessWidget {

  final Post post;
  final VoidCallback delete;
  final VoidCallback like;
  String userId;

  //LikeButtonTapCallback isLiked;

  //final userId;
  PostTileSearched({required this.post, required this.delete, required this.like, required this.userId});

  final _user = FirebaseAuth.instance.currentUser;
  bool liked_already = false;
  String comment = '';

  Future <bool >alreadyLiked() async {
    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async{

    bool success = false;

    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).update({
        'likeCount': post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      return success;
    }

    else{
      listOfLikes.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).update({
        'likeCount': post.likeCount - 1,
        'likedBy': listOfLikes,
      }).then((value) => success = false);

      return success;
    }
  }

  Future onPostComment() async{
    DocumentSnapshot<Map<String, dynamic>> comments = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).get();

    List<dynamic> listOfComments = [];

    print(comments.data()!.cast().values.toList());

    listOfComments = comments.data()!.cast().values.toList()[4];

    listOfComments.add(comment);

    await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).update({
      'comment': listOfComments,
    });
  }

  Future<bool> isThereImage () async {
    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(userId).collection('posts').doc(post.postId).get();

    if(liked.data()!.cast().values.toList()[2] == "" || liked.data()!.cast().values.toList()[2] == null){
      return false;
    }

    return true;
  }

  Future <void>report(Post post)async {
    String username = "unite.report.mail@gmail.com";
    String password = "Elma1357!";

    final smtpServer = gmail(username, password);

    // Create our email message.
    final message = Message()
      ..from = Address(username)
      ..recipients.add('unite.report.mail@gmail.com') //recipent email
      ..subject = 'Post report' //subject of the email
      ..text = '${_user!.email} reported the post: ${post.postId}'; //body of the email

    try {
      final sendReport = await send(message, smtpServer);
      print('Message sent: ' + sendReport.toString()); //print if the email is sent
    } on MailerException catch (e) {
      print('Message not sent. \n'+ e.toString()); //print if the email is not sent
      // e.toString() will show why the email is not sending
    }
  }

  bool there_is_image = true;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: isThereImage().then((value) => there_is_image = value),
        builder: (context, snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return  Card(
                margin: EdgeInsets.all(10),
                color: AppColors.postBackgroundColor,
                child:Center(child: CircularProgressIndicator()));}
          else{
            if(there_is_image){
              return FutureBuilder(
                  future: alreadyLiked().then((result) => liked_already = result),
                  builder: (context, snapshot){
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostPage(post: post)),
                        );
                        FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
                      },
                      child: Card(
                          margin: EdgeInsets.all(10),
                          color: AppColors.postBackgroundColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.network(post.image_url, height: 150, width: 150, fit: BoxFit.cover),
                                    SizedBox(width: 55,),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(post.date,style: TextStyle(color: Colors.white, )),
                                            IconButton(
                                              alignment: Alignment.topRight,
                                              onPressed: () => report(post),
                                              iconSize: 20,
                                              splashRadius: 24,
                                              color: AppColors.postTextColor,
                                              icon: Icon(
                                                Icons.report,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height :5),
                                            Text(post.text, style: AppStyles.postText),
                                            SizedBox(height : 15),
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
                                                Text('${post.likeCount}', style: AppStyles.postText),
                                                SizedBox(width: 15),
                                                Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                                                SizedBox(width: 5),
                                                Text('${post.commentCount}', style: AppStyles.postText)
                                              ],
                                            ),
                                            SizedBox(height : 15),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      decoration: new InputDecoration(
                                        hintText: "Add a comment...",
                                        fillColor: Colors.black,
                                        border: new OutlineInputBorder(
                                          borderRadius: new BorderRadius.circular(0.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if(value!.isEmpty || value == ''){
                                          comment = '';
                                        }
                                        else
                                          comment = value!;
                                      },
                                    ),
                                  ),
                                  FloatingActionButton(
                                      onPressed: () async {
                                        onPostComment();
                                      },
                                      child: Text('Post'))
                                ],
                              ),
                            ],
                          )
                      ),
                    );
                  });
            }
            else{
              return FutureBuilder(
                  future: alreadyLiked().then((result) => liked_already = result),
                  builder: (context, snapshot){
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostPage(post: post)),
                        );
                        FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
                      },
                      child: Card(
                          margin: EdgeInsets.all(10),
                          color: AppColors.postBackgroundColor,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //Image.network(post.image_url, height: 150, width: 150, fit: BoxFit.cover),
                                    Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(post.date,style: TextStyle(color: Colors.white, )),
                                            SizedBox(width :55),
                                            IconButton(
                                              alignment: Alignment.topRight,
                                              onPressed: () => report(post),
                                              iconSize: 20,
                                              splashRadius: 24,
                                              color: AppColors.postTextColor,
                                              icon: Icon(
                                                Icons.report,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            SizedBox(height :5),
                                            Text(post.text, style: AppStyles.postText),
                                            SizedBox(height : 15),
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
                                                Text('${post.likeCount}', style: AppStyles.postText),
                                                SizedBox(width: 15),
                                                Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                                                SizedBox(width: 5),
                                                Text('${post.commentCount}', style: AppStyles.postText)
                                              ],
                                            ),
                                            SizedBox(height : 15),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      textAlign: TextAlign.center,
                                      decoration: new InputDecoration(
                                        hintText: "Add a comment...",
                                        fillColor: Colors.black,
                                        border: new OutlineInputBorder(
                                          borderRadius: new BorderRadius.circular(0.0),
                                          borderSide: new BorderSide(),
                                        ),
                                      ),
                                      validator: (String? value) {
                                        if(value!.isEmpty || value == ''){
                                          comment = '';
                                        }
                                        else
                                          comment = value!;
                                      },
                                    ),
                                  ),
                                  FloatingActionButton(
                                      onPressed: () async {
                                        onPostComment();
                                      },
                                      child: Text('Post'))
                                ],
                              ),
                            ],
                          )
                      ),
                    );
                  });
            }
          }
    }
    );
  }
}