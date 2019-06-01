import 'dart:async';

import 'package:admin_sungkawa/pages/about.dart';
import 'package:admin_sungkawa/pages/admin_home.dart';
import 'package:admin_sungkawa/pages/introslider.dart';
import 'package:admin_sungkawa/pages/login.dart';
import 'package:admin_sungkawa/pages/post_add.dart';
import 'package:admin_sungkawa/pages/superadmin_menu.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/Notifikasi.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
      .then((_) {
    runApp(MyApp());
  });
}

final GoogleSignIn googleSignIn = GoogleSignIn();

enum AuthStatus { signedIn, notSignedIn }

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Sungkawa',
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primarySwatch: Colors.green,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      home: Opening(),
    );
  }
}

enum Pilihan { about, signOut }

class _DashboardScreenState extends State<DashboardScreen> {
  AuthStatus _authStatus;
  var connectionStatus;
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notifikasi> notif = [];

  bool isSuperAdmin;

  @override
  // ignore: missing_return
  Widget build(BuildContext context) {
    switch (_authStatus) {
      case AuthStatus.notSignedIn:
        return Login();

      case AuthStatus.signedIn:
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
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
                      builder: (context) => buildCupertinoActionSheet(context));
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

  CupertinoActionSheet buildCupertinoActionSheet(BuildContext context) {
    return CupertinoActionSheet(
        title: const Text(
          'Pilihan menu',
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => About()));
              },
              child: Text('Tentang Kami')),
          if (isSuperAdmin == true)
            CupertinoActionSheetAction(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SuperAdminMenu()));
                },
                child: Text('Super Admin Menu')),
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
            )));
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
  void initState() {
    // TODO: implement initState
    checkConnectivity();
    getCurrentUser().then((userId) {
      setState(() {
        _authStatus =
            userId == null ? AuthStatus.notSignedIn : AuthStatus.signedIn;
      });
    });
    initFCM();
    checkSuperAdmin();
    super.initState();
  }

  void initFCM() {
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        final notification = message['notification'];
        setState(() {
          notif.add(Notifikasi(
            title: notification['title'],
            nama: notification['body'],
          ));
        });
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");

        final notification = message['data'];
        setState(() {
          notif.add(Notifikasi(
            title: '${notification['title']}',
            nama: '${notification['body']}',
          ));
        });
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  void sendTokenToServer(String fcm) {
    print('Token : $fcm');
  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;

    prefs.remove('userId');
    prefs.remove('nama');
    prefs.remove('email');

//    Navigator.pop(context);
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

  Future checkSuperAdmin() async {
    prefs = await SharedPreferences.getInstance();
    isSuperAdmin = prefs.getBool('isSuperAdmin');
  }
}
