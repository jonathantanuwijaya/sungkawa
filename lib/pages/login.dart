import 'dart:async';
import 'package:Sungkawa/main.dart';
import 'package:Sungkawa/utilities/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GoogleSignIn googleSignIn = GoogleSignIn();
  CRUD crud = new CRUD();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  SharedPreferences prefs;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: new Padding(
        padding: const EdgeInsets.all(20.0),
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            new Text(
              'Sungkawa',
              style: TextStyle(fontSize: 40.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 5.0,
            ),
            CupertinoButton(
                child: Text(
                  "Sign In with Google",
                  style: new TextStyle(color: Colors.white),
                ),
                color: Colors.blue,
                onPressed: () {
//                  login();
                  handleSignIn();
                }),
            new Padding(padding: const EdgeInsets.all(10.0)),
          ],
        ),
      ),
    );
  }

  Future handleSignIn() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    prefs = await SharedPreferences.getInstance();

    prefs.setString('userId', googleAccount.id);
    prefs.setString('nama', googleAccount.displayName);
    prefs.setString('email', googleAccount.email);

    firebaseAuth.signInWithCredential(credential).whenComplete(() {
      addToDatabase(googleAccount);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    });
  }

  Future addToDatabase(GoogleSignInAccount googleAccount) async {
    print('Adding to database');
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(googleAccount.id)
        .once()
        .then((snapshot) {
      if (snapshot.value == null) {
        print('Added to database');
        crud.addUser(googleAccount.id, {
          'userid': googleAccount.id,
          'nama': googleAccount.displayName,
          'email': googleAccount.email
        });
      }
    });
  }
}
