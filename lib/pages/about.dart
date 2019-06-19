import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var textShadow = <Shadow>[
      Shadow(
          blurRadius: 5,
          color: Color.fromARGB(255, 0, 0, 0),
          offset: Offset(1, 1))
    ];
    var textColor = Colors.yellow;
    var bigText = TextStyle(
      shadows: textShadow,
      color: textColor,
      fontSize: 16.0,
    );
    var smallText = TextStyle(
      shadows: textShadow,
      color: textColor,
    );

    var headerText = TextStyle(
      shadows: textShadow,
      color: textColor,
      fontWeight: FontWeight.bold,
      fontSize: 20.0,
    );

    Timer(Duration(seconds: 60), () {
      print('60 secs has passed');
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: Text('The Journey'),
                content: Text('Death is not a hunter unbeknowst to its prey.\n'
                    'One is always aware that it lies in wait.\n'
                    'Though life is merely a journey to the grave, it must not be undertaken without hope.\n'
                    'Only then will a traveler\'s story live on, treasured by those who bid him farewell.\n'
                    'But alas, my guest\'s life has now ended, his tale left unwritten...'),
              ));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
      ),
      body: Container(
        padding: EdgeInsets.only(
          top: 50.0,
          left: 20.0,
          right: 20.0,
        ),
        width: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            fit: BoxFit.fill,
            image: AssetImage('assets/images/gedung_mdp.jpg'),
          ),
        ),
        child: BackdropFilter(
          child: Container(
            decoration: BoxDecoration(color: Colors.white.withOpacity(0)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Image.asset(
                  'assets/images/logo_mdp.png',
                  fit: BoxFit.cover,
                  width: 280,
                ),
                SizedBox(height: 20),
                Text(
                  "Jalan Rajawali No 14, Palembang",
                  style: smallText,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  'www.mdp.ac.id',
                  style: smallText,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'MDP Application Incubator',
                  style: headerText,
                ),
                Text(
                  'Copyright \u00A9 2019',
                  style: bigText,
                ),
                SizedBox(
                  height: 30.0,
                ),
                Text(
                  'Sungkawa',
                  style: headerText,
                ),
                Text(
                  'Version 1.0',
                  style: bigText,
                ),
                SizedBox(
                  height: 60.0,
                  width: MediaQuery.of(context).size.width - 100,
                  child: Divider(
                    color: Colors.green,
                  ),
                ),
                Text('Developers', style: headerText),
                Text(
                  '1. Jonathan Tanuwijaya',
                  style: bigText,
                ),
                Text(
                  '2. Stephen Suhendra Kohar',
                  style: bigText,
                ),
                Text(
                  '3. Alvin Leonardo Djoni',
                  style: bigText,
                ),
                Text(
                  '4. Ericco Andreas',
                  style: bigText,
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Contact',
                  style: headerText,
                ),
                Text(
                  'Email : mdpic@mdp.ac.id',
                  style: smallText,
                ),
              ],
            ),
          ),
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
        ),
      ),
    );
  }
}
