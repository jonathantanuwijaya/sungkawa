import 'package:firebase_database/firebase_database.dart';

class Admin {
  String _userName;
  String _email;
  String _isSuperAdmin;
  String _uid;

  Admin.fromSnapshot(DataSnapshot snapshot) {
    _uid = snapshot.key;
    _userName = snapshot.value['username'];
    _email = snapshot.value['email'];
    _isSuperAdmin = snapshot.value['isSuperAdmin'];
  }

  String get email => _email;

  String get isSuperAdmin => _isSuperAdmin;

  String get userName => _userName;
}
