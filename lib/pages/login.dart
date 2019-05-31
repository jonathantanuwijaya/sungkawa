import 'dart:async';

import 'package:admin_sungkawa/main.dart';
import 'package:admin_sungkawa/utilities/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  GoogleSignInAuthentication googleAuth;
  bool isNotAdmin;
  bool isSuperAdmin;
  bool isNewAdmin;

  AuthCredential get credential =>
      GoogleAuthProvider.getCredential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

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
            Image.asset(
              'assets/images/icon_android.png',
              fit: BoxFit.scaleDown,
              width: 100,
              height: 100,
            ),
            SizedBox(
              height: 110,
            ),
            new Text(
              'Sungkawa',
              style: TextStyle(fontSize: 40.0),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10.0,
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
            SizedBox(
              height: 200,
            ),
            new Padding(padding: const EdgeInsets.all(10.0)),
          ],
        ),
      ),
    );
  }

  Future checkAdmin(GoogleSignInAccount googleAccount) async {
    DatabaseReference adminTempRef;
    DatabaseReference adminRef;

    try {
      try {
        adminTempRef = FirebaseDatabase.instance
            .reference()
            .child('admintemp')
            .child(googleAccount.email);
      } finally {
        if (adminTempRef != null) {
          print('Data exists in Admin Temp');
          adminTempRef.once().then((snapshot) {
            if (snapshot.key != null) {
              crud.addAdmin(googleAccount.id, {
                'tempat': snapshot.value['tempat'],
                'userId': googleAccount.id,
                'email': googleAccount.email,
                'nama': googleAccount.displayName,
                'superAdmin': false,
                'role': 'Admin'
              });
              isNotAdmin = false;
              isNewAdmin = true;
            } else {}
          }).catchError((e) {
            print(e);
          });
        }
      }

      try {
        adminRef = FirebaseDatabase.instance
            .reference()
            .child('admins')
            .child(googleAccount.id);
      } finally {
        if (adminRef != null) {
          adminRef.once().then((snapshot) {
            if (snapshot.key != null) {
              if (snapshot.value['superAdmin'] == true) {
                isSuperAdmin = true;
              } else {
                isSuperAdmin = false;
                isNotAdmin = false;
              }
            } else {
              isNotAdmin = true;
              print(snapshot.value);
            }
          }).catchError((e) {
            print(e);
          });
        }
      }
    } finally {
      print('Is Not Admin : $isNotAdmin');
      print('is New Admin : $isNewAdmin');
      print('Super Admin : $isSuperAdmin');

      prefs.setString('userId', googleAccount.id);
      prefs.setString('email', googleAccount.email);
      prefs.setBool('isSuperAdmin', isSuperAdmin);

      if (isNewAdmin == true) adminTempRef.remove();

      if (isNotAdmin == true) {
        Fluttertoast.showToast(msg: 'Anda tidak terdaftar sebagai admin');
        googleSignIn.signOut();
      } else {
        firebaseAuth.signInWithCredential(credential).whenComplete(() {
          if (isNewAdmin == true) {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                result: 'Welcome to Sungkawa ${googleAccount.displayName}');
          } else {
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()),
                result: 'Welcome back, ${googleAccount.displayName}');
          }
        });
      }
    }
  }

  Future handleSignIn() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    prefs = await SharedPreferences.getInstance();

    googleAuth = await googleAccount.authentication;

    checkAdmin(googleAccount);
  }
}
