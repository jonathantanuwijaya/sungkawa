import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

class CRUD {
  DatabaseReference postRef =
  FirebaseDatabase.instance.reference().child('posts');
  DatabaseReference commentRef =
  FirebaseDatabase.instance.reference().child('comments');
  DatabaseReference adminRef =
  FirebaseDatabase.instance.reference().child('admins');

  Future<void> addAdmin(String adminId, adminData) async {
    adminRef.child(adminId).set(adminData);
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

  // ignore: missing_return
  Future<bool> checkCommentEmpty(postId) async {
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

  updatePost(postId, postData) async {
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