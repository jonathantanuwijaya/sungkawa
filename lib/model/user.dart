import 'package:firebase_database/firebase_database.dart';

class User {
  String _key, _uid, _email, _nama, _userName;
  User(this._key, this._uid, this._email, this._nama, this._userName);
  User.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _uid = snapshot.value['userid'];
    _email = snapshot.value['email'];
    _nama = snapshot.value['nama'];
    _userName = snapshot.value['username'];
  }

  String get email => _email;

  String get key => _key;

  String get nama => _nama;

  String get uid => _uid;

  get userName => _userName;
}
