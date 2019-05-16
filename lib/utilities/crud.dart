import 'dart:async';
import 'package:firebase_database/firebase_database.dart';

class CRUD {
  DatabaseReference postRef =
  FirebaseDatabase.instance.reference().child('posts');
  DatabaseReference commentRef =
  FirebaseDatabase.instance.reference().child('comments');
  DatabaseReference userRef =
  FirebaseDatabase.instance.reference().child('users');

  Future<void> addUser(String adminId, adminData) async {
    userRef.child(adminId).set(adminData);
  }

  Future<void> addPost(postData) async {
    postRef.push().set(postData).catchError((e) {
      print(e);
    });
  }

  Future<void> addComment(postId, commentData) async {
    commentRef.child(postId).push().set(commentData).catchError((e) {
      print(e);
    });
  }

  checkPostEmpty() {
    bool isEmpty;
    postRef.orderByKey().once().then((snapshot) {
      if (snapshot.value == null)
        isEmpty = true;
      else
        isEmpty = false;
    }).whenComplete(() {
      print(isEmpty);
      return isEmpty;
    });
  }

  bool checkCommentEmpty(postId) {
    bool isEmpty;
    commentRef.child(postId).orderByKey().once().then((snapshot) {
      if (snapshot.value == null)
        isEmpty = true;
      else
        isEmpty = false;
    }).whenComplete(() {
      print(isEmpty);
      return isEmpty;
    });
  }

  updatePost(postId, postData) {
    postRef.child(postId).update(postData).catchError((e) {
      print(e);
    });
  }

  updateComment(commentId, commentData) {
    commentRef.child(commentId).update(commentData).catchError((e) {
      print(e);
    });
  }

  deletePost(postId) {
    postRef.child(postId).remove().catchError((e) {
      print(e);
    });
  }

  deleteComment(postId, commentId) {
    commentRef.child(postId).child(commentId).remove().catchError((e) {
      print(e);
    });
  }
}