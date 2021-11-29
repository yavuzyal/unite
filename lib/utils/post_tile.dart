import 'package:flutter/material.dart';
import 'post.dart';
import 'styles.dart';
import 'colors.dart';
import 'post_page.dart';

class PostTile extends StatelessWidget {

  final Post post;
  final VoidCallback delete;
  final VoidCallback like;
  const PostTile({required this.post, required this.delete, required this.like});

  @override
  Widget build(BuildContext context) {
    return
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PostPage(post: post)),
          );
        },
        child: Card(
<<<<<<< Updated upstream
        margin: EdgeInsets.all(10),
        color: AppColors.postBackgroundColor,
        child:
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.network(post.image_url, height: 150, width: 150, fit: BoxFit.fitHeight),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width :55),
                      IconButton(
                        alignment: Alignment.topRight,
                        onPressed: delete,
                        iconSize: 20,
                        splashRadius: 24,
                        color: AppColors.postTextColor,
                        icon: Icon(
                          Icons.delete_outline,
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
                    children: [
                      IconButton(
                        constraints: BoxConstraints(),
                        onPressed: like,
                        iconSize: 25,
                        splashRadius: 150,
                        padding: EdgeInsets.all(0),
                        color: AppColors.postTextColor,
                        icon: Icon(
                          Icons.favorite_border,
                        ),
                      ),
                      SizedBox(width: 5),
                      Text('${post.likeCount}', style: AppStyles.postText),
                      SizedBox(width: 15),
                      Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                      SizedBox(width: 5),
                      Text('${post.commentCount}', style: AppStyles.postText)
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
=======
          margin: EdgeInsets.all(10),
          color: AppColors.postBackgroundColor,
          child:
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.network(post.image_url, height: 150, width: 150, fit: BoxFit.fitHeight),
                Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width :55),
                        IconButton(
                          alignment: Alignment.topRight,
                          onPressed: delete,
                          iconSize: 20,
                          splashRadius: 24,
                          color: AppColors.postTextColor,
                          icon: Icon(
                            Icons.delete_outline,
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
                          children: [
                            IconButton(
                              constraints: BoxConstraints(),
                              onPressed: like,
                              iconSize: 25,
                              splashRadius: 150,
                              padding: EdgeInsets.all(0),
                              color: AppColors.postTextColor,
                              icon: Icon(
                                Icons.favorite_border,
                              ),
                            ),
                            SizedBox(width: 5),
                            Text('${post.likeCount}', style: AppStyles.postText),
                            SizedBox(width: 15),
                            Icon(Icons.chat_bubble_outline, color: AppColors.postTextColor),
                            SizedBox(width: 5),
                            Text('${post.commentCount}', style: AppStyles.postText)
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
>>>>>>> Stashed changes
      );
  }
}