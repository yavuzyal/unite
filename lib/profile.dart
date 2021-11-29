import 'package:flutter/material.dart';
import 'utils/colors.dart';
import 'utils/styles.dart';
import 'utils/post_tile.dart';
import 'utils/post.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {


  List<Post> myPosts = [

    Post(text: 'Hanım ve ben', image_url: "https://fastly.4sqi.net/img/user/130x130/70007152-VS1PELETNKOZ0TQ1.jpg", date: '22.10.2021', likeCount: 10, commentCount: 5, comments: {"duygu": "<3", "yasemin": "heyyo", "berk": "yasasin", "yavuz": "couple goals", "zeynep": "AAAAAaaaAAAAAAAAAAAAaaaAAAAAAAAAAAAaaaAAAAAAAAAAAAaaaAAAAAAA"}),
    Post(text: 'Sabanj', image_url: "https://studyinturkey.net/wp-content/uploads/2020/12/sabanci-universitesi-kampus.jpg", date: '22.10.2019', likeCount: 10, commentCount: 5, comments: {}),

  ];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body:
      SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.asset('assets/unite_logo.png', height: 50, width: 50,),
                    SizedBox(height: 30.0,),
                    CircleAvatar(
                      backgroundColor: AppColors.logoColor,
                      child: ClipOval(
                        child: Image.network(
                          'https://pbs.twimg.com/profile_images/477095600941707265/p1_nev2e_400x400.jpeg',
                          fit: BoxFit.cover,
                        ),
                      ),
                      radius: 70,
                    ),
                    SizedBox(height : 15),
                    Text("Barış Altop", style: AppStyles.profileName,),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(90,0,0,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                          Expanded(child: Text("Sabancı University", style: AppStyles.profileText, textAlign: TextAlign.left,))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(90,0,0,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                          Expanded(child: Text("Computer Science", style: AppStyles.profileText, textAlign: TextAlign.left,))
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(90,0,0,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                          Expanded(child: Text("30", style: AppStyles.profileText, textAlign: TextAlign.left,))
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(90,0,20,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                          Expanded(child: Text("Hacking, coding, travelling, interest4, interest5", style: AppStyles.profileText, textAlign: TextAlign.left,))
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(90,0,0,0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on_outlined, color: AppColors.appTextColor),
                          Expanded(child: Text("Hi there, I am using UNIte!", style: AppStyles.profileText, textAlign: TextAlign.left,))
                        ],
                      ),
                    ),

                    SizedBox(height: 20),
                    Container(
                      child: Column(
                        children: myPosts.map(
                                (post) =>
                                PostTile(
                                  post: post,
                                  delete: () {
                                    setState(() {
                                      myPosts.remove(post);
                                    });
                                  },
                                  like: () {
                                    setState(() {
                                      post.likeCount++;
                                    });
                                  },)
                        ).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}