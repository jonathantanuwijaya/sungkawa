import 'dart:async';

import 'package:admin_sungkawa/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RTDBService rtdbService = RTDBService();

class RTDBService {
  SharedPreferences prefs;
  static DatabaseReference _db = FirebaseDatabase.instance.reference();
  var currentAdminRef;

  Future checkSuperAdmin() async {
    prefs = await SharedPreferences.getInstance();
    String userId = (await authService.currentUser).uid;
    currentAdminRef =
        _db.child('admins').child(userId).onValue.listen(_checkAdminStatus);
  }

  DatabaseReference _postRef = _db.child('posts');
  DatabaseReference _commentRef = _db.child('comments');
  DatabaseReference _adminRef = _db.child('admins');

  Future<void> addAdmin(String adminId, adminData) async {
    _adminRef.child(adminId).set(adminData);
  }

  Future<void> addComment(postId, commentData) async {
    _commentRef.child(postId).push().set(commentData).catchError((e) {
      print(e);
    });
  }

  Future<void> addPost(postData) async {
    _postRef.push().set(postData).catchError((e) {
      print(e);
    });
  }

  // ignore: missing_return
  Future<bool> checkCommentEmpty(postId) async {
    bool isEmpty;
    _commentRef.child(postId).orderByKey().once().then((snapshot) {
      if (snapshot.value == null)
        isEmpty = true;
      else
        isEmpty = false;
    }).whenComplete(() {
      print(isEmpty);
      return isEmpty;
    });
  }

  checkPostEmpty() {
    bool isEmpty;
    _postRef.orderByKey().once().then((snapshot) {
      if (snapshot.value == null)
        isEmpty = true;
      else
        isEmpty = false;
    }).whenComplete(() {
      print(isEmpty);
      return isEmpty;
    });
  }

  deleteComment(postId, commentId) {
    _commentRef.child(postId).child(commentId).remove().catchError((e) {
      print(e);
    });
  }

  deletePost(postId) {
    _postRef.child(postId).remove().catchError((e) {
      print(e);
    });
  }

  updateComment(commentId, commentData) {
    _commentRef.child(commentId).update(commentData).catchError((e) {
      print(e);
    });
  }

  updatePost(postId, postData) async {
    _postRef.child(postId).update(postData).catchError((e) {
      print(e);
    });
  }

  Future checkAdminPlaceInfo() async {
    String userId = (await authService.currentUser).uid;

    return FirebaseDatabase.instance
        .reference()
        .child('admins')
        .child(userId)
        .once()
        .then((snapshot) {
      return snapshot.value['tempat'] ?? '';
    });
  }

//  Future checkAdmin(GoogleSignInAccount googleAccount) async {
//    print('Hash Code : ${googleAccount.email.hashCode.toString()}');
//    adminRef = FirebaseDatabase.instance
//        .reference()
//        .child('admins')
//        .child(googleAccount.id);
//    adminTempRef = FirebaseDatabase.instance
//        .reference()
//        .child('admintemp')
//        .child(googleAccount.email.hashCode.toString());
//
//    try {
//      prefs.setBool('isSuperAdmin', false);
//
//      adminRef.once().then((snapshot) {
//        print('${snapshot.key}');
//        if (snapshot.key != null) {
//          if (snapshot.value['role'] == 'Admin') {
//          } else if (snapshot.value['role'] == 'Superadmin') {
//            prefs.setBool('isSuperAdmin', true);
//          }
//          adminFound = true;
//          result = 'Selamat datang kembali, ${googleAccount.displayName}';
//        } else {
//          adminFound = false;
//        }
//      }).catchError((e) {
//        print('hoi');
//      }).whenComplete(() {
//        if (adminFound == true) {
//          signInToMainMenu(googleAccount);
//        } else {
//          print('pbe');
//          adminTempRef.once().then((snapshot) {
//            print('${snapshot.value['email']}');
//            if (snapshot.value['email'] == googleAccount.email) {
//              adminRef.set({
//                'email': snapshot.value['email'],
//                'nama': googleAccount.displayName,
//                'role': 'Admin',
//                'tempat': snapshot.value['tempat'],
//                'userid': googleAccount.id
//              });
//              adminFound = true;
//              result =
//                  'Selamat Datang di Sungkawa, ${googleAccount.displayName}';
//            } else {
//              adminFound = false;
//            }
//          }).catchError((e) {
//            print(e);
//          }).whenComplete(() {
//            signInToMainMenu(googleAccount);
//          });
//        }
//      });
//    } catch (e) {
//      print(e);
//    }
//  }

  StreamSubscription<Event> _adminStream;

  Future<bool> checkAdmin(FirebaseUser user) async {
    _adminStream = _adminRef.child('${user.uid}').onValue.listen(onData);
  }

  void _checkAdminStatus(Event event) {
    if (event.snapshot == null) {
      authService.signOut();
    } else if (event.snapshot.value['role'] == 'Admin') {
      prefs.setBool('isSuperAdmin', false);
    } else if (event.snapshot.value['role'] == 'Superadmin') {
      prefs.setBool('isSuperAdmin', true);
    }
  }

  void onData(Event event) {
    event.snapshot != null
        ? print('Snapshot Exists')
        : print('Snapshot doesn\'t exists');

    _adminStream.cancel();
  }
}
