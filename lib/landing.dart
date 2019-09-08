import 'package:admin_sungkawa/dashboard.dart';
import 'package:admin_sungkawa/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Landing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseAuth.instance.onAuthStateChanged,
        builder: (context, snapshot) =>
            snapshot.hasData ? DashboardScreen() : Login());
  }
}
