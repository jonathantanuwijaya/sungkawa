import 'package:admin_sungkawa/pages/introslider.dart';
import 'package:flutter/material.dart';

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
