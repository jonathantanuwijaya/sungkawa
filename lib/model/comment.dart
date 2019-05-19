import 'package:Sungkawa/model/user.dart';
import 'package:firebase_database/firebase_database.dart';

class Comment {
  String _key;
  String _fullName;
  String _comment;
  String _userId;
  String _userName;
  int _timestamp;
  User _user;
  String _displayName;

  Comment(this._key, this._fullName, this._comment, this._userId,
      this._userName, this._timestamp, this._user);

  String get displayName => _displayName;

  String get userName => _userName;

  int get timestamp => _timestamp;

  String get userId => _userId;

  String get comment => _comment;

  String get fullName => _fullName;

  String get key => _key;

  User get user => _user;

  Comment.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _fullName = snapshot.value['fullName'];
    _comment = snapshot.value['comment'];
    _timestamp = snapshot.value['timestamp'];
    _userId = snapshot.value['userId'];
  }

  Comment.getUserInfo(_userId) {
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(_userId)
        .once()
        .then((snapshot) {
      _displayName = snapshot.value['userName'];
    });
  }
}
