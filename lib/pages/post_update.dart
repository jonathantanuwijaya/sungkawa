import 'dart:async';
import 'dart:io';

import 'package:admin_sungkawa/model/posting.dart';
import 'package:admin_sungkawa/utilities/constants.dart';
import 'package:admin_sungkawa/utilities/crud.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UpdatePost extends StatefulWidget {
  final Post post;

  UpdatePost(this.post);

  @override
  _UpdatePostState createState() => _UpdatePostState();
}

class _UpdatePostState extends State<UpdatePost> {
  String userId,
      nama,
      agama,
      usia,
      alamat,
      lokasiSemayam,
      keterangan,
      tempatMakam;
  double _progress;
  bool isChanged = false;
  var postRef;
  CRUD crud = new CRUD();
  SharedPreferences prefs;

  DateTime tanggalDimakamkan, waktuDimakamkan, tanggalMeninggal, tanggalSemayam;

  var radioValue;

  int timestamp;
  File image;
  var imageFile, _prosesi;
  bool isLoading = false;
  bool isUploading = false;
  final dateFormat = DateFormat('dd/MM/yyyy');
  final timeFormat = DateFormat('hh:mm a');
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Posting"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: (isLoading != true)
                ? () {
                    validateAndSubmit();
                  }
                : null,
          ),
        ],
        backgroundColor: Colors.green,
      ),
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: new ListView(
            children: <Widget>[
              isChanged == false
                  ? CachedNetworkImage(
                      imageUrl: widget.post.photo,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.warning),
                    )
                  : buildImage(),
              SizedBox(
                height: 5,
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
                  buildProgressIndicator()
                ],
              ),
              SizedBox(
                height: 5,
              ),
              TextFormField(
                initialValue: nama,
                onSaved: (value) => nama = value,
                validator: (value) =>
                    value.isEmpty ? 'Nama tidak boleh kosong' : null,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                maxLength: 50,
                maxLines: 1,
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                initialValue: usia,
                validator: (value) =>
                    value.isEmpty ? 'Umur tidak boleh kosong' : null,
                onSaved: (value) => usia = value,
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
                textCapitalization: TextCapitalization.words,
              ),
              DropdownButtonFormField(
                decoration: InputDecoration(
                    hintText: 'Agama',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5))),
                validator: (value) =>
                    value.isNotEmpty ? null : 'Agama Wajib di isi',
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
                height: 12.0,
              ),
              DateTimePickerFormField(
                initialValue: tanggalSemayam,
                inputType: InputType.date,
                editable: false,
                format: dateFormat,
                decoration: InputDecoration(
                  labelText: 'Tanggal Disemayamkan',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                validator: (value) =>
                    value != null ? null : 'Tanggal wajib diisi',
                onChanged: (value) => setState(() => tanggalDimakamkan = value),
              ),
              SizedBox(height: 15),
              DateTimePickerFormField(
                initialValue: tanggalMeninggal,
                inputType: InputType.date,
                editable: false,
                format: dateFormat,
                onSaved: (value) => tanggalMeninggal = value,
                decoration: InputDecoration(
                  labelText: 'Tanggal Meninggal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              TextFormField(
                initialValue: alamat,
                validator: (value) =>
                    value.isEmpty ? 'Alamat tidak boleh kosong' : null,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                maxLength: 50,
                maxLines: 1,
                onSaved: (value) => alamat = value,
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
              TextFormField(
                initialValue: lokasiSemayam,
                validator: (value) =>
                    value.isEmpty ? 'Lokasi tidak boleh kosong' : null,
                decoration: InputDecoration(
                  labelText: 'Tempat disemayamkan',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                maxLength: 50,
                maxLines: 1,
                onSaved: (value) => lokasiSemayam = value,
                textCapitalization: TextCapitalization.words,
              ),
              TextFormField(
                initialValue: tempatMakam,
                validator: (value) => value.isEmpty
                    ? 'Tempat dimakamkan tidak boleh kosong'
                    : null,
                decoration: InputDecoration(
                  labelText: 'Tempat Pemakaman/Kremasi',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                maxLength: 50,
                maxLines: 1,
                onSaved: (value) => tempatMakam = value,
                textCapitalization: TextCapitalization.words,
              ),
              DateTimePickerFormField(
                inputType: InputType.date,
                editable: false,
                format: dateFormat,
                initialValue: tanggalDimakamkan,
                validator: (value) => value.isBefore(tanggalMeninggal)
                    ? 'Tanggal Prosesi harus sesudah Tanggal Meninggal'
                    : null,
                onSaved: (value) => tanggalDimakamkan = value,
                decoration: InputDecoration(
                  labelText: 'Tanggal Pemakaman/Kremasi',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              DateTimePickerFormField(
                inputType: InputType.time,
                editable: false,
                format: timeFormat,
                initialValue: waktuDimakamkan,
                onSaved: (value) => waktuDimakamkan = value,
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
              TextFormField(
                initialValue: keterangan,
                validator: (value) =>
                    value.isEmpty ? 'Keterangan tidak boleh kosong' : null,
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
                onSaved: (value) => keterangan = value,
                textCapitalization: TextCapitalization.sentences,
              ),
            ],
          ),
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

  Widget buildProgressIndicator() {
    if (isUploading == true)
      return Expanded(
          child: LinearProgressIndicator(
        value: _progress,
      ));
    else if (isLoading == true)
      return Container(
          width: 20, height: 20, child: CircularProgressIndicator());
    else
      return SizedBox();
  }

  void getImageCamera() async {
    try {
      imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
      print('imageFile : $imageFile');
      setState(() {
        image = imageFile;
        isChanged = true;
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
        isChanged = true;
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
    readLocal();
    postRef = FirebaseDatabase.instance
        .reference()
        .child('posts')
        .child(widget.post.key);
    _prosesi = widget.post.prosesi;
    tanggalDimakamkan = dateFormat.parse(widget.post.tanggalSemayam);
    tanggalMeninggal = dateFormat.parse(widget.post.tanggalMeninggal);
    waktuDimakamkan = timeFormat.parse(widget.post.waktuDimakamkan);
    nama = widget.post.nama;
    agama = widget.post.agama;
    usia = widget.post.usia;
    alamat = widget.post.alamat;
    keterangan = widget.post.keterangan;
    lokasiSemayam = widget.post.lokasiSemayam;
    tempatMakam = widget.post.tempatMakam;
    tanggalSemayam = dateFormat.parse(widget.post.tanggalSemayam);
  }

  void pushData(_url) {
    try {
      print('Updating ....');
      crud.updatePost(widget.post.key, {
        'nama': nama,
        'usia': usia,
        'agama': agama,
        'photo': _url,
        'timestamp': timestamp,
        'userId': userId,
        'tanggalMeninggal': dateFormat.format(tanggalMeninggal),
        'alamat': alamat,
        'prosesi': _prosesi.toString(),
        'tempatMakam': tempatMakam,
        'tanggalSemayam': dateFormat.format(tanggalDimakamkan),
        'lokasiSemayam': lokasiSemayam,
        'waktuSemayam': timeFormat.format(waktuDimakamkan),
        'keterangan': keterangan
      });
    } catch (e) {
      print('error : $e');
    } finally {
      print('Updating selesai.......');
      Navigator.pop(context);
    }
  }

  void readLocal() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
  }

  void updatePost() async {
    print('Mencoba Update Posting');
    timestamp = DateTime.now().millisecondsSinceEpoch;

    if (isChanged == true) {
      uploadImage(image).then((_url) {
        pushData(_url);
      });
    } else {
      setState(() {
        isLoading = true;
      });
      pushData(widget.post.photo);
    }
  }

  Future<String> uploadImage(var imageFile) async {
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

  bool validateAndSave() {
    final form = formKey.currentState;

    form.save();

    if (form.validate()) {
      print('Posting valid');
      return true;
    } else {
      print('Posting tidak valid');
      return false;
    }
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        updatePost();
      } catch (e) {
        print('Error $e');
      }
    } else {
      formKey.currentState.reset();
    }
  }
}
