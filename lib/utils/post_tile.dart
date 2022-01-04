import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'post.dart';
import 'styles.dart';
import 'colors.dart';
import 'post_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class PostTile extends StatefulWidget {

  final Post post;
  final VoidCallback delete;
  final VoidCallback like;
  int dummy = 0;

  PostTile({required this.post, required this.delete, required this.like});

  @override
  _PostTileState createState() => _PostTileState();

}

class _PostTileState extends State<PostTile> {

  final _user = FirebaseAuth.instance.currentUser;
  bool liked_already = false;

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

  Future <bool >alreadyLiked() async {
    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
  }

  Future<bool> onLikeButtonTapped(context, bool isLiked, post) async{

    bool success = false;

    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      setState(() {
        post.likeCount = post.likeCount + 1;
      });

      return success;
    }

    else{
      listOfLikes.remove(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount - 1,
        'likedBy': listOfLikes,
      }).then((value) => success = false);

      setState(() {
        post.likeCount = post.likeCount - 1;
      });

      return success;
    }
  }
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: alreadyLiked().then((result) => liked_already = result),
        builder: (context, snapshot){
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PostPage(post: widget.post)),
              );
              FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
            },
            child: Card(
              margin: EdgeInsets.all(10),
              color: AppColors.postBackgroundColor,
              child:
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.network(widget.post.image_url, height: 150, width: 150, fit: BoxFit.cover),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(widget.post.date, style: AppStyles.postText),
                            SizedBox(width :5),
                            IconButton(
                              alignment: Alignment.topRight,
                              onPressed: widget.delete,
                              iconSize: 20,
                              splashRadius: 24,
                              color: AppColors.postTextColor,
                              icon: Icon(
                                Icons.delete_outline,
                              ),
                            ),
                            SizedBox(width :5),
                            IconButton(
                              alignment: Alignment.topRight,
                              onPressed: () => report(widget.post),
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
                            Text(widget.post.text, style: AppStyles.postText),
                            SizedBox(height : 15),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LikeButton(
                                  isLiked: liked_already,
                                  onTap: (isLiked) {
                                    return onLikeButtonTapped(context, liked_already, widget.post);
                                  },
                                ),
                                SizedBox(width: 5),
                                Text('${widget.post.likeCount}', style: AppStyles.postText),
                                SizedBox(width: 15),
                                Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                                SizedBox(width: 5),
                                Text('${widget.post.commentCount}', style: AppStyles.postText)
                              ],
                            ),
                            SizedBox(height : 45),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
