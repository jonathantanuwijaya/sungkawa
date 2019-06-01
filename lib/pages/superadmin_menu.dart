import 'dart:async';

import 'package:admin_sungkawa/model/admin.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SuperAdminMenu extends StatefulWidget {
  @override
  _SuperAdminMenuState createState() => _SuperAdminMenuState();
}

class _SuperAdminMenuState extends State<SuperAdminMenu> {
  List<Admin> _adminList = new List();
  DatabaseReference _adminRef =
      FirebaseDatabase.instance.reference().child('admins');

  SharedPreferences prefs;
  StreamSubscription<Event> _onAdminAddedSubscription;
  StreamSubscription<Event> _onAdminChangedSubscription;
  StreamSubscription<Event> _onAdminRemovedSubscription;

  final _emailController = new TextEditingController();

  final _tempatController = new TextEditingController();

  final _formKey = new GlobalKey<FormState>();

  String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Super Admin Menu'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          sortAdminList();

          return Padding(
            padding: const EdgeInsets.only(left: 5, right: 5),
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    child: Column(
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
                        buildButtonRow(index)
                      ],
                    ),
                    padding: EdgeInsets.all(5),
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
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: <Widget>[
                            Center(
                              child: Text(
                                'Tambah Admin',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(labelText: 'Email'),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            TextFormField(
                              controller: _tempatController,
                              decoration: InputDecoration(labelText: 'Tempat'),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                FlatButton(
                                    onPressed: () {
                                      _formKey.currentState.save();

                                      FirebaseDatabase.instance
                                          .reference()
                                          .child('admintemp')
                                          .push()
                                          .set({
                                        'email': _emailController.text,
                                        'tempat': _tempatController.text,
                                      }).whenComplete(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                    child: Text('Tambah')),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: FlatButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('Batal')),
                                )
                              ],
                            )
                          ],
                          mainAxisSize: MainAxisSize.min,
                        ),
                      ),
                    ),
                  );
                });
          }),
    );
  }

  Widget buildButtonRow(int index) {
    if (currentUserId != _adminList[index].uid) {
      return Row(
        children: <Widget>[
          buildChangeStatusButton(
              _adminList[index].role, _adminList[index].uid),
          FlatButton.icon(
              textColor: Colors.red,
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) =>
                        CupertinoAlertDialog(
                          title: Text('Hapus Admin?'),
                          content: Text(
                              'Tindakan ini tidak dapat dipulihkan, lanjutkan>'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('Hapus'),
                              onPressed: () {},
                            ),
                            CupertinoDialogAction(
                              child: Text('Batal'),
                              isDestructiveAction: true,
                            )
                          ],
                        ));
              },
              icon: Icon(Icons.remove_circle),
              label: Text('Hapus'))
        ],
      );
    } else {
      return SizedBox(
        width: MediaQuery
            .of(context)
            .size
            .width - 28,
      );
    }
  }

  // ignore: missing_return
  Widget buildChangeStatusButton(role, String uid) {
    if (role == 'Superadmin' && currentUserId != uid) {
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_down),
        onPressed: () {
          FirebaseDatabase.instance
              .reference()
              .child('admins')
              .child(uid)
              .update({'role': 'Admun'});
        },
        label: Text('Turunkan'),
      );
    } else if (role == 'Admin' && currentUserId != uid)
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          FirebaseDatabase.instance
              .reference()
              .child('admins')
              .child(uid)
              .update({'role': 'Superadmin'});
        },
        label: Text('Naikkan'),
      );
  }

  @override
  void dispose() {
    super.dispose();
    _adminList.clear();
    _onAdminAddedSubscription.cancel();
    _onAdminChangedSubscription.cancel();
    _onAdminRemovedSubscription.cancel();
  }

  Future getPrefs() async {
    prefs = await SharedPreferences.getInstance();
    currentUserId = prefs.getString('userId');
  }

  @override
  void initState() {
    _adminList.clear();
    getPrefs();

    _onAdminAddedSubscription = _adminRef.onChildAdded.listen(_onAdminAdded);
    _onAdminChangedSubscription =
        _adminRef.onChildChanged.listen(_onAdminChanged);
    _onAdminRemovedSubscription =
        _adminRef.onChildRemoved.listen(_onAdminRemoved);

    _adminList.sort((a, b) => b.role.compareTo(a.role));
    super.initState();
  }

  void sortAdminList() {
    var userEntry = _adminList.singleWhere((entry) {
      print('${entry.uid}==$currentUserId');
      return entry.uid == currentUserId;
    });
    print(_adminList.indexOf(userEntry));
    _adminList.removeAt(_adminList.indexOf(userEntry));
    _adminList.insert(0, userEntry);
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
}
