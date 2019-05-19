import 'package:Sungkawa/pages/about.dart';
import 'package:Sungkawa/pages/introslider.dart';
import 'package:Sungkawa/pages/login.dart';
import 'package:Sungkawa/pages/profil.dart';
import 'package:Sungkawa/pages/user_home.dart';
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

enum Pilihan { about, signOut, profil }

final GoogleSignIn googleSignIn = GoogleSignIn();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SUNGKAWA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primarySwatch: Colors.lightBlue,
          pageTransitionsTheme: PageTransitionsTheme(builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          })),
      home: Opening(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

enum AuthStatus { signedIn, notSignedIn }

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  FirebaseUser currentUser;
  SharedPreferences prefs;
  bool isLoading;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  var connectionStatus;
  final List<Notifikasi> notif = [];

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
    }).whenComplete(() {
      String displayName = googleSignIn.currentUser.displayName;
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('User $displayName is signed in!')));
    });
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

  Future<String> getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user != null ? user.uid : null;
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sungkawa',
          style: TextStyle(color: Colors.white),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {
              showCupertinoModalPopup(
                  context: context,
                  builder: (context) =>
                      CupertinoActionSheet(
                          title: const Text(
                            'Pilihan menu',
                          ),
                          actions: <Widget>[
                            CupertinoActionSheetAction(
                              onPressed: () {
                                switch (_authStatus) {
                                  case AuthStatus.notSignedIn:
                                    handleSignIn().then((_) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Profil()));
                                    });
                                    break;
                                  case AuthStatus.signedIn:
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Profil()));
                                    break;
                                }
                              },
                              child: Text('Profil'),
                            ),
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
        backgroundColor: Colors.lightBlue,
      ),
      body: HomePage(),
    );
  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;

    prefs = await SharedPreferences.getInstance();
    prefs.setString('userId', '');
    prefs.setString('nama', '');
    prefs.setString('email', '');
//    SnackBar(
//      content: Text('Signed Out'),
//      duration: Duration(seconds: 2),
//    );
    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
//      .whenComplete((){
//      Fluttertoast.showToast(
//          msg: "Signed Out",
//          toastLength: Toast.LENGTH_SHORT,
//          gravity: ToastGravity.CENTER,
//          timeInSecForIos: 1,
//          backgroundColor: Colors.black,
//          textColor: Colors.white,
//          fontSize: 16.0);
//    });
  }

  void checkConnectivity() async {
    try {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.mobile) {
        print('Connectivity Result: $connectivityResult');
        connectionStatus = true;
      } else if (connectivityResult == ConnectivityResult.wifi) {
        print('Connectivity Result: $connectivityResult');
        connectionStatus = true;
      } else {
        print('Connectivity Result: not connected');
        connectionStatus = false;
      }
    } catch (e) {
      print('Error: $e');
    }
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

    _auth.signInWithCredential(credential).whenComplete(() {
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

  void sendTokenToServer(String fcm) {
    print('Token : $fcm');
  }
}
