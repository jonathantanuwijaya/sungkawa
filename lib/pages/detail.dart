import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sungkawa/model/comment.dart';
import 'package:sungkawa/model/posting.dart';
import 'package:sungkawa/pages/comment_page.dart';
import 'package:sungkawa/utilities/utilities.dart';

class Detail extends StatefulWidget {
  final Post post;

  Detail(this.post);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List<Comment> _commentList = new List();
  var _commentRef;
  var displayName;
  Utilities util = new Utilities();
  StreamSubscription<Event> _onCommentAddedSubscription;
  StreamSubscription<Event> _onCommentChangedSubscription;
  StreamSubscription<Event> _onCommentRemovedSubscription;

  @override
  Widget build(BuildContext context) {
    var mediumText = TextStyle(fontSize: 16.0);
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        bottom: true,
        child: CustomScrollView(
          shrinkWrap: false,
          slivers: <Widget>[
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              snap: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.post.nama,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                centerTitle: true,
                background: CachedNetworkImage(
                  imageUrl: widget.post.photo,
                  placeholder: (context, url) => CircularProgressIndicator(),
                  errorWidget: (context, url, error) => Icon(Icons.warning),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SliverFillRemaining(
              child: Container(
                padding: EdgeInsets.all(16.0),
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      'Telah Meninggal Dunia',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Text(
                      "Nama : " + widget.post.nama,
                      style: mediumText,
                    ),
                    Text(
                      "Alamat : " + widget.post.alamat,
                      style: mediumText,
                    ),
                    Text(
                      "Usia : ${widget.post.usia} tahun",
                      style: mediumText,
                    ),
                    Text(
                      "Agama : ${widget.post.agama}",
                      style: mediumText,
                    ),
                    Divider(
                      color: Colors.green,
                    ),
                    Text(
                      "Tanggal Meninggal : ${widget.post.tanggalMeninggal}",
                      style: mediumText,
                    ),
                    Divider(
                      color: Colors.green,
                    ),
                    Text(
                      'Disemayamkan di ' + widget.post.lokasiSemayam,
                      style: mediumText,
                    ),
                    Text(
                      "Tanggal disemayamkan : " + widget.post.tanggalSemayam,
                      style: mediumText,
                    ),
                    Divider(
                      color: Colors.green,
                    ),
                    Text(
                      widget.post.prosesi +
                          ' di ' +
                          widget.post.tempatMakam +
                          ' pada ' +
                          widget.post.tanggalDimakamkan +
                          ' pukul ' +
                          widget.post.waktuDimakamkan,
                      style: mediumText,
                    ),
                    Divider(
                      color: Colors.green,
                    ),
                    buildKeluarga(),
                    SizedBox(height: 10.0),
                    Text(
                      'Ucapan Belasungkawa (' +
                          _commentList.length.toString() +
                          ')',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10.0),
                    sampleComment(),
                    Divider(
                      color: Colors.blue,
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(child: SizedBox()),
                        FlatButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      CommentPage(widget.post)),
                            );
                          },
                          child: Text('LAINNYA...'),
                          textColor: Colors.green[700],
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  buildKeluarga() {
    if (widget.post.keterangan == '') {
      return Text('');
    } else {
      return Column(
        children: <Widget>[
          Text(
            'Keterangan :\n' + widget.post.keterangan,
            style: TextStyle(fontSize: 16.0),
          ),
        ],
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _onCommentAddedSubscription.cancel();
    _onCommentChangedSubscription.cancel();
    _onCommentRemovedSubscription.cancel();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _commentRef = FirebaseDatabase.instance
        .reference()
        .child('comments')
        .child(widget.post.key)
        .orderByChild('timestamp');
    _commentList.clear();
    _onCommentAddedSubscription =
        _commentRef.onChildAdded.listen(_onCommentAdded);
    _onCommentChangedSubscription =
        _commentRef.onChildChanged.listen(_onCommentChanged);
    _onCommentRemovedSubscription =
        _commentRef.onChildRemoved.listen(_onCommentRemoved);
  }

  Widget sampleComment() {
    if (_commentList.length == 0) {
      return Text('');
    } else {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            buildDisplayName(),
            Text(_commentList[0].comment, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      );
    }
  }

  Text buildDisplayName() {
    return Text(displayName,
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold));
  }

  _onCommentAdded(Event event) {
    setState(() {
      _commentList.add(Comment.fromSnapshot(event.snapshot));
      displayName = getDisplayName(_commentList[0].userId);
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

  String getDisplayName(String userId) {
    String displayName;
    print('Comment Key : ${_commentList[0].key}');
    FirebaseDatabase.instance
        .reference()
        .child('users')
        .child(userId)
        .once()
        .then((snapshot) {
      var username = snapshot.value['username'];
      if (username == null) {
        print('true');
        displayName = snapshot.value['nama'];
      } else {
        print('false');
        displayName = username;
      }
    }).whenComplete(() {
      print('Searching Complete...');
      print('Display Name : $displayName');
    });
    return displayName;
  }
}
