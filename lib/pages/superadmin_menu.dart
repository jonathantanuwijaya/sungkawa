import 'dart:async';

import 'package:admin_sungkawa/model/admin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class SuperAdminMenu extends StatefulWidget {
  @override
  _SuperAdminMenuState createState() => _SuperAdminMenuState();
}

class _SuperAdminMenuState extends State<SuperAdminMenu> {
  List<Admin> _adminList = new List();
  DatabaseReference _adminRef =
  FirebaseDatabase.instance.reference().child('admins');

  StreamSubscription<Event> _onAdminAddedSubscription;
  StreamSubscription<Event> _onAdminChangedSubscription;
  StreamSubscription<Event> _onAdminRemovedSubscription;

  @override
  void initState() {
    _adminList.clear();
    _onAdminAddedSubscription = _adminRef.onChildAdded.listen(_onAdminAdded);
    _onAdminChangedSubscription =
        _adminRef.onChildChanged.listen(_onAdminChanged);
    _onAdminRemovedSubscription =
        _adminRef.onChildRemoved.listen(_onAdminRemoved);
    _adminList.sort((a, b) => b.role.compareTo(a.role));

    super.initState();
  }

  _onAdminAdded(Event event) {
    setState(() {
      _adminList.add(Admin.fromSnapshot(event.snapshot));
      _adminList.sort((a, b) => b.role.compareTo(a.role));
    });
  }

  _onAdminChanged(Event event) {
    var oldEntry = _adminList.singleWhere((entry) {
      return entry.uid == event.snapshot.key;
    });

    setState(() {
      _adminList[_adminList.indexOf(oldEntry)] =
          Admin.fromSnapshot(event.snapshot);
      _adminList.sort((a, b) => b.role.compareTo(a.role));
    });
  }

  _onAdminRemoved(Event event) {
    var deletedEntry = _adminList.singleWhere((entry) {
      return entry.uid == event.snapshot.key;
    });
    print('on child removed called');
    setState(() {
      _adminList.remove(deletedEntry);
    });
  }

  @override
  void dispose() {
    super.dispose();
    _adminList.clear();
    _onAdminAddedSubscription.cancel();
    _onAdminChangedSubscription.cancel();
    _onAdminRemovedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Menu'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
//          return ListTile(
//            isThreeLine: true,
//            trailing: Row(
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                buildChangeStatusButton(_adminList[index].role),
//                IconButton(
//                  icon: Icon(Icons.remove_circle),
//                  onPressed: null,
//                  tooltip: 'Remove Admin',
//                )
//              ],
//            ),
//            title: Text(_adminList[index].nama),
//            subtitle: Column(
//              mainAxisAlignment: MainAxisAlignment.start,
//              crossAxisAlignment: CrossAxisAlignment.start,
//              mainAxisSize: MainAxisSize.min,
//              children: <Widget>[
//                Text('Role : ${_adminList[index].role}'),
//                Text('Tempat : ${_adminList[index].tempat}')
//              ],
//            ),
//          );
          return Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _adminList[index].nama,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      Text('Role : ${_adminList[index].role}'),
                      SizedBox(
                        height: 3,
                      ),
                      Text('Tempat : ${_adminList[index].tempat}'),
                      Row(
                        children: <Widget>[
                          buildChangeStatusButton(_adminList[index].role),
                          FlatButton.icon(
                              textColor: Colors.red,
                              onPressed: () {},
                              icon: Icon(Icons.remove_circle),
                              label: Text('Hapus'))
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: _adminList.length,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.person_add),
          tooltip: 'Tambah Admin',
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  return Dialog(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          decoration: InputDecoration(labelText: 'Nama'),
                        ),
                        TextField(
                          decoration: InputDecoration(labelText: 'Tempat'),
                        )
                      ],
                      mainAxisSize: MainAxisSize.min,
                    ),
                  );
                });
          }),
    );
  }

  FlatButton buildChangeStatusButton(role) {
    if (role == 'Admin') {
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_down),
        onPressed: () {},
        label: Text('Turunkan'),
      );
    } else
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_up),
        onPressed: () {},
        label: Text('Naikkan'),
      );
  }
}
