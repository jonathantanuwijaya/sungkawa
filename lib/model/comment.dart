import 'package:firebase_database/firebase_database.dart';

class Comment {
  String _key;
  String _fullName;
  String _comment;
  String _postId;

  int _timestamp;

  Comment(
      this._key, this._fullName, this._comment, this._postId, this._timestamp);

  Comment.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _fullName = snapshot.value['fullName'];
    _comment = snapshot.value['comment'];
    _timestamp = snapshot.value['timestamp'];
    _postId = snapshot.value['postId'];
  }

  String get comment => _comment;

  String get fullName => _fullName;

  String get key => _key;

  String get postId => _postId;

  int get timestamp => _timestamp;
}
