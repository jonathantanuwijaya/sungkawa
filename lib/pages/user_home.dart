import 'dart:async';
import 'package:Sungkawa/model/posting.dart';
import 'package:Sungkawa/pages/detail.dart';
import 'package:Sungkawa/utilities/crud.dart';
import 'package:Sungkawa/utilities/utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

final _postRef = FirebaseDatabase.instance
    .reference()
    .child('posts')
    .orderByChild('timestamp');
Utilities util = new Utilities();
CRUD crud = new CRUD();

class _HomePageState extends State<HomePage> {
  List<Posting> _postList = new List();

  StreamSubscription<Event> _onPostAddedSubscription;
  StreamSubscription<Event> _onPostChangedSubscription;

  _onPostAdded(Event event) {
    setState(() {
      _postList.add(Posting.fromSnapshot(event.snapshot));
      _postList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  _onPostChanged(Event event) {
    var oldEntry = _postList.singleWhere((entry) {
      return entry.key == event.snapshot.key;
    });

    setState(() {
      _postList[_postList.indexOf(oldEntry)] =
          Posting.fromSnapshot(event.snapshot);
    });
  }

  @override
  void initState() {
    super.initState();
    _postList.clear();
    _onPostAddedSubscription = _postRef.onChildAdded.listen(_onPostAdded);
    _onPostChangedSubscription = _postRef.onChildChanged.listen(_onPostChanged);
    _postList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  @override
  void dispose() {
    super.dispose();
    _postList.clear();
    _onPostAddedSubscription.cancel();
    _onPostChangedSubscription.cancel();
  }

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
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5.0)),
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
                          util.convertTimestamp(
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
                          'Usia : ' + _postList[index].usia + ' tahun',
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
                          "Agama : " + _postList[index].agama,
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

  Widget buildStatusText(data) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    DateTime tanggalMeninggal = dateFormat.parse(data.tanggalMeninggal);

    var now = DateTime.now();

    print('tanggal = $now');

    if (now.isAfter(tanggalMeninggal))
      return Text(
        'Telah ${data.prosesi}',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      );
    else
      return Text(
        'Telah Disemayamkan',
        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
      );
  }
}
