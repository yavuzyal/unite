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


class PostTileSearched extends StatefulWidget {

  final Post post;
  final VoidCallback delete;
  final VoidCallback like;
  String userId;

  PostTileSearched({required this.post, required this.delete, required this.like, required this.userId});

  @override
  _PostTileSearched createState() => _PostTileSearched();

}

class _PostTileSearched extends State<PostTileSearched> {

  final _user = FirebaseAuth.instance.currentUser;
  bool liked_already = false;
  String comment = '';

  Future<bool> onLikeButtonTapped(bool isLiked) async{

    bool success = false;

    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      setState(() {
        widget.post.likeCount = widget.post.likeCount + 1;
      });

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('notifications').add({
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

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount - 1,
        'likedBy': listOfLikes,
      }).then((value) => success = false);

      setState(() {
        widget.post.likeCount = widget.post.likeCount - 1;
      });

      return success;
    }
  }

  Future onPostComment() async{
    DocumentSnapshot<Map<String, dynamic>> comments = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfComments = [];

    //print(comments.data()!.cast().values.toList());

    print(comments.get('comment'));

    listOfComments = comments.get('comment');

    listOfComments.add(_user!.uid + comment);

    await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).update({
      'comment': listOfComments,
    });
  }

  Future <bool> alreadyLiked() async {
    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');
    String reshared_id = liked.get('sharedFrom');

    print(reshared_id);

    final name = await FirebaseFirestore.instance.collection('users').doc(reshared_id).get();
    reshared = name.get('username');

    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
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

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("You have ReUnited!"),
      ));

  }

  bool there_is_image = false;
  final _formKey = GlobalKey<FormState>();
  String reshared = '';

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(

        future: alreadyLiked().then((value) => liked_already = value),
        builder: (context, snapshot){

          if(widget.post.image_url != ''){
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostPage(post: widget.post, userId: widget.userId,)),
                );
                FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
              },
              child: Form(
                key: _formKey,
                child: Card(
                  margin: EdgeInsets.all(10),
                  color: AppColors.postBackgroundColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 10,),
                      reshared != '' ? Text('ReUnited From ' + reshared, style: TextStyle(color: Colors.white, )): Text(''),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Image.network(widget.post.image_url, height: 150, width: 150, fit: BoxFit.cover),
                            //SizedBox(width: 55,),
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(widget.post.date,style: TextStyle(color: Colors.white, )),
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
                                          onTap: (isLiked) async {
                                            return onLikeButtonTapped(liked_already);
                                          },
                                        ),
                                        SizedBox(width: 5),
                                        Text('${widget.post.likeCount}', style: AppStyles.postText),
                                        SizedBox(width: 15),
                                        Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                                        SizedBox(width: 5),
                                        Text('${widget.post.comments.length}', style: AppStyles.postText),
                                        SizedBox(width: 5),
                                        IconButton(
                                          icon: Icon(Icons.refresh),
                                          color: AppColors.postTextColor,
                                          onPressed: () {
                                            reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', widget.userId);
                                          },),
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
                                print('Value: ');
                                print(value);
                                comment = value!;
                              },
                            ),
                          ),
                          FloatingActionButton(
                              onPressed: () async {
                                if(_formKey.currentState!.validate()){
                                  onPostComment();
                                }
                              },
                              child: Text('Post'))
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          else{
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostPage(post: widget.post, userId: widget.userId,)),
                );
                FirebaseAnalytics.instance.logScreenView(screenClass: "PostPage", screenName: "PostPage");
              },
              child: Form(
                key: _formKey,
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
                                  reshared != '' ? Text('ReUnited From ' + reshared,style: TextStyle(color: Colors.white, )): Text(''),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(widget.post.date,style: TextStyle(color: Colors.white, )),
                                      //SizedBox(width :55),
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
                                            onTap: (isLiked) async {
                                              return onLikeButtonTapped(liked_already);
                                            },
                                          ),
                                          SizedBox(width: 5),
                                          Text('${widget.post.likeCount}', style: AppStyles.postText),
                                          SizedBox(width: 15),
                                          Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                                          SizedBox(width: 5),
                                          Text('${widget.post.comments.length}', style: AppStyles.postText),
                                          SizedBox(width: 5),
                                          IconButton(
                                            icon: Icon(Icons.refresh),
                                            color: AppColors.postTextColor,
                                            onPressed: () {
                                              reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', widget.userId);
                                            },),
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
                                  print('Value: ');
                                  print(value);
                                  comment = value!;
                                },
                              ),
                            ),
                            FloatingActionButton(
                                onPressed: () async {
                                  if(_formKey.currentState!.validate()){
                                    onPostComment();
                                  }
                                },
                                child: Text('Post'))
                          ],
                        ),
                      ],
                    )
                ),
              ),
            );
          }
        });
  }
}


/*  Future<List> isThereImage () async {
    DocumentSnapshot img = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).get();

    print('URL');
    print(img.get('image_url'));

    if(img.get('image_url') == "" || img.get('image_url') == null){
      there_is_image =  false;
    }

    there_is_image = true;

    DocumentSnapshot<Map<String, dynamic>> liked = await FirebaseFirestore.instance.collection('users').doc(widget.userId).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.data()!.cast().values.toList()[1];

    print(listOfLikes.contains(_user!.uid));

    if(listOfLikes.contains(_user!.uid)){
      liked_already = true;
    }
    liked_already = false;

    List bools = [there_is_image, liked_already];

    return bools;

  }*/