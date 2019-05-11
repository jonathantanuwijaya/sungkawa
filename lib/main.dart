import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sung_user/pages/about.dart';
import 'package:sung_user/pages/introslider.dart';
import 'package:sung_user/pages/user_home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sung_user/pages/login.dart';
import 'package:connectivity/connectivity.dart';
import 'package:flutter/services.dart';
import 'package:sung_user/pages/profil.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  var connectionStatus;

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
            icon: Icon(Icons.more_vert,color: Colors.white),
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
                                handleSignIn().then((_){
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Profil()));
                                });
                                break;
                              case AuthStatus.signedIn:
                                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Profil()));
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

  void selectedAction(Pilihan value) {
    print('You choose : $value');
    if (value == Pilihan.about) {
      Navigator.push(context,
          MaterialPageRoute(builder: (BuildContext context) => About()));
    }
    if (value == Pilihan.signOut) {
      signOut();
    }
    if (value == Pilihan.profil) {
      switch (_authStatus) {
        case AuthStatus.notSignedIn:
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Login()));
          break;
        case AuthStatus.signedIn:
          print('Profil dibuka');
          Navigator.push(context,
              MaterialPageRoute(builder: (BuildContext context) => Profil()));
          break;
      }
    }
  }

  void signOut() async {
    FirebaseAuth.instance.signOut();
    googleSignIn.signOut();
    _authStatus = AuthStatus.notSignedIn;
//    Scaffold.of(_snackBarContext).showSnackBar(SnackBar(content: Text("Signed Out"),
//    duration: Duration(seconds: 2),));
    SnackBar(
      content: Text('Signed Out'),
      duration: Duration(seconds: 2),
    );

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (BuildContext context) => Login()));
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
        crud.addUser(googleAccount.id,
            {'userid':googleAccount.id,
              'nama': googleAccount.displayName, 'email': googleAccount.email});
      }
    });
  }

}
