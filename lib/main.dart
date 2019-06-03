import 'dart:async';

import 'package:admin_sungkawa/pages/about.dart';
import 'package:admin_sungkawa/pages/admin_home.dart';
import 'package:admin_sungkawa/pages/introslider.dart';
import 'package:admin_sungkawa/pages/login.dart';
import 'package:admin_sungkawa/pages/post_add.dart';
import 'package:admin_sungkawa/pages/superadmin_menu.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
      routes: {
        'loginScreen': (BuildContext context) => Login(),
        'postAdd': (context) => PostAdd(),
      },
    );
  }
}

class _DashboardScreenState extends State<DashboardScreen> {
  AuthStatus _authStatus;
  var connectionStatus;
  GoogleSignInAccount gsa;
  SharedPreferences prefs;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notifikasi> notif = [];
  DatabaseReference currentAdminRef;

  bool isSuperAdmin;

  StreamSubscription<Event> _onAdminStatusChangeSub;
  StreamSubscription<Event> _onAdminStatusRemoveSub;

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
    isSuperAdmin = prefs.getBool('isSuperAdmin');
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

  Future checkSuperAdmin() async {
    prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString('userId') ?? '';
    currentAdminRef =
        FirebaseDatabase.instance.reference().child('admins').child(userId);
    _onAdminStatusChangeSub =
        currentAdminRef.onChildChanged.listen(_onAdminStatusChange);
    _onAdminStatusRemoveSub =
        currentAdminRef.onChildRemoved.listen(_onAdminStatusRemove);
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

    _onAdminStatusChangeSub.cancel();
    _onAdminStatusRemoveSub.cancel();
//    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }

  void _onAdminStatusChange(Event event) {
    String userRole = event.snapshot.value;
    print('User Role : $userRole');
    if (userRole == 'Admin') {
      setState(() {
        prefs.setBool('isSuperAdmin', false);
      });
    } else if (userRole == 'Superadmin') {
      setState(() {
        prefs.setBool('isSuperAdmin', true);
      });
    }
  }

  void _onAdminStatusRemove(Event event) {
    signOut();
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
