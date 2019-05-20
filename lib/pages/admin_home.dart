import 'dart:async';

import 'package:admin_sungkawa/model/posting.dart';
import 'package:admin_sungkawa/pages/detail.dart';
import 'package:admin_sungkawa/pages/post_update.dart';
import 'package:admin_sungkawa/utilities/crud.dart';
import 'package:admin_sungkawa/utilities/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

CRUD crud = new CRUD();

Utilities util = new Utilities();
final _postRef = FirebaseDatabase.instance
    .reference()
    .child('posts')
    .orderByChild('timestamp');

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _postList = new List();

  StreamSubscription<Event> _onPostAddedSubscription;
  StreamSubscription<Event> _onPostChangedSubscription;
  StreamSubscription<Event> _onPostRemovedSubscription;

  @override
  Widget build(BuildContext context) {
    return buildPage();
  }

  Widget buildPage() {
    if (_postList.length == 0)
      return Center(child: CircularProgressIndicator());

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _postList.length,
      itemBuilder: (buildContext, int index) {
        return Padding(
          padding: const EdgeInsets.only(left: 5.0, right: 5.0),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => Detail(_postList[index])));
            },
            onLongPress: () {
              showCupertinoModalPopup(
                context: context,
                builder: (context) =>
                    CupertinoActionSheet(
                      title: Text("Apa yang ingin anda lakukan?"),
                      actions: <Widget>[
                        CupertinoActionSheetAction(
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UpdatePost(_postList[index])));
                            },
                            child: Text('Update')),
                        CupertinoActionSheetAction(
                          isDestructiveAction: true,
                          child: Text('Delete'),
                          onPressed: () {
                            Navigator.pop(context);
                            showCupertinoDialog(
                              context: context,
                              builder: (context) =>
                                  CupertinoAlertDialog(
                                    content:
                                    Text('Anda yakin dengan pilihan ini'),
                                    actions: <Widget>[
                                      FlatButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text(
                                            'Batal',
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          )),
                                      FlatButton(
                                        onPressed: () {
                                          crud.deletePost(_postList[index].key);
                                          setState(() {
                                            _postList.removeAt(index);
                                            Navigator.pop(context);
                                          });
                                        },
                                        child: Text(
                                          'Ya',
                                          style: TextStyle(
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                            );
                          },
                        )
                      ],
                    ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 10.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          _postList[index].nama,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18.0,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Text(
                          util.convertPostTimestamp(
                            _postList[index].timestamp,
                          ),
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Usia : ${_postList[index].usia} tahun',
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        buildStatusText(_postList[index])
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      bottom: 10.0,
                    ),
                    child: Row(
                      children: <Widget>[
                        Text(
                          'Alamat : ' + _postList[index].alamat,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.grey,
                          ),
                        ),
                        Expanded(
                          child: SizedBox(),
                        ),
                        Text(
                          "Agama : ${_postList[index].agama}",
                          style: TextStyle(fontSize: 14.0, color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                  Center(
                    child: CachedNetworkImage(
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                      imageUrl: _postList[index].photo,
                      height: 240.0,
                      width: double.infinity,
                      fit: BoxFit.fitWidth,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildStatusText(Post post) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    DateTime tanggalMeninggal = dateFormat.parse(post.tanggalMeninggal);
    DateTime tanggalSemayam = dateFormat.parse(post.tanggalSemayam);
    DateTime tanggalDimakamkan = dateFormat.parse(post.tanggalDimakamkan);

    var now = DateTime.now();

    print('tanggal = $now');

    if (now.isAfter(tanggalDimakamkan))
      return Text(
        'Telah ${post.prosesi}',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      );
    else if (now.isAfter(tanggalSemayam))
      return Text(
        'Akan ${post.prosesi}',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    else if (now.isAfter(tanggalMeninggal))
      return Text(
        'Akan Disemayamkan',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
    return Text('');
  }

  @override
  void dispose() {
    super.dispose();
    _postList.clear();
    _onPostAddedSubscription.cancel();
    _onPostChangedSubscription.cancel();
    _onPostRemovedSubscription.cancel();
  }

  @override
  void initState() {
    super.initState();
    _postList.clear();
    _onPostAddedSubscription = _postRef.onChildAdded.listen(_onPostAdded);
    _onPostChangedSubscription = _postRef.onChildChanged.listen(_onPostChanged);
    _onPostRemovedSubscription = _postRef.onChildRemoved.listen(_onPostRemoved);
    _postList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  _onPostAdded(Event event) {
    setState(() {
      _postList.add(Post.fromSnapshot(event.snapshot));
      _postList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  _onPostChanged(Event event) {
    var oldEntry = _postList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _postList[_postList.indexOf(oldEntry)] =
          Post.fromSnapshot(event.snapshot);
    });
  }

  _onPostRemoved(Event event) {
    var deletedEntry = _postList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });
    print('on child removed called');
    setState(() {
      _postList.remove(deletedEntry);
    });
  }
}
