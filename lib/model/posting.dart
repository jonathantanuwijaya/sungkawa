import 'package:firebase_database/firebase_database.dart';

class Posting {
  String _key;
  String _photo;
  String _nama,
      _agama,
      _userId,
      _tempatMakam,
      _usia,
      _keterangan,
      _tanggalSemayam,
      _lokasiSemayam,
      _lokasiMakam,
      _alamat,
      _tanggalMeninggal,
      _prosesi,
      _waktuSemayam;
  int _timestamp;

  Posting(
      this._key,
      this._photo,
      this._nama,
      this._agama,
      this._userId,
      this._tempatMakam,
      this._usia,
      this._keterangan,
      this._tanggalSemayam,
      this._lokasiSemayam,
      this._lokasiMakam,
      this._alamat,
      this._tanggalMeninggal,
      this._prosesi,
      this._waktuSemayam,
      this._timestamp);

  String get key => _key;

  String get photo => _photo;

  String get nama => _nama;

  get agama => _agama;

  get userId => _userId;

  get tempatMakam => _tempatMakam;

  String get usia => _usia;

  get keterangan => _keterangan;

  get tanggalSemayam => _tanggalSemayam;

  get lokasiSemayam => _lokasiSemayam;

  get lokasiMakam => _lokasiMakam;

  get alamat => _alamat;

  get tanggalMeninggal => _tanggalMeninggal;

  get prosesi => _prosesi;

  get waktuSemayam => _waktuSemayam;

  int get timestamp => _timestamp;

  Posting.fromSnapshot(DataSnapshot snapshot) {
    _key = snapshot.key;
    _userId = snapshot.value['userId'];
    _nama = snapshot.value["nama"];
    _usia = snapshot.value["usia"];
    _agama = snapshot.value['agama'];
    _photo = snapshot.value['photo'];
    _alamat = snapshot.value['alamat'];
    _tanggalMeninggal = snapshot.value["tanggalMeninggal"];
    _prosesi = snapshot.value["prosesi"];
    _lokasiSemayam = snapshot.value["lokasiSemayam"];
    _lokasiMakam = snapshot.value["lokasiMakam"];
    _tempatMakam = snapshot.value["tempatMakam"];
    _tanggalSemayam = snapshot.value["tanggalSemayam"];
    _waktuSemayam = snapshot.value["waktuSemayam"];
    _keterangan = snapshot.value["keterangan"];
    _timestamp = snapshot.value['timestamp'];
  }

  Posting.fromJson(Map<String, dynamic> json) {
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
    _tanggalSemayam = json["tanggalSemayam"];
    _waktuSemayam = json["waktuSemayam"];
    _keterangan = json["keterangan"];
    _timestamp = json['timestamp'];
  }

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
        'tanggalSemayam': _tanggalSemayam,
        'waktuSemayam': _waktuSemayam,
        'keterangan': _keterangan,
        'timestamp': _timestamp
      };
}
