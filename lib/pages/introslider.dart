import 'package:flutter/material.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sung/main.dart';
import 'dart:async';

class Opening extends StatefulWidget {
  @override
  _OpeningState createState() => _OpeningState();
}

class _OpeningState extends State<Opening> {
  Future checkFirstScreen() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _cek = (prefs.getBool('cek') ?? false);

    if (_cek) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
      prefs.setBool('cek', true);
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => IntroSliderScreen()));
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    checkFirstScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

class IntroSliderScreen extends StatefulWidget {
  static TextStyle style = TextStyle(fontSize: 28.0);

  @override
  _IntroSliderScreenState createState() => _IntroSliderScreenState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {

  final pages = [
    PageViewModel(
        title: Text('Halaman Pertama Intro '),
        bubble: Image.asset('assets/images/mario.jpg'),
        pageColor: Colors.blue,
        body: Text('Welcome to Halaman 1 '),
        mainImage: Image.asset('assets/images/mario.jpg'),
        textStyle: TextStyle(color: Colors.white)),
    PageViewModel(
        title: Text('Halaman Kedua Intro '),
        bubble: Image.asset('assets/images/mr_bean.png'),
        pageColor: Colors.orange,
        body: Text('Welcome to Halaman 1 '),
        mainImage: Image.asset('assets/images/mr_bean.png'),
        textStyle: TextStyle(color: Colors.white)),
    PageViewModel(
        title: Text('Halaman Ketiga Intro '),
        bubble: Image.asset('assets/images/garfield.jpeg'),
        pageColor: Colors.purpleAccent,
        body: Text('Welcome to Halaman 1 '),
        mainImage: Image.asset('assets/images/garfield.jpeg'),
        textStyle: TextStyle(color: Colors.white)),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Builder(
          builder: (context) => IntroViewsFlutter(
                pages,
                onTapDoneButton: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => DashboardScreen()));
                },
                pageButtonTextStyles:
                    TextStyle(color: Colors.white, fontSize: 18.0),
              )),
    );
  }
}
