import 'package:firebase_database/firebase_database.dart';

class Admin {
  String _nama;
  String _email;
  String _role;
  String _tempat;
  String _uid;

  Admin.fromSnapshot(DataSnapshot snapshot) {
    _uid = snapshot.key;
    _nama = snapshot.value['nama'];
    _email = snapshot.value['email'];
    _role = snapshot.value['role'];
    _tempat = snapshot.value['tempat'];
  }

  String get email => _email;

  String get nama => _nama;

  String get role => _role;

  String get tempat => _tempat;

  String get uid => _uid;
}
