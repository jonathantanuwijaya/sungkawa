import 'package:flutter/material.dart';

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tentang Aplikasi'),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.only(
          top: 50.0,
          left: 20.0,
          right: 20.0,
        ),
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Image.asset(
              'assets/images/logo_mdp.png',
              fit: BoxFit.cover,
              width: 280,
            ),
            SizedBox(
              height: 20.0,
            ),
            Text(
              'MDP Application Incubator',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              'Copyright \u00A9 2019',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Text(
              'Sungkawa',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              'Version 1.0',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            SizedBox(
              height: 60.0,
              width: MediaQuery.of(context).size.width - 100,
              child: Divider(
                color: Colors.green,
              ),
            ),
            Text(
              'Developers',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Text(
              '1. Jonathan Tanuwijaya',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              '2. Stephen Suhendra Kohar',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              '3. Alvin Leonardo Djoni',
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
            Text(
              '4. Ericco Andreas',
              style: TextStyle(
                fontSize: 16.0,
              ),
            )
          ],
        ),
      ),
    );
  }
}
