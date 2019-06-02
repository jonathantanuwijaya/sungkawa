import 'dart:async';

import 'package:admin_sungkawa/utilities/crud.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

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
  String result;
  DatabaseReference adminTempRef;
  DatabaseReference adminRef;

  bool adminFound;

  AuthCredential get credential => GoogleAuthProvider.getCredential(
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
    print('Hash Code : ${googleAccount.email.hashCode.toString()}');
    adminRef = FirebaseDatabase.instance
        .reference()
        .child('admins')
        .child(googleAccount.id);
    adminTempRef = FirebaseDatabase.instance
        .reference()
        .child('admintemp')
        .child(googleAccount.email.hashCode.toString());

    try {
      prefs.setBool('isSuperAdmin', false);

      adminRef.once().then((snapshot) {
        print('${snapshot.key}');
        if (snapshot.key != null) {
          if (snapshot.value['role'] == 'Admin') {
          } else if (snapshot.value['role'] == 'Superadmin') {
            prefs.setBool('isSuperAdmin', true);
          }
          adminFound = true;
          result = 'Selamat datang kembali, ${googleAccount.displayName}';
        } else {
          adminFound = false;
        }
      }).catchError((e) {
        print('hoi');
      }).whenComplete(() {
        if (adminFound == true) {
          signInToMainMenu(googleAccount);
        } else {
          print('pbe');
          adminTempRef.once().then((snapshot) {
            print('${snapshot.value['email']}');
            if (snapshot.value['email'] == googleAccount.email) {
              adminRef.set({
                'email': snapshot.value['email'],
                'nama': googleAccount.displayName,
                'role': 'Admin',
                'tempat': snapshot.value['tempat'],
                'userid': googleAccount.id
              });
              adminFound = true;
              result =
                  'Selamat Datang di Sungkawa, ${googleAccount.displayName}';
            } else {
              adminFound = false;
            }
          }).catchError((e) {
            print(e);
          }).whenComplete(() {
            signInToMainMenu(googleAccount);
          });
        }
      });
    } catch (e) {
      print(e);
    }
  }

  Future handleSignIn() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    prefs = await SharedPreferences.getInstance();

    googleAuth = await googleAccount.authentication;

    checkAdmin(googleAccount);
  }

  void signInToMainMenu(GoogleSignInAccount googleAccount) {
    print('Admin : $adminFound');
    print('Super Admin : ${prefs.getBool('isSuperAdmin')}');
    prefs.setString('userId', googleAccount.id);

    if (adminFound == true) {
      adminTempRef.remove();
      FirebaseAuth.instance.signInWithCredential(credential).whenComplete(() {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => DashboardScreen()),
            result: result);
      });
    } else {
      Fluttertoast.showToast(msg: 'Anda tidak terdaftar sebagai admin');
      googleSignIn.signOut();
    }
  }
}
