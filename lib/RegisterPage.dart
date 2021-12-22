import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
import 'package:unite/Login.dart';
//import 'package:unite/utils/authentication_service.dart';
import 'package:unite/utils/dimensions.dart';
import 'utils/styles.dart';
import 'utils/colors.dart';

class RegisterPage extends StatefulWidget {

  @override
  State<RegisterPage> createState() => _RegisterPage2();
}

class _RegisterPage2 extends State<RegisterPage> {

  final database = FirebaseDatabase.instance.reference();

  Future<String> getUser() async {
    print("in getUser");
    String result = (await FirebaseDatabase.instance.reference().child('users/').child(username).once()).value;
    print(result);
    return result;
  }

  Color buttonColorCheck(Set<MaterialState> states){
    const Set<MaterialState> interactiveStates = <MaterialState>{
      MaterialState.pressed,
      MaterialState.hovered,
      MaterialState.focused,
      MaterialState.dragged,
    };
    if (states.any(interactiveStates.contains)) {
      return AppColors.buttonColorPressed;
    }
    return AppColors.buttonColor;
  }

  final _formKey = GlobalKey<FormState>();
  String email = "";
  String password = "";
  String username = "";
  RegExp regex = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~-]).{8,}$');

  Widget build(BuildContext context) {

    //final _firebaseUser = context.watch<User>();

    //if(_firebaseUser != null){
    //  return Text("Signed in");
    //}
    //else{
    //  return Text("Not signed in");
    //}

    //return MultiProvider(
    //  providers: [
    //    Provider<AuthenticationService>(create: (_) => AuthenticationService(FirebaseAuth.instance),),
    //    StreamProvider(create: (context) => context.read<AuthenticationService>().authStateChanges, initialData: null,),
    //  ],

      return Scaffold(
        appBar: AppBar(
          title: Text("Register Page"),
          backgroundColor: AppColors.logoColor,
          centerTitle: true,
        ),
        body: Center(
            child: Form(
              key: _formKey,
              child: Padding(
                padding: AppDimensions.padding20,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/unite_logo.png', height: 150, width: 150,),
                      SizedBox(height: 20.0,),
                      Text("UNIte", style: AppStyles.appNamePage,),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Email",
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(0.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else if (!EmailValidator.validate(value)) {
                            return 'Please enter a valid email address';
                          }
                          else {
                            email = value;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Username",
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(0.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else {
                            username = value;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0,),
                      TextFormField(
                        obscureText: true,
                        textAlign: TextAlign.center,
                        decoration: new InputDecoration(
                          hintText: "Enter Password",
                          fillColor: Colors.black,
                          border: new OutlineInputBorder(
                            borderRadius: new BorderRadius.circular(0.0),
                            borderSide: new BorderSide(),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else if (value.length < 8) {
                            return 'Password length cannot be less than 8 characters';
                          }
                          else if (!regex.hasMatch(value)) {
                            return 'Password should include an uppercase letter, a lowercase\n  letter, one digit and a special character';
                          }
                          else {
                            password = value;
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0,),
                      ElevatedButton(
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.resolveWith(
                                buttonColorCheck)),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {

                            await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

                            List<String> indexList = [];

                            for(int i = 1; i <= username.length; i++){
                              indexList.add(username.substring(0, i).toLowerCase());
                            }

                            //await FirebaseFirestore.instance.collection('users').add({'username' : username, 'searchKey': indexList});    //.add({'username' :username});

                            setState(() {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Signed Up Successfully!')),
                              );
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginPage()),
                              );
                            });
                            //database.child('users/').child(username).set({'email': email, 'password': password})
                            //    .onError((error, stackTrace) => print("There is an error of setting the email and password to Firebase dB"));
                          }
                        },
                        child: const Text(
                          'Sign Up', style: TextStyle(fontSize: 16),),
                      ),
                    ],
                  ),
                ),
              ),
            )
        ),
      );
    //);
  }
}