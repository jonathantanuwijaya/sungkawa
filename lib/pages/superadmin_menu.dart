import 'package:firebase_database/firebase_database.dart';
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
      body: StreamBuilder(
          stream:
              FirebaseDatabase.instance.reference().child('admintemp').onValue,
          builder: (context, snapshot) {
            ListView.builder(
              itemBuilder: (context, index) {
                if (snapshot.hasData) {
                  if (snapshot.data != null) {
                    Map<dynamic, dynamic> map = snapshot.data;
                    list = map.values.toList();
                    ListTile(
                      title: Text(list[index]['email']),
                      subtitle: Row(
                        children: <Widget>[
                          IconButton(
                              color: Colors.green,
                              icon: Icon(Icons.check),
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('admins')
                                    .set({
                                  'userName': list[index]['userName'],
                                  'email': list[index]['email'],
                                  'role': 'Admin'
                                });
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('admintemp')
                                    .child(list[index])
                                    .remove();
                                setState(() {
                                  list.remove(index);
                                });
                              }),
                          IconButton(
                              color: Colors.red,
                              icon: Icon(Icons.close),
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('admintemp')
                                    .child(list[index])
                                    .remove();

                                setState(() {
                                  list.remove(index);
                                });
                              })
                        ],
                      ),
                    );
                  }
                }
              },
              itemCount: list.length,
            );
          }),
    );
  }
}
