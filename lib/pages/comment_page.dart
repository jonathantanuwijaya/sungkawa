import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
//                decoration:
//                    InputDecoration(hintText: 'Tuliskan Komentarmu disini'),
              ),
              trailing:
              IconButton(icon: Icon(Icons.send), onPressed: sendComment),
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

  void readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('nama');
    userId = prefs.getString('userId');
  }
}