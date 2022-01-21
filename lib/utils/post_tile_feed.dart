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
import 'package:unite/valueListenables.dart';
import 'package:unite/usables/config.dart' as globals;


class PostTileFeed extends StatefulWidget {

  final Post post;
  final VoidCallback delete;
  final VoidCallback like;
  bool searched;
  int dummy = 0;

  PostTileFeed({required this.post, required this.delete, required this.like, required this.searched});

  @override
  _PostTileFeedState createState() => _PostTileFeedState();


}

class _PostTileFeedState extends State<PostTileFeed> {

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

  Future <void>bookmark(Post post)async {

    if (bookmarked == false) {

      await FirebaseFirestore.instance.collection('users').doc(
          _user!.uid).collection('bookmarks').doc(post.postId).set(
          {
            'postId' : post.postId,
            'owner': post.owner,
            'owner_name' : post.owner_name,
            'like_count' : post.likeCount,
            'comment_count' : post.commentCount,
            'comments' : post.comments,
            'url' : post.image_url,
            'date' : post.date,
            'text' : post.text,
          });

      setState(() {
        bookmarked = true;
      });
    }
    else{

      await FirebaseFirestore.instance.collection('users').doc(
          _user!.uid).collection('bookmarks').doc(post.postId).delete();

      setState(() {
        bookmarked = false;
      });
    }

    valueListenables.bookmarkedPost.value= !valueListenables.bookmarkedPost.value;

  }

  Future <bool> alreadyLiked() async {

    DocumentSnapshot user_info = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).get();

    widget.post.owner_name = user_info['username'];

    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    String reshared_id = liked.get('sharedFrom');

    String location_name = liked.get('location');

    String reshared_if = reshared_id == "" ? "" : 'Reshared';

    if(reshared_id != ''){
      DocumentSnapshot snap = await FirebaseFirestore.instance.collection('users').doc(reshared_id).get();
      String name = snap['username'];

      setState(() {
        reshared = name;
        if_reshared = reshared_if;
        location = location_name;
      });
    }
    else{
      setState(() {
        if_reshared = reshared_if;
        location = location_name;
      });
    }

    tags = await liked.get('tags');
    
