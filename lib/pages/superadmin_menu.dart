import 'package:flutter/material.dart';

class SuperAdminMenu extends StatefulWidget {
  @override
  _SuperAdminMenuState createState() => _SuperAdminMenuState();
}

class _SuperAdminMenuState extends State<SuperAdminMenu> {
  List<dynamic> list;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Menu'),
      ),
      body: PageView(
        children: <Widget>[ListView.builder(itemBuilder: (context, index) {})],
        scrollDirection: Axis.horizontal,
        onPageChanged: (int) {},
      ),
    );
  }
}
