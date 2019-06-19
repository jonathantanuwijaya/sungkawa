import 'package:firebase_database/firebase_database.dart';
import 'package:sungkawa/model/user.dart';

class Comment {
  String _key;
  String _comment;
  String _userId;

  int _timestamp;
  User _user;
  String _displayName;

  Comment(this._key, this._comment, this._userId, this._timestamp, this._user,
      this._displayName);

  Comment.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _comment = snapshot.value['comment'];
    _timestamp = snapshot.value['timestamp'];
    _userId = snapshot.value['userId'];
    _displayName = snapshot.value['fullName'];
  }

  String get comment => _comment;

  String get displayName => _displayName;

  String get key => _key;

  int get timestamp => _timestamp;

  User get user => _user;

  String get userId => _userId;
}