    QuerySnapshot user = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).collection('bookmarks').get();

    for(var check_post in user.docs){
      if(check_post['postId'] == widget.post.postId){
        setState(() {
          bookmarked = true;
        });
        break;
      }
    }

    print("${widget.post.postId} $bookmarked");

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy');


    if(listOfLikes.contains(_user!.uid)){
      return true;
    }
    return false;
  }

  Future reShare(url, like, comment, caption, location, sharedFrom ) async {

    final firestoreInstance = FirebaseFirestore.instance;

    DocumentSnapshot info1 = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    List<String> indexList = [];

    String location = info1.get('location');
    List tags_list = info1.get('tags');

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
          "sharedFrom": widget.post.owner,
          'location_array' : indexList,
          "owner" : _user!.uid,
          "text_array" : indexListCaption,
          'tags' : tags_list
        }).then((value){
      //print(value.id);
    });

    DocumentSnapshot info = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();
    String name = info.get('username');

    firestoreInstance.collection("users").doc(widget.post.owner).collection('notifications').add(
        {
          'message' : '${name} reshared your post!',
          'datetime': DateTime.now(),
          'url' : widget.post.image_url,
          'uid': '',
          'follow_request': 'no',
        });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text("You have ReUnited!"),
    ));

  }

  Future<bool> onLikeButtonTapped(context, bool isLiked, post) async{

    bool success = false;

    DocumentSnapshot liked = await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).get();

    List<dynamic> listOfLikes = [];

    listOfLikes = liked.get('likedBy'); 

    if(isLiked == false){
      listOfLikes.add(_user!.uid);

      await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('posts').doc(widget.post.postId).update({
        'likeCount': widget.post.likeCount + 1,
        'likedBy': listOfLikes,
      }).then((value) => success = true);

      setState(() {
        post.likeCount = post.likeCount + 1;
      });

      DocumentSnapshot info = await FirebaseFirestore.instance.collection('users').doc(_user!.uid).get();

      await FirebaseFirestore.instance.collection('users').doc(widget.post.owner).collection('notifications').add({
        'message' : 'You received a like from ${info['username']}!',
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

  String if_reshared = '';
  String reshared = '';
  bool bookmarked = false;
  String location = '';
  List tags = [];

  @override
  Widget build(BuildContext context) {
    if(widget.post.image_url != ''){
              return FutureBuilder(
                  future: alreadyLiked().then((value) => liked_already = value),
                  builder: (context, snapshot){
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
                              if_reshared == 'Reshared' ? Text('${widget.post.owner_name} ReUNited From ' + reshared, style: TextStyle(color: Colors.white, )): Text(''),
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
                                          SizedBox.shrink(),
                                          IconButton(
                                            padding: EdgeInsets.all(0),
                                            alignment: Alignment.center,
                                            visualDensity: VisualDensity.compact,
                                            onPressed: () => {
                                            bookmark(widget.post),
                                          },
                                            iconSize: 20,
                                            splashRadius: 20,
                                            color: AppColors.postTextColor,
                                            icon: bookmarked == true ? Icon(Icons.bookmark) : Icon(Icons.bookmark_outline),
                                          ),
                                          IconButton(
                                            alignment: Alignment.center,
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
                                          Text(location,  style: AppStyles.postLocation),
                                          SizedBox(height : 5),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(widget.post.owner_name, style: AppStyles.postOwnerText),
                                              SizedBox(width: 10),
                                              Text(widget.post.text, style: AppStyles.postText, overflow: TextOverflow.fade,),
                                            ],
                                          ),
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
                                                  reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', widget.post.owner);
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
                              Wrap(
                                  children: tags.map(
                                          (tag) => Padding(
                                        padding: const EdgeInsets.all(4.0),
                                        child: Chip(
                                          label:Text(tag),
                                          labelStyle: AppStyles.tagText,
                                          backgroundColor: globals.light ? AppColors.logoColor : Colors.deepPurple,
                                        ),
                                      )
                                  ).toList()
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
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  if_reshared == 'Reshared' ? Text('${widget.post.owner_name} ReUNited From ' + reshared, style: TextStyle(color: Colors.white, )): Text(''),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Text(widget.post.date, style: AppStyles.postText),
                                      //SizedBox(width :5),
                                      SizedBox.shrink(),
                                      IconButton(
                                        padding: EdgeInsets.all(0),
                                        alignment: Alignment.center,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => bookmark(widget.post),
                                        iconSize: 20,
                                        splashRadius: 20,
                                        color: AppColors.postTextColor,
                                        icon: bookmarked == true ? Icon(Icons.bookmark) : Icon(Icons.bookmark_outline),
                                      ),
                                      IconButton(
                                        alignment: Alignment.center,
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

                                  Text(location,  style: AppStyles.postLocation),
                                  SizedBox(height :5),
                                  Row(
                                    children: [
                                      Text(widget.post.owner_name, style: AppStyles.postOwnerText),
                                      SizedBox(width: 10),
                                      Text(widget.post.text, style: AppStyles.postText, overflow: TextOverflow.fade,),
                                    ],
                                  ),
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
                                          reShare(widget.post.image_url, 0, [] , widget.post.text, 'Reshared', widget.post.owner);
                                        },),
                                    ],
                                  ),
                                  Wrap(
                                      children: tags.map(
                                              (tag) => Padding(
                                            padding: const EdgeInsets.all(4.0),
                                            child: Chip(
                                              label:Text(tag),
                                              labelStyle: AppStyles.tagText,
                                              backgroundColor: globals.light ? AppColors.logoColor : Colors.deepPurple,
                                            ),
                                          )
                                      ).toList()
                                  ),
                                  SizedBox(height : 10),
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
