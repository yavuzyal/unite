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
  bool there_is_image = true;

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
    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');

    print('LIST OF LIKES');
    print(listOfLikes);
    print(_user!.uid);

    String reshared_id = liked.get('sharedFrom');

    final name = await FirebaseFirestore.instance.collection('users').doc(reshared_id).get();
    reshared = name.get('username');

    print(widget.post.text);
    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
  }

  Future reShare(url, like, comment, caption, location, sharedFrom, ) async {

    final firestoreInstance = FirebaseFirestore.instance;

    firestoreInstance.collection("users").doc(_user!.uid).collection('posts').add(
        {
          "image_url" : url,
          "likeCount" : like,
          "comment" : [],
          "caption": caption,
          "datetime": DateTime.now(),
          "location": location,
          "likedBy": [],
          "sharedFrom": sharedFrom,
        }).then((value){
      print(value.id);
    });

    url != "" ?
    firestoreInstance.collection("users").doc(_user!.uid).collection('notifications').add(
        {
          'message' : 'You uploaded a post!',
          'datetime': DateTime.now(),
          'url' : url,
          'uid': '',
          'follow_request': 'no',
        }) :
    firestoreInstance.collection("users").doc(_user!.uid).collection('notifications').add(
        {
          'message' : 'You shared a message!',
          'datetime': DateTime.now(),
          'url' : url,
          'uid': '',
          'follow_request': 'no',
        });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("You have ReUnited!"),
    ));

  }

  Future<bool> onLikeButtonTapped(context, bool isLiked, post) async{

    bool success = false;

    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy'); 

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      setState(() {
        post.likeCount = post.likeCount + 1;
      });

      await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('notifications').add({
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

  Future<bool> isThereImage () async {
    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('posts').doc(widget.post.postId).get();

    if(liked.get('image_url') == "" || liked.get('image_url') == null){
      return false;
    }

    return true;
  }

  String reshared = '';

  @override
  Widget build(BuildContext context) {
            if(widget.post.image_url != ''){
              return FutureBuilder(
                  future: alreadyLiked().then((result) => liked_already = result),
                  builder: (context, snapshot){
                    //print(widget.post.text);
                    //print(liked_already);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostPage(post: widget.post, userId: _user!.uid,)),
                        );
                        FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        color: AppColors.postBackgroundColor,
                        child:
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            children: [
                              reshared != '' ? Text('ReUNited From ' + reshared, style: TextStyle(color: Colors.white, )): Text(''),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.network(widget.post.image_url, height: 150, width: 150, fit: BoxFit.cover),
                                  Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(widget.post.date, style: AppStyles.postText),
                                          //SizedBox(width :5),
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
                                          //SizedBox(width :5),
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
                                              Text('${widget.post.commentCount}', style: AppStyles.postText),
                                              SizedBox(width: 5),
                                              IconButton(
                                                icon: Icon(Icons.refresh),
                                                color: AppColors.postTextColor,
                                                onPressed: () {
                                                  reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', _user!.uid);
                                                },),
                                            ],
                                          ),
                                          SizedBox(height : 45),
                                        ],
                                      ),
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
            else{
              return FutureBuilder(
                  future: alreadyLiked().then((result) => liked_already = result),
                  builder: (context, snapshot){
                    print(widget.post.text);
                    print(liked_already);
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PostPage(post: widget.post, userId: _user!.uid,)),
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  reshared != '' ? Text('ReUNited From ' + reshared, style: TextStyle(color: Colors.white, )): Text(''),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(widget.post.date, style: AppStyles.postText),
                                      //SizedBox(width :5),
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
                                      //SizedBox(width :5),
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

                                  SizedBox(height :5),
                                  Text(widget.post.text, style: AppStyles.postText, overflow: TextOverflow.fade,),
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
                                      Text('${widget.post.commentCount}', style: AppStyles.postText),
                                      SizedBox(width: 5),
                                      IconButton(
                                        icon: Icon(Icons.refresh),
                                        color: AppColors.postTextColor,
                                        onPressed: () {
                                          reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', _user!.uid);
                                        },),
                                    ],
                                  ),
                                  SizedBox(height : 45),

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
}
