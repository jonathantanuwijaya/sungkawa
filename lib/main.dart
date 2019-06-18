import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sungkawa/model/Notifikasi.dart';
import 'package:sungkawa/pages/about.dart';
import 'package:sungkawa/pages/introslider.dart';
import 'package:sungkawa/pages/login.dart';
import 'package:sungkawa/pages/profil.dart';
import 'package:sungkawa/pages/user_home.dart';

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
      title: 'Sungkawa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryTextTheme: TextTheme(title: TextStyle(color: Colors.white)),
        primaryIconTheme: IconThemeData(color: Colors.white),
        primarySwatch: Colors.lightBlue,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: IntroSlider(),
    );
  }
}

enum Pilihan { about, signOut, profil }

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  SharedPreferences prefs;
  bool isLoading;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  var connectionStatus;
  final List<Notifikasi> notif = [];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
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
                  builder: (context) => CupertinoActionSheet(
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
                        buildAuthButton(),
                      ],
                      cancelButton: CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                          ))));
            },
          )
        ],
        backgroundColor: Colors.lightBlue,
      ),
      body: HomePage(),
    );
  }

  CupertinoActionSheetAction buildAuthButton() {
    if (_authStatus == AuthStatus.signedIn) {
      return CupertinoActionSheetAction(
          isDestructiveAction: true,
          onPressed: signOut,
          child: Text(
            'Sign Out',
          ));
    } else if (_authStatus == AuthStatus.notSignedIn) {
      return CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => Login(),
              ),
            );
          },
          child: Text('Sign In'));
    } else
      return null;
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

  Future<String> getCurrentUser() async {
    try {
      FirebaseUser user = await FirebaseAuth.instance.currentUser();
      return user != null ? user.uid : null;
    } catch (e) {
      print('Error: $e');
      return null;
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

  void initFCM() {
    _firebaseMessaging.onTokenRefresh.listen(sendTokenToServer);
    _firebaseMessaging.getToken();
    _firebaseMessaging.subscribeToTopic('all');
    _firebaseMessaging.configure(
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
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

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
    initFCM();
  }

  void sendTokenToServer(String fcm) {
    print('Token : $fcm');
  }

  void signOut() async {
    prefs = await SharedPreferences.getInstance();
    prefs.setString("nama", '');
    prefs.setString("email", '');
    prefs.setString("userId", '');

    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;

    Navigator.pop(context);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
  }
}
