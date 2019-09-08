import 'package:admin_sungkawa/auth.dart';
import 'package:admin_sungkawa/crud.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
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
                  handleLogin(context);
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

  Future handleLogin(BuildContext context) async {
    await authService.googleSignIn().then(
          (u) => rtdbService.checkAdminExist(u).then(
            (exists) {
              if (!exists) {
                authService.signOut();
                Scaffold.of(context).showSnackBar(SnackBar(
                  content: Text('Tidak ada admin'),
                ));
              }
            },
          ),
        );
  }
}
