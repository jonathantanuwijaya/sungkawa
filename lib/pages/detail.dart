import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:sung/model/comment.dart';
import 'package:sung/model/posting.dart';
import 'package:sung/pages/comment_page.dart';
import 'package:sung/utilities/utilities.dart';

class Detail extends StatefulWidget {
  final Posting post;

  Detail(this.post);

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List<Comment> _commentList = new List();
  var _commentRef;

  Utilities util = new Utilities();
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
    _onCommentRemovedSubscription =
        _commentRef.onChildRemoved.listen(_onCommentRemoved);
  }

  @override
  void dispose() {
    super.dispose();
    _onCommentAddedSubscription.cancel();
    _onCommentChangedSubscription.cancel();
    _onCommentRemovedSubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            expandedHeight: 240.0,
            floating: true,
            pinned: true,
            snap: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(widget.post.nama),
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
                    style:
                    TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    "Nama : " + widget.post.nama,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Alamat : " + widget.post.alamat,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Usia : " + widget.post.usia + " tahun",
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Agama : " + widget.post.agama,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                  Text(
                    "Tanggal Meninggal : " + widget.post.tanggalMeninggal,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                  Text(
                    'Disemayamkan di ' + widget.post.lokasiSemayam,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Text(
                    "Tanggal disemayamkan : " + widget.post.tanggalSemayam,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                  buildKeluarga(),
                  Text(
                    widget.post.prosesi +
                        ' di ' +
                        widget.post.tempatMakam +
                        ' pada ' +
                        widget.post.tanggalSemayam +
                        ' pukul ' +
                        widget.post.waktuSemayam,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  Divider(
                    color: Colors.green,
                  ),
                  SizedBox(height: 10.0),
                  Text(
                    'Ucapan Belasungkawa (' +
                        _commentList.length.toString() +
                        ')',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
                                builder: (context) => CommentPage(widget.post)),
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
    );
  }

  Widget sampleComment() {
    if (_commentList.length == 0) {
      return Text('');
    } else {
      return Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(_commentList[0].fullName,
                style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
            Text(_commentList[0].comment, style: TextStyle(fontSize: 16.0)),
          ],
        ),
      );
    }
  }

  buildKeluarga() {
    if (widget.post.keterangan == '') {
      return Text('');
    } else {
      return Column(
        children: <Widget>[
          Text('Keterangan :\n' + widget.post.keterangan,
            style: TextStyle(fontSize: 16.0),),

        ],
      );
    }
  }
}
