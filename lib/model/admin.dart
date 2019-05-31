import 'package:firebase_database/firebase_database.dart';

class Admin {
  String _userName;
  String _email;
  String _superAdmin;

  // ignore: unused_field
  String _uid;

  Admin.fromSnapshot(DataSnapshot snapshot) {
    _uid = snapshot.key;
    _userName = snapshot.value['username'];
    _email = snapshot.value['email'];
    _superAdmin = snapshot.value['superAdmin'];
  }

  String get email => _email;

  String get superAdmin => _superAdmin;

  String get userName => _userName;
}
