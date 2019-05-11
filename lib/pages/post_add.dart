import 'dart:async';
import 'dart:io';

import 'package:sung/main.dart';
import 'package:sung/utilities/crud.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PostAdd extends StatefulWidget {
  @override
  _PostAddState createState() => _PostAddState();
}

class _PostAddState extends State<PostAdd> {
  double _progress;
  String userId;
  InputType inputType = InputType.date;
  bool editable = true;
  bool isUploading = false;
  DateTime date = DateTime.now();
  int timestamp;
  final namaController = TextEditingController();
  final umurController = TextEditingController();
  final alamatController = TextEditingController();
  final tempatProsesiController = TextEditingController();
  final tanggalMeninggalController = TextEditingController();
  final tempatSemayamController = TextEditingController();
  final agamaController = TextEditingController();
  final keluargaController = TextEditingController();
  final tempatsemyamController = TextEditingController();
  final keteranganController = TextEditingController();
  final tanggalProsesiController = TextEditingController();
  final waktuSemayamController = TextEditingController();
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('hh:mm a');
  DateTime tanggalMeninggal;

  DateTime tanggalSemayam;
  DateTime waktuSemayam;
  BuildContext _snackBarContext;

  File image;
  var imageFile, _prosesi;
  bool isLoading = false;
  String kubur;
  CRUD crud = new CRUD();
  var radiovalue;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambahkan posting',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.grey[350],
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return IconButton(
              color: Colors.black,
              icon: Icon(Icons.check),
              onPressed: () {
                _snackBarContext = context;
                image == null ? showErrorMessage() : savePost();
              },
            );
          })
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: ListView(
          padding: EdgeInsets.only(top: 8.0),
          children: <Widget>[
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Nama',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    textInputAction: TextInputAction.next,
                    maxLength: 50,
                    maxLines: 1,
                    controller: namaController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Usia',
                      hintText: 'Tulis usia dalam satuan tahun',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    maxLines: 1,
                    controller: umurController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Agama',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLength: 50,
                    maxLines: 1,
                    controller: agamaController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  DateTimePickerFormField(
                    inputType: InputType.date,
                    editable: false,
                    format: dateFormat,
                    controller: tanggalMeninggalController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Meninggal',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    onChanged: (value) => setState(() => date = value),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLength: 50,
                    maxLines: 1,
                    controller: alamatController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(
                        height: 8.0,
                      ),
                      new Radio(
                        value: 'Dimakamkan',
                        onChanged: handleProsesi,
                        activeColor: Colors.green,
                        groupValue: _prosesi,
                      ),
                      Text('Dimakamkan'),
                      SizedBox(
                        height: 8.0,
                      ),
                      new Radio(
                        value: 'Dikremasi',
                        onChanged: handleProsesi,
                        activeColor: Colors.green,
                        groupValue: _prosesi,
                      ),
                      Text('Dikremasi'),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Tempat disemayamkan',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLength: 50,
                    maxLines: 1,
                    controller: tempatSemayamController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Tempat Pemakaman/Kremasi',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLength: 50,
                    maxLines: 1,
                    controller: tempatProsesiController,
                    textCapitalization: TextCapitalization.words,
                  ),
                  DateTimePickerFormField(
                    inputType: InputType.date,
                    editable: false,
                    format: dateFormat,
                    controller: tanggalProsesiController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Pemakaman/Kremasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  DateTimePickerFormField(
                    inputType: InputType.time,
                    editable: false,
                    format: timeFormat,
                    controller: waktuSemayamController,
                    decoration: InputDecoration(
                      labelText: 'Jam Pemakaman/Kremasi',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Keterangan',
                      hintText: 'Tulis keterangan...',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    maxLength: 200,
                    maxLines: 6,
                    controller: keteranganController,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  Row(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.grey,
                        ),
                        onPressed: getImageCamera,
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.image,
                          color: Colors.grey,
                        ),
                        onPressed: getImageGallery,
                      ),
                      buildProgressBar(),
                    ],
                  ),
                  imageFile != null ? buildImage() : Text(''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProgressBar() {
    return Expanded(
      child: isUploading == true
          ? LinearProgressIndicator(
              value: _progress,
            )
          : SizedBox(),
    );
  }

  Widget buildImage() {
    return Container(
      child: Image.file(
        imageFile,
        width: MediaQuery.of(context).size.width,
        height: 240,
        fit: BoxFit.fitWidth,
      ),
    );
  }

  void getImageGallery() async {
    try {
      imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
      print('imageFile : $imageFile');
      setState(() {
        image = imageFile;
      });
    } catch (e) {
      print('Error $e');
    }
  }

  void getImageCamera() async {
    try {
      imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
      print('imageFile : $imageFile');
      setState(() {
        image = imageFile;
      });
    } catch (e) {
      print('Error $e');
    }
  }

  Future<String> uploadImage(var imageFile) async {
    timestamp = DateTime.now().millisecondsSinceEpoch;
    String fileName = timestamp.toString() + 'jpg';
    StorageReference storageRef =
        FirebaseStorage.instance.ref().child('image').child(fileName);
    StorageUploadTask task = storageRef.putFile(image);

    task.events.listen((event) {
      setState(() {
        isUploading = true;
        _progress = event.snapshot.bytesTransferred.toDouble() /
            event.snapshot.totalByteCount.toDouble();
      });
    });

    var downloadUrl = await (await task.onComplete).ref.getDownloadURL();
    String _url = downloadUrl.toString();

    return _url;
  }

  void savePost() async {
    await FirebaseAuth.instance.currentUser().then((user) {
      setState(() {
        userId = user.uid;
      });
    });
    if (image != null) {
      setState(() {
        isLoading = true;
      });
      uploadImage(image).then((_url) {
        try {
          print('Posting ....');
          crud.addPost({
            'nama': namaController.text,
            'usia': umurController.text,
            'agama': agamaController.text,
            'photo': _url,
            'timestamp': timestamp,
            'userId': userId,
            'tanggalMeninggal': tanggalMeninggalController.text,
            'alamat': alamatController.text,
            'prosesi': _prosesi.toString(),
            'tempatMakam': tempatProsesiController.text,
            'tanggalSemayam': tanggalProsesiController.text,
            'lokasiSemayam': tempatSemayamController.text,
            'waktuSemayam': waktuSemayamController.text,
            'keterangan': keteranganController.text
          }).whenComplete(() {
            print('Posting selesai.......');
            Navigator.pop(context,
                MaterialPageRoute(builder: (context) => DashboardScreen()));
            namaController.clear();
            tempatProsesiController.clear();
            agamaController.clear();
            alamatController.clear();
            waktuSemayamController.clear();
            keteranganController.clear();
            tanggalMeninggalController.clear();
            umurController.clear();
            tanggalMeninggalController.clear();
            tempatSemayamController.clear();
          });
        } catch (e) {
          print('error : $e');
          isLoading = false;
        }
      });
    } else {
      isLoading = false;
    }
  }

  void handleProsesi(value) {
    print('Process type : $value');
    setState(() {
      _prosesi = value;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _prosesi = 'Dimakamkan';
  }

  void showErrorMessage() {
    Scaffold.of(_snackBarContext).showSnackBar(SnackBar(
      content: Text("Photo wajib ada"),
      duration: Duration(seconds: 2),
    ));
  }
}
