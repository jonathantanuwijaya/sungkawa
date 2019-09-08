import 'dart:async';

import 'package:admin_sungkawa/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

final RTDBService rtdbService = RTDBService();

class RTDBService {
  static DatabaseReference _db = FirebaseDatabase.instance.reference();
  SharedPreferences prefs;
  var currentAdminRef;

  DatabaseReference _postRef = _db.child('posts');
  DatabaseReference _commentRef = _db.child('comments');
  DatabaseReference _adminRef = _db.child('admins');

  StreamSubscription<Event> _adminStream;

  Future<void> addAdmin(
      {String adminId, Map<String, dynamic> adminData}) async {
    _adminRef.child(adminId).set(adminData);
  }

  Future<void> addComment(
      {String postId, Map<String, dynamic> commentData}) async {
    _commentRef.child(postId).push().set(commentData).catchError((e) {
      print(e);
    });
  }

  Future<void> addPost({Map<String, dynamic> postData}) async {
    _postRef.push().set(postData).catchError((e) {
      print(e);
    });
  }

  // ignore: missing_return
  Future checkAdmin({FirebaseUser user}) async {
    _adminStream = _adminRef.child('${user.uid}').onValue.listen(onData);
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

  checkCommentEmpty(postId) => _commentRef
      .child(postId)
      .orderByKey()
      .once()
      .then((snapshot) => snapshot.value == null ? true : false);

  checkPostEmpty() => _postRef
      .orderByKey()
      .once()
      .then((snapshot) => snapshot.value == null ? true : false);

  Future checkSuperAdmin() async {
    prefs = await SharedPreferences.getInstance();
    String userId = (await authService.currentUser).uid;
    currentAdminRef =
        _db.child('admins').child(userId).onValue.listen(_checkAdminRole);
  }

  deleteComment({String postId, String commentId}) {
    _commentRef.child(postId).child(commentId).remove().catchError((e) {
      print(e);
    });
  }

  deletePost(String postId) {
    _postRef.child(postId).remove().catchError((e) {
      print(e);
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

  void onData(Event event) {
    event.snapshot != null
        ? print('Snapshot Exists')
        : print('Snapshot doesn\'t exists');

    _adminStream.cancel();
  }

  void updateComment(commentId, commentData) =>
      _commentRef.child(commentId).update(commentData).catchError((e) {
        print(e);
      });

  void updatePost(postId, postData) async =>
      _postRef.child(postId).update(postData).catchError((e) {
        print(e);
      });

  void _checkAdminRole(Event event) {
    if (event.snapshot == null) {
      authService.signOut();
    } else if (event.snapshot.value['role'] == 'Admin') {
      prefs.setBool('isSuperAdmin', false);
    } else if (event.snapshot.value['role'] == 'Superadmin') {
      prefs.setBool('isSuperAdmin', true);
    }
  }

  Future<bool> checkAdminExist(FirebaseUser user) {
    Query adminRef = _adminRef.orderByChild('email').equalTo('${user.email}');
    return adminRef.once().then((doc) {
      print('''Document Key : ${doc.key}
        Document Value : ${doc.value}''');
      if (doc.key != user.uid) {
        _adminRef.child('${user.uid}').set({
          'email': user.email,
          'nama': user.displayName,
          'role': 'Admin',
          'tempat': doc.value['tempat'],
          'userid': user.uid
        });
      }

      return doc != null ? true : false;
    });
  }

  convertAdmin({FirebaseUser user, DataSnapshot doc}) {}
}
