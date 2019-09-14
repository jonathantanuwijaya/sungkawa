import 'package:firebase_database/firebase_database.dart';

class Post {
  String _key;
  String _photo;
  String _nama,
      _agama,
      _userId,
      _tempatMakam,
      _usia,
      _keterangan,
      _tanggalDimakamkan,
      _tanggalSemayam,
      _lokasiSemayam,
      _lokasiMakam,
      _alamat,
      _tanggalMeninggal,
      _prosesi,
      _waktuDimakamkan;
  int _timestamp;

  Post(
      this._key,
      this._photo,
      this._nama,
      this._agama,
      this._userId,
      this._tempatMakam,
      this._usia,
      this._keterangan,
      this._tanggalDimakamkan,
      this._tanggalSemayam,
      this._lokasiSemayam,
      this._lokasiMakam,
      this._alamat,
      this._tanggalMeninggal,
      this._prosesi,
      this._waktuDimakamkan,
      this._timestamp);

  Post.fromJson(Map<String, dynamic> json) {
    _userId = json['userId'];
    _nama = json["nama"];
    _usia = json["usia"];
    _agama = json['agama'];
    _photo = json['photo'];
    _alamat = json['alamat'];
    _tanggalMeninggal = json["tanggalMeninggal"];
    _prosesi = json["prosesi"];
    _lokasiSemayam = json["lokasiSemayam"];
    _lokasiMakam = json["lokasiMakam"];
    _tempatMakam = json["tempatMakam"];
    _tanggalDimakamkan = json["tanggalSemayam"];
    _waktuDimakamkan = json["waktuSemayam"];
    _keterangan = json["keterangan"];
    _timestamp = json['timestamp'];
  }

  Post.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _userId = snapshot.value['userId'];
    _nama = snapshot.value["nama"];
    _usia = snapshot.value["usia"];
    _agama = snapshot.value['agama'];
    _photo = snapshot.value['photo'];
    _alamat = snapshot.value['alamat'];
    _tanggalMeninggal = snapshot.value["tanggalMeninggal"];
    _tanggalSemayam = snapshot.value["tanggalSemayam"];
    _prosesi = snapshot.value["prosesi"];
    _lokasiSemayam = snapshot.value["lokasiSemayam"];
    _lokasiMakam = snapshot.value["lokasiMakam"];
    _tempatMakam = snapshot.value["tempatMakam"];
    _tanggalDimakamkan = snapshot.value["tanggalDimakamkan"];
    _waktuDimakamkan = snapshot.value["waktuDimakamkan"];
    _keterangan = snapshot.value["keterangan"];
    _timestamp = snapshot.value['timestamp'];
  }

  get agama => _agama;

  get alamat => _alamat;

  get keterangan => _keterangan;

  String get key => _key;

  get lokasiMakam => _lokasiMakam;

  get lokasiSemayam => _lokasiSemayam;

  String get nama => _nama;

  String get photo => _photo;

  get prosesi => _prosesi;

  get tanggalDimakamkan => _tanggalDimakamkan;

  get tanggalMeninggal => _tanggalMeninggal;

  get tanggalSemayam => _tanggalSemayam;

  get tempatMakam => _tempatMakam;

  int get timestamp => _timestamp;

  get userId => _userId;

  get usia => _usia;

  get waktuDimakamkan => _waktuDimakamkan;

  Map<String, dynamic> toJson() => {
        'userId': _userId,
        'nama': _nama,
        'usia': _usia,
        'agama': _agama,
        'photo': _photo,
        'alamat': _alamat,
        'tanggalMeninggal': _tanggalMeninggal,
        'prosesi': _prosesi,
        'lokasiSemayam': _lokasiSemayam,
        'lokasiMakam': _lokasiMakam,
        'tempatMakam': _tempatMakam,
        'tanggalSemayam': _tanggalDimakamkan,
        'waktuSemayam': _waktuDimakamkan,
        'keterangan': _keterangan,
        'timestamp': _timestamp
      };
}
