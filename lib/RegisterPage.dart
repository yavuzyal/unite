import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  @override
  State<RegisterPage> createState() => _RegisterPage2();
}

class _RegisterPage2 extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register Page"), backgroundColor: Colors.lightBlueAccent, centerTitle: true,
      ),
      body: Center(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/unite_logo.png', height: 150, width: 150,),
                  SizedBox(height: 60.0,),
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
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
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
                      else if (value.length < 6){
                        return 'Password length cannot be less than 6';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0,),
                  TextFormField(
                    obscureText: true,
                    textAlign: TextAlign.center,
                    decoration: new InputDecoration(
                      hintText: "Enter Password Again",
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
                      else if (value.length < 6){
                        return 'Password length cannot be less than 6';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.0,),
                  ElevatedButton(
                    style: ButtonStyle( ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All done')),
                        );
                      }
                    },
                    child: const Text('Login', style: TextStyle(fontSize: 16),),
                  ),
                ],
              ),
            ),
          )
      ),

    );
  }
}
