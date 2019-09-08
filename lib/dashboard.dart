import 'dart:async';

import 'package:admin_sungkawa/auth.dart';
import 'package:admin_sungkawa/model/Notifikasi.dart';
import 'package:admin_sungkawa/pages/about.dart';
import 'package:admin_sungkawa/pages/admin_home.dart';
import 'package:admin_sungkawa/pages/introslider.dart';
import 'package:admin_sungkawa/pages/post_add.dart';
import 'package:admin_sungkawa/pages/superadmin_menu.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  var connectionStatus;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notifikasi> notif = [];
  DatabaseReference currentAdminRef;

  bool isSuperAdmin;

  @override
  Widget build(BuildContext context) {
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
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => PostAdd()));
          }),
    );
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
              onPressed: () {
                authService.signOut();
                Navigator.of(context).pop();
              },
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

    initFCM();
    super.initState();
  }

  void sendTokenToServer(String fcm) {
    print('Token : $fcm');
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
