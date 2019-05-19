import 'package:Sungkawa/model/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profil extends StatefulWidget {
  final User pengguna;
  final String currentUserId;

  Profil({this.pengguna, this.currentUserId});

  @override
  _ProfilState createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  String username = '', email = '', userid = '';
  SharedPreferences prefs;
  FirebaseUser currentUser;
  bool isLoading = false;
  TextEditingController usernameController;
  TextEditingController emailController;

  var userRef;
  final FocusNode focusNodeUsername = new FocusNode();
  final FocusNode focusNodeEmail = new FocusNode();
  final formkey = GlobalKey<FormState>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    readLocal();
  }

  void readLocal() async {
    prefs = await SharedPreferences.getInstance();
    userid = prefs.getString('userId') ?? '';
    username = prefs.getString('nama') ?? '';
    email = prefs.getString('email') ?? '';
    print('username = $username');
    setState(() {
      usernameController = new TextEditingController(text: username);
      emailController = new TextEditingController(text: email);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profil',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.only(top: 6.0, left: 14.0, right: 14.0),
        child: Form(
          key: formkey,
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: Container(
                      width: 70.0,
                      height: 20.0,
                      child: Text(
                        'Nama : ',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    child: TextField(
                      decoration:
                          InputDecoration(hintText: 'Usename harus diisi'),
                      controller: usernameController,
                      onChanged: (value) => username = value,
                      focusNode: focusNodeUsername,
                    ),
                  )),
                ],
              ),
              Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 22.0),
                    child: Container(
                      width: 70.0,
                      child: Text(
                        'Email :',
                        style: TextStyle(fontSize: 20.0),
                      ),
                    ),
                  ),
                  Expanded(
                      child: Container(
                          child: TextField(
                    controller: emailController,
                    onChanged: (value) => email = value,
                    focusNode: focusNodeEmail,
                    enabled: false,
                  ))),
                ],
              ),
              SizedBox(
                height: 50.0,
              ),
              CupertinoButton(
                onPressed: handleUpdateData,
                child: Text(
                  'Update Profil',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w300),
                ),
                color: Colors.blue[700],
              )
            ],
          ),
        ),
      ),
    );
  }

  void handleUpdateData() async {
    focusNodeUsername.unfocus();
    focusNodeEmail.unfocus();

    setState(() {
      isLoading = true;
    });
    var userRef =
        FirebaseDatabase.instance.reference().child('users').child(userid);
    userRef.update({'username': username, 'email': email}).then((data) async {
      print('username == ${username}');
      await prefs.setString('userid', userid);
      await prefs.setString('username', username);
      await prefs.setString('email', email);
    }).whenComplete(() {
      Fluttertoast.showToast(
          msg: "Update Success",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
