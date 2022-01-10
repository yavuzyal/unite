import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'post.dart';
import 'styles.dart';
import 'colors.dart';

class PostPage extends StatefulWidget {

  final Post post;
  const PostPage({required this.post});

  @override
  _PostPageState createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {

  List<Card> CommentCards = [];
  Map<String, String> withUsername = {};


  Future MappingOperation() async {

    for(int i = 0; i < widget.post.comments.length; i++){

      String user = widget.post.comments[i].toString().substring(0, 28);
      String comment = widget.post.comments[i].toString().substring(28);

      DocumentSnapshot thisUser =  await FirebaseFirestore.instance.collection('users').doc(user).get();

      String username = thisUser.get('username');

      withUsername[username] = comment;

    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: MappingOperation(),
        builder: (context, snapshot){
          withUsername.forEach((user,comment) => CommentCards.add(
            Card(
              color: AppColors.postBackgroundColor,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(child: Text(user, style: AppStyles.commentName,)),
                    SizedBox(width: 10),
                    Expanded(child: Text(comment, style: AppStyles.commentName,)),
                  ],
                ),
              ),
            ),
          ),
          );

          return Scaffold(
            appBar: AppBar(
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
                    Text(widget.post.text, style: AppStyles.profileText,),
                    SizedBox(height: 10.0,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          constraints: BoxConstraints(),
                          onPressed: () {
                            setState(() {
                              widget.post.likeCount++;
                            });
                          },
                          iconSize: 25,
                          splashRadius: 150,
                          padding: EdgeInsets.all(0),
                          color: AppColors.appTextColor,
                          icon: Icon(
                            Icons.favorite_border,
                          ),
                        ),
                        SizedBox(width: 5),
                        Text('${widget.post.likeCount}', style: AppStyles.profileText),
                        SizedBox(width: 15),
                        Icon(Icons.chat_bubble_outline, color: AppColors.appTextColor),
                        SizedBox(width: 5),
                        Text('${widget.post.commentCount}', style: AppStyles.profileText)
                      ],
                    ),

                    Expanded(
                      child: ListView.builder(
                        itemCount: CommentCards.length,
                        itemBuilder: (context, index) {
                          return CommentCards[index];
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });

  }
}