import 'package:firebase_database/firebase_database.dart';
import 'package:sungkawa/model/user.dart';

class Comment {
  String _key;
  String _userName;
  String _comment;
  String _userId;

  int _timestamp;
  User _user;
  String _displayName;

  Comment(this._key, this._userName, this._comment, this._userId,
      this._timestamp, this._user);

  Comment.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _userName = snapshot.value['fullName'];
    _comment = snapshot.value['comment'];
    _timestamp = snapshot.value['timestamp'];
    _userId = snapshot.value['userId'];

    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(_userId)
        .once()
        .then((snapshot) {
      _displayName = snapshot.value['username'];
    });
  }


  String get comment => _comment;

  String get displayName => _displayName;

  String get key => _key;

  int get timestamp => _timestamp;

  User get user => _user;

  String get userId => _userId;

  String get userName => _userName;
}
