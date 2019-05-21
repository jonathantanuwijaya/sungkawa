import 'dart:async';
import 'dart:io';

import 'package:admin_sungkawa/API/ApiService.dart';
import 'package:admin_sungkawa/main.dart';
import 'package:admin_sungkawa/utilities/constants.dart';
import 'package:admin_sungkawa/utilities/crud.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
  int timestamp;

  final _formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final umurController = TextEditingController();
  final alamatController = TextEditingController();
  final tempatProsesiController = TextEditingController();
  final tanggalMeninggalController = TextEditingController();
  final tanggalDisemayamkanController = TextEditingController();
  final tempatSemayamController = TextEditingController();
  final keluargaController = TextEditingController();
  final tempatsemyamController = TextEditingController();
  final keteranganController = TextEditingController();
  final tanggalDimakamkanController = TextEditingController();
  final waktuDimakamkanController = TextEditingController();

  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('hh:mm a');

  DateTime tanggalMeninggal;
  DateTime tanggalSemayam;
  DateTime waktuSemayam;

  File image;
  var imageFile, _prosesi;
  bool isLoading = false;
  String kubur, agama;
  CRUD crud = new CRUD();
  String tuhan;
  Constants constants = new Constants();
  var radioValue;
  DateTime tanggalDimakamkan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Tambahkan posting',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        actions: <Widget>[
          Builder(builder: (BuildContext context) {
            return IconButton(
                color: Colors.black,
                icon: Icon(Icons.check),
                onPressed: isLoading != true
                    ? () {
                  if (image == null) {
                    Scaffold.of(context).showSnackBar(SnackBar(
                      content: Text("Photo wajib ada"),
                      duration: Duration(seconds: 2),
                    ));
                  } else
                    checkPost();
                      }
                    : null);
          })
        ],
      ),
      body: Container(
        margin: EdgeInsets.all(16.0),
        child: ListView(
          padding: EdgeInsets.only(top: 8.0),
          children: <Widget>[
            Form(
//              autovalidate: true,
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  TextFormField(
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
                    validator: (value) =>
                        value.isNotEmpty ? null : 'Nama wajib diisi',
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
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
                    validator: (value) =>
                        value.isNotEmpty ? null : 'Usia wajib diisi',
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  DropdownButtonFormField(
                    decoration: InputDecoration(
                        hintText: 'Agama',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5))),
                    validator: (value) =>
                        value != null ? null : 'Agama Wajib di isi',
                    value: agama,
                    items: Constants.agama.map((String value) {
                      return DropdownMenuItem(
                        child: Text(value),
                        value: value,
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        agama = value;
                        if (agama == 'Islam') {
                          _prosesi = 'Dimakamkan';
                        }
                      });
                    },
                  ),
                  SizedBox(
                    height: 10,
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
                    validator: (value) {
                      if (value.isAfter(tanggalSemayam) ||
                          value.isAfter(tanggalDimakamkan))
                        return "Urutan tanggal salah";
                      else
                        return null;
                    },
                    onChanged: (value) => tanggalMeninggal = value,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  DateTimePickerFormField(
                    inputType: InputType.date,
                    editable: false,
                    format: dateFormat,
                    controller: tanggalDisemayamkanController,
                    decoration: InputDecoration(
                      labelText: 'Tanggal Disemayamkan',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value.isBefore(tanggalMeninggal) ||
                          value.isAfter(tanggalDimakamkan))
                        return 'Urutan Tanggal salah';
                      else
                        return null;
                    },
                    onChanged: (value) => tanggalSemayam = value,
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Alamat',
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                    validator: (value) =>
                        value.isNotEmpty ? null : 'Alamat wajib diisi',
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
                        onChanged: (agama == 'Islam' ? null : handleProsesi),
                        activeColor: Colors.green,
                        groupValue: _prosesi,
                      ),
                      Text('Dikremasi'),
                    ],
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
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
                      validator: (value) => value.isNotEmpty
                          ? null
                          : 'Tempat persemayaman wajib diisi.'),
                  TextFormField(
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
                    validator: (value) =>
                        value.isNotEmpty ? null : 'Tempat Prosesi wajib diisi.',
                  ),
                  DateTimePickerFormField(
                    onChanged: (value) => tanggalDimakamkan = value,
                    inputType: InputType.date,
                    editable: false,
                    format: dateFormat,
                    controller: tanggalDimakamkanController,
                    validator: (value) {
                      if (value.isBefore(tanggalSemayam) ||
                          value.isBefore(tanggalMeninggal))
                        return "Urutan tanggal salah";
                      else
                        return null;
                    },
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
                    validator: (value) =>
                        value != null ? null : 'Jam wajib diisi',
                    controller: waktuDimakamkanController,
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
                      hintText: 'Tulis keterangan (Optional)',
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

  Widget buildProgressBar() {
    return Expanded(
      child: isUploading == true
          ? LinearProgressIndicator(
              value: _progress,
            )
          : SizedBox(),
    );
  }

  void checkPost() {
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {
      try {
        savePost();
      } catch (e) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(e),
          duration: Duration(seconds: 2),
        ));
      }
    } else {
      print("Failed to Validate");
      if (!(tanggalMeninggal.isAfter(DateTime.now()) &&
          tanggalSemayam.isAfter(tanggalMeninggal) &&
          tanggalDimakamkan.isAfter(tanggalSemayam))) {
        Fluttertoast.showToast(
            msg: "Tanggal yang diinput tidak logis",
            gravity: ToastGravity.CENTER,
            toastLength: Toast.LENGTH_SHORT,
            timeInSecForIos: 1,
            backgroundColor: Colors.black,
            fontSize: 16,
            textColor: Colors.white);
      }
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

      if (_formKey.currentState.validate()) {
        uploadImage(image).then((_url) {
          try {
            print('Posting ....');
            crud.addPost({
              'nama': namaController.text,
              'usia': umurController.text,
              'agama': agama,
              'photo': _url,
              'timestamp': timestamp,
              'userId': userId,
              'tanggalSemayam': tanggalDisemayamkanController.text,
              'tanggalMeninggal': tanggalMeninggalController.text,
              'alamat': alamatController.text,
              'prosesi': _prosesi.toString(),
              'tempatMakam': tempatProsesiController.text,
              'tanggalDimakamkan': tanggalDimakamkanController.text,
              'lokasiSemayam': tempatSemayamController.text,
              'waktuDimakamkan': waktuDimakamkanController.text,
              'keterangan': keteranganController.text
            }).whenComplete(() {
              sendNotification();
              print('Posting selesai.......');
              Navigator.pop(context,
                  MaterialPageRoute(builder: (context) => DashboardScreen()));
              namaController.clear();
              tempatProsesiController.clear();
              alamatController.clear();
              waktuDimakamkanController.clear();
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
      }
    } else {
      isLoading = false;
    }
  }

  Future sendNotification() async {
    final response = await ApiService.sendToAll(
        title: 'Berita Duka Cita',
        body: 'Telah meninggal dunia \n' +
            namaController.text +
            ' (' +
            umurController.text +
            ' tahun)');

    if (response.statusCode != 200) {
      Scaffold.of(context).showSnackBar(SnackBar(
        content:
            Text('[${response.statusCode}] Error message: ${response.body}'),
      ));
    }
  }

  void sendTokenToServer(String fcmtoken) {
    print('Token : $fcmtoken');
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
}
