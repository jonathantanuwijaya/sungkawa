import 'package:admin_sungkawa/crud.dart';
import 'package:admin_sungkawa/model/comment.dart';
import 'package:admin_sungkawa/model/posting.dart';
import 'package:admin_sungkawa/utilities/utilities.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommentPage extends StatefulWidget {
  final Post post;

  CommentPage(this.post);

  @override
  _CommentPageState createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  String fullName, userId;
  Utilities util = new Utilities();
  Query _commentRef;
  bool isEmpty;
  final commentController = new TextEditingController();
  final commentNode = new FocusNode();

  SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Komentar'),
      ),
      body: StreamBuilder(
        stream:
            _commentRef.onValue.map((e) => Comment.fromSnapshot(e.snapshot)),
        builder: (context, AsyncSnapshot<Comment> snapshot) {
          print('Snapshot Data : ${snapshot.data}');
          return Text('${snapshot.data.key}');
        },
      ),
    );
  }

//  return Column(
//  mainAxisSize: MainAxisSize.max,
//  children: <Widget>[
//  if (snapshot.connectionState == ConnectionState.done)
//  Expanded(
//  child: Container(
//  child: snapshot.hasData
//  ? ListTile(
//  title: Text(
//  comment.fullName,
//  style: TextStyle(fontWeight: FontWeight.bold),
//  ),
//  trailing: Text(util
//      .convertCommentTimestamp(comment.timestamp)),
//  subtitle: Text(comment.comment),
//  )
//      : Center(
//  child: Text('No Comment'),
//  ),
//  ),
//  ),
//  Align(
//  alignment: Alignment.bottomCenter,
//  child: ListTile(
//  title: CupertinoTextField(
//  controller: commentController,
//  textInputAction: TextInputAction.send,
//  onEditingComplete: sendComment,
//  placeholder: 'Tuliskan Komentarmu disini',
//  focusNode: commentNode,
//  decoration: BoxDecoration(
//  borderRadius: BorderRadius.circular(5.0),
//  border: Border.all(
//  width: 0.0, color: CupertinoColors.activeBlue)),
////                decoration:
////                    InputDecoration(hintText: 'Tuliskan Komentarmu disini'),
//  ),
//  trailing: IconButton(
//  icon: Icon(Icons.send), onPressed: sendComment),
//  ),
//  )
//  ],
//  );

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _commentRef = FirebaseDatabase.instance
        .reference()
        .child('comments')
        .child(widget.post.key);
    readLocal();
  }

  void readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('nama');
    userId = prefs.getString('userId');
  }

  void sendComment() {
    print('Comment : ' + commentController.text);

    if (commentController.text == ' ' ||
        commentController.text == '' ||
        commentController.text == '  ') {
      Fluttertoast.showToast(
          msg: "Ucapan tidak boleh kosong",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIos: 1,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      setState(() {
        rtdbService.addComment(postId: widget.post.key, commentData: {
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
}
