/// Flutter code sample for PageView

// Here is an example of [PageView]. It creates a centered [Text] in each of the three pages
// which scroll horizontally.

import 'package:flutter/material.dart';
import 'package:unite/Login.dart';

/// This is the main application widget.
class WalkthroughScreen extends StatelessWidget {
  const WalkthroughScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      color: Colors.white,
      home: Scaffold(
        backgroundColor: Colors.white,
        body: const MyStatelessWidget(),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MyStatelessWidget extends StatelessWidget {
  const MyStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 0);
    return PageView(
      /// [PageView.scrollDirection] defaults to [Axis.horizontal].
      /// Use [Axis.vertical] to scroll vertically.
      scrollDirection: Axis.horizontal,
      controller: controller,
      children: <Widget>[



        Center( //ILK SAYFASI
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(height: 20,),
                Text('Welcome to UNIte', style: TextStyle(fontSize: 35),),
                Image.asset(
                  'assets/unite_logo.png',
                  height: 250.0,
                  width: 250.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Here, you can find new friends,\n or the love of your life ❤',overflow: TextOverflow.fade, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Swipe left', style: TextStyle(fontSize: 20, color: Colors.white),),
                        Icon(Icons.arrow_back, color: Colors.white,),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Swipe Right', style: TextStyle(fontSize: 20, color: Colors.grey),),
                        Icon(Icons.arrow_forward, color: Colors.grey,),
                      ],
                    ),
                  ]
                ),
              ],
            ),
              )
        ),



        Center(  //IKINCI SAYFASI
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20,),
                  Text('Search by Location', style: TextStyle(fontSize: 35),),
                  Image.asset(
                    'assets/search by loc2.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('You can find other people\nby searching a location',overflow: TextOverflow.fade, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Swipe left', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_back, color: Colors.grey,),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Swipe Right', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_forward, color: Colors.grey,),
                          ],
                        ),
                      ]
                  ),
                ],
              ),
            )
        ),



        Center(  //3. SAYFASI
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20,),
                  Text('One Time Password', style: TextStyle(fontSize: 35),),
                  Image.asset(
                    'assets/one time password.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('For privacy, others can only add\nyou with a one time code!',overflow: TextOverflow.fade, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Swipe left', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_back, color: Colors.grey,),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Swipe Right', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_forward, color: Colors.grey,),
                          ],
                        ),
                      ]
                  ),
                ],
              ),
            )
        ),



        Center(  //4. SAYFASI
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20,),
                  Text('Swipe Left or Right!', style: TextStyle(fontSize: 35),),
                  Image.asset(
                    'assets/swipe.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('To match with the people you\nlike, you can simply swipe!',overflow: TextOverflow.fade, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Swipe left', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_back, color: Colors.grey,),
                          ],
                        ),
                        Column(
                          children: [
                            Text('Swipe Right', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_forward, color: Colors.grey,),
                          ],
                        ),
                      ]
                  ),
                ],
              ),
            )
        ),


        Center(  //5. SAYFASI
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(height: 20,),
                  Text('Message On Match!', style: TextStyle(fontSize: 35),),
                  Image.asset(
                    'assets/message.jpg',
                    height: 250.0,
                    width: 250.0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('If you matched, you can\nmessage through the app!',overflow: TextOverflow.fade, textAlign: TextAlign.center,style: TextStyle(fontSize: 25),),
                    ],
                  ),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text('Swipe left', style: TextStyle(fontSize: 20, color: Colors.grey),),
                            Icon(Icons.arrow_back, color: Colors.grey,),
                          ],
                        ),
                        FloatingActionButton(
                          child: Text('Start'),
                            onPressed: (){
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => LoginPage()),
                              );
                            }),
                      ]
                  ),
                ],
              ),
            )
        ),
      ],
    );
  }
}