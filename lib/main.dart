import 'dart:async';

import 'package:sung/pages/about.dart';
import 'package:sung/pages/admin_home.dart';
import 'package:sung/pages/login.dart';
import 'package:sung/pages/post_add.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

enum Pilihan { about, signOut }

final GoogleSignIn googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sungkawa',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.green,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      home: DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

enum AuthStatus { signedIn, notSignedIn }

class _DashboardScreenState extends State<DashboardScreen> {
  AuthStatus _authStatus;
  var connectionStatus;
  SharedPreferences prefs;
  GoogleSignIn user;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkConnectivity();
    getCurrentUser().then((userId) {
      setState(() {
        _authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
  }

  Future<String> getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user.uid;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return Login();

      case AuthStatus.signedIn:
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Sungkawa',
              textAlign: TextAlign.center,
            ),
            actions: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white,
                ),
                onPressed: () {
                  showCupertinoModalPopup(
                      context: context,
                      builder: (context) => CupertinoActionSheet(
                          title: const Text(
                            'Pilihan menu',
                          ),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                                onPressed: () {
                                  Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => About()));
                                },
                                child: Text('Tentang Kami')),
                            CupertinoActionSheetAction(
                                isDestructiveAction: true,
                                onPressed: signOut,
                                child: Text(
                                  'Sign Out',
                                )),
                          ],
                          cancelButton: CupertinoActionSheetAction(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ))));
                },
              )
            ],
            backgroundColor: Colors.green,
          ),
          body: HomePage(),
          floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add),
              backgroundColor: Colors.green,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => PostAdd()));
              }),
        );

      default:
        return Center(
          child: CircularProgressIndicator(),
        );
    }
  }

//  void selectedAction(Pilihan value) {
//    print('You choose : $value');
//    if (value == Pilihan.about) {
//      Navigator.push(context,
//          MaterialPageRoute(builder: (BuildContext context) => About()));
//    }
//    if (value == Pilihan.signOut) {
//      signOut();
//    }
//  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  static Future<bool> checkConnectivity() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile) {
      print('Connectivity Result: $connectivityResult');
      return true;
    } else if (connectivityResult == ConnectivityResult.wifi) {
      print('Connectivity Result: $connectivityResult');
      return true;
    } else {
      print('Connectivity Result: not connected');
      return false;
    }
  }
}
