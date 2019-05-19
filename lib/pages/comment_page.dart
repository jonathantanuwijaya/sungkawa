import 'dart:async';

import 'package:Sungkawa/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sungkawa/model/comment.dart';
import 'package:Sungkawa/model/posting.dart';
import 'package:Sungkawa/utilities/crud.dart';
import 'package:Sungkawa/utilities/utilities.dart';

class CommentPage extends StatefulWidget {
  CommentPage(this.post);

  final Posting post;

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  String fullName, userId;
  CRUD crud = new CRUD();
  Utilities util = new Utilities();
  var _commentRef;
  var isEmpty;
  final commentController = new TextEditingController();
  final commentNode = new FocusNode();
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  AuthStatus _authStatus = AuthStatus.notSignedIn;
  SharedPreferences prefs;
  List<Comment> _commentList = new List();
  StreamSubscription<Event> _onCommentAddedSubscription;
  StreamSubscription<Event> _onCommentChangedSubscription;
  StreamSubscription<Event> _onCommentRemovedSubscription;

  _onCommentAdded(Event event) {
    setState(() {
      _commentList.add(Comment.fromSnapshot(event.snapshot));
    });
  }

  _onCommentChanged(Event event) {
    var oldEntry = _commentList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _commentList[_commentList.indexOf(oldEntry)] =
          Comment.fromSnapshot(event.snapshot);
    });
  }

  _onCommentRemoved(Event event) {
    var deletedEntry = _commentList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    print('on child removed called');
    setState(() {
      _commentList.remove(deletedEntry);
    });
  }

  @override
  void initState() {
    super.initState();
    _commentRef = FirebaseDatabase.instance
        .reference()
        .child('comments')
        .child(widget.post.key)
        .orderByChild('timestamp');
    readLocal();
    _commentList.clear();

    _onCommentAddedSubscription =
        _commentRef.onChildAdded.listen(_onCommentAdded);
    _onCommentChangedSubscription =
        _commentRef.onChildChanged.listen(_onCommentChanged);
    _onCommentRemovedSubscription =
        _commentRef.onChildRemoved.listen(_onCommentRemoved);

    isEmpty = crud.checkCommentEmpty(widget.post.key);
    print(isEmpty);
  }

  @override
  void dispose() {
    super.dispose();
    _commentList.clear();
    _onCommentAddedSubscription.cancel();
    _onCommentChangedSubscription.cancel();
    _onCommentRemovedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(
              child: buildCommentPage(),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ListTile(
              title: CupertinoTextField(
                controller: commentController,
                textInputAction: TextInputAction.send,
                onEditingComplete: sendComment,
                placeholder: 'Tuliskan Komentarmu disini',
                focusNode: commentNode,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5.0),
                    border: Border.all(
                        width: 0.0, color: CupertinoColors.activeBlue)),
              ),
              trailing: IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    switch (_authStatus) {
                      case AuthStatus.notSignedIn:
                        handleSignIn().then((data) {
                          sendComment();
                        });
                        break;
                      case AuthStatus.signedIn:
                        sendComment();
                    }
                  }),
            ),
          )
        ],
      ),
    );
  }

  Widget buildCommentPage() {
    return ListView.builder(
      itemCount: _commentList.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(
            _commentList[index].fullName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          trailing:
              Text(util.convertCommentTimestamp(_commentList[index].timestamp)),
          subtitle: Text(_commentList[index].comment),
        );
      },
    );
  }

  void sendComment() {
    print('Comment : ' + commentController.text);

    if(commentController.text == ' '|| commentController.text == '' || commentController.text == '  '){
      Fluttertoast.showToast(
          msg: "Ucapan tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    }else{
      setState(() {
        crud.addComment(widget.post.key, {
          'fullName': fullName,
          'comment': commentController.text,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'userId': userId,
        }).whenComplete(() {
          commentController.clear();
          commentNode.unfocus();
        });
      });
    }

  }

  Future handleSignIn() async {
    GoogleSignInAccount googleAccount = await googleSignIn.signIn();
    GoogleSignInAuthentication googleAuth = await googleAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    prefs = await SharedPreferences.getInstance();

    prefs.setString('userId', googleAccount.id);
    prefs.setString('nama', googleAccount.displayName);
    prefs.setString('email', googleAccount.email);

    fullName = prefs.getString('nama');
    userId = prefs.getString('userId');

    firebaseAuth.signInWithCredential(credential).whenComplete(() {
      addToDatabase(googleAccount);
    });
  }

  Future addToDatabase(GoogleSignInAccount googleAccount) async {
    print('Adding to database');
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(googleAccount.id)
        .once()
        .then((snapshot) {
      if (snapshot.value == null) {
        print('Added to database');
        crud.addUser(googleAccount.id, {
          'userid': googleAccount.id,
          'nama': googleAccount.displayName,
          'email': googleAccount.email
        });
      }
    });
  }

  void readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('nama');
    userId = prefs.getString('userId');
  }
}
