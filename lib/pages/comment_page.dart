import 'package:admin_sungkawa/crud.dart';
import 'package:admin_sungkawa/model/comment.dart';
import 'package:admin_sungkawa/model/post.dart';
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
      body: StreamBuilder(stream: _commentRef.onValue, builder: _builder),
    );
  }

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
        .child(widget.post.key)
        .orderByChild('timestamp');
    readLocal();
  }

  void readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    fullName = prefs.getString('nama');
    userId = prefs.getString('userId');
  }

  void sendComment() {
    print('Comment : ' + commentController.text);

    if (commentController.text.isEmpty) {
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

  List<Comment> _commentList = [];

  Widget _builder(BuildContext context, AsyncSnapshot<Event> snap) {
    if (snap.hasData && !snap.hasError && snap.data.snapshot.value != null) {
      DataSnapshot ss = snap.data.snapshot;

      print('SS Value : ${ss.key}');

      ss.value.forEach((val) {
        print('${val.toString()}');
        if (val != null) {
          Comment comment = Comment.fromSnapshot(val);
          _commentList.add(comment);
        }
      });

      return Column(
        children: <Widget>[
          Expanded(
              child: ListView.builder(
            itemBuilder: _buildCommentTile,
            itemCount: _commentList.length,
          ))
        ],
      );
    }
  }

  Widget _buildCommentTile(context, index) {
    return ListTile(
      title: Text('${_commentList[index].fullName}'),
    );
  }
}
