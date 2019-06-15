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
        title: Text('Kelola Admin'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          sortAdminList();

          return buildAdminCard(index);
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
                  return buildAddAdminDialog(context);
                });
          }),
    );
  }

  CupertinoAlertDialog buildAddAdminDialog(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text('Tambah Admin'),
      content: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              CupertinoTextField(
                controller: _emailController,
                placeholder: 'Email',
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                    border: Border.all(style: BorderStyle.solid)),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(
                height: 15,
              ),
              CupertinoTextField(
                controller: _tempatController,
                placeholder: 'Tempat',
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    shape: BoxShape.rectangle,
                    border: Border.all(style: BorderStyle.solid)),
              ),
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ),
      ),
      actions: <Widget>[
        FlatButton(
            textColor: Colors.blue,
            onPressed: () {
              _formKey.currentState.save();

              FirebaseDatabase.instance
                  .reference()
                  .child('admintemp')
                  .child(_emailController.text.hashCode.toString())
                  .set({
                'email': _emailController.text,
                'tempat': _tempatController.text,
              }).whenComplete(() {
                clearTextField(context);
              });
            },
            child: Text('Tambah')),
        FlatButton(
            textColor: Colors.red,
            onPressed: () {
              clearTextField(context);
            },
            child: Text('Batal'))
      ],
    );
  }

  Padding buildAdminCard(int index) {
    return Padding(
      padding: const EdgeInsets.only(left: 5, right: 5),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
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
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text('Email : ${_adminList[index].email}'),
                  SizedBox(
                    height: 3,
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
                    builder: (context) => CupertinoAlertDialog(
                          title: Text('Hapus Admin?'),
                          content: Text(
                              'Tindakan ini tidak dapat dipulihkan, lanjutkan?'),
                          actions: <Widget>[
                            CupertinoDialogAction(
                              child: Text('Hapus'),
                              onPressed: () {
                                FirebaseDatabase.instance
                                    .reference()
                                    .child('admins')
                                    .child(_adminList[index].uid)
                                    .remove();

                                setState(() {
                                  _adminList.removeAt(index);
                                  Navigator.pop(context);
                                });
                              },
                            ),
                            CupertinoDialogAction(
                              child: Text('Batal'),
                              isDestructiveAction: true,
                              onPressed: () {
                                Navigator.pop(context);
                              },
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
        width: MediaQuery.of(context).size.width - 28,
      );
    }
  }

  Widget buildChangeStatusButton(role, String uid) {
    if (role == 'Superadmin' && currentUserId != uid) {
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_down),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: Text('Turunkan ke Admin?'),
                    content: Text(
                        'Superadmin ini akan kehilangan akses untuk mengelola admin yang ada. Lanjutkan?'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                        child: Text('Lanjut'),
                        onPressed: () {
                          setState(() {
                            FirebaseDatabase.instance
                                .reference()
                                .child('admins')
                                .child(uid)
                                .update({'role': 'Admin'});
                          });
                        },
                      ),
                      CupertinoDialogAction(
                        child: Text('Batal'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        isDestructiveAction: true,
                      )
                    ],
                  ));
        },
        label: Text('Turunkan'),
      );
    } else if (role == 'Admin' && currentUserId != uid)
      return FlatButton.icon(
        icon: Icon(Icons.keyboard_arrow_up),
        onPressed: () {
          showDialog(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                    title: Text('Naikkan ke Super Admin?'),
                    content: Text(
                        'Superadmin memiliki akses program yang lebih tinggi daripada admin biasa, tindakan ini dapat berbahaya.\n Lanjutkan?'),
                    actions: <Widget>[
                      CupertinoDialogAction(
                          onPressed: () {
                            setState(() {
                              FirebaseDatabase.instance
                                  .reference()
                                  .child('admins')
                                  .child(uid)
                                  .update({'role': 'Superadmin'}).whenComplete(
                                      () {
                                Navigator.pop(context);
                              });
                            });
                          },
                          child: Text(
                            'Lanjut',
                          )),
                      CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Batal',
                          ))
                    ],
                  ));
        },
        label: Text('Naikkan'),
      );
  }

  void clearTextField(BuildContext context) {
    _emailController.clear();
    _tempatController.clear();
    Navigator.pop(context);
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
    subscribeStream();
    _adminList.sort((a, b) => b.role.compareTo(a.role));
    super.initState();
  }

  void sortAdminList() {
    var userEntry = _adminList.singleWhere((entry) {
      return entry.uid == currentUserId;
    });
    print(_adminList.indexOf(userEntry));
    _adminList.removeAt(_adminList.indexOf(userEntry));
    _adminList.insert(0, userEntry);
  }

  void subscribeStream() {
    _onAdminAddedSubscription = _adminRef.onChildAdded.listen(_onAdminAdded);
    _onAdminChangedSubscription =
        _adminRef.onChildChanged.listen(_onAdminChanged);
    _onAdminRemovedSubscription =
        _adminRef.onChildRemoved.listen(_onAdminRemoved);
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
