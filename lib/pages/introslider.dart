import 'dart:async';

import 'package:admin_sungkawa/main.dart';
import 'package:flutter/material.dart';
import 'package:intro_views_flutter/Models/page_view_model.dart';
import 'package:intro_views_flutter/intro_views_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;

class IntroSliderScreen extends StatefulWidget {
  static TextStyle style = TextStyle(fontSize: 28.0);

  @override
  _IntroSliderScreenState createState() => _IntroSliderScreenState();
}

class Opening extends StatefulWidget {
  @override
  _OpeningState createState() => _OpeningState();
}

class _IntroSliderScreenState extends State<IntroSliderScreen> {
  final pages = [
    PageViewModel(
        title: Text(
          '',
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
        bubble: Image.asset('assets/images/welcome.png'),
        pageColor: Colors.blue,
        body: Text('Welcome to Sungkawa '),
        mainImage: Image.asset('assets/images/welcome.png'),
        textStyle: TextStyle(color: Colors.white)),
    PageViewModel(
        title: Text(
          '',
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
        bubble: Image.asset(
          'assets/images/phone.png',
        ),
        pageColor: Colors.orange,
        body: Text('Ucapan belasungkawa yang interaktif '),
        mainImage: Image.asset('assets/images/phone.png'),
        textStyle: TextStyle(color: Colors.white)),
    PageViewModel(
        title: Text(
          '',
          overflow: TextOverflow.fade,
          maxLines: 1,
          softWrap: false,
        ),
        bubble: Image.asset('assets/images/speed.png'),
        pageColor: Colors.purpleAccent,
        body: Text('Informasi yang selalu realtime '),
        mainImage: Image.asset('assets/images/speed.png'),
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
                  prefs.setBool('cek', true);
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

class _OpeningState extends State<Opening> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }

  Future checkFirstScreen() async {
    prefs = await SharedPreferences.getInstance();

    bool _cek = (prefs.getBool('cek') ?? false);

    if (_cek) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => DashboardScreen()));
    } else {
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
}
