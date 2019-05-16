import 'package:flutter/material.dart';

@immutable
class Notifikasi {
  final String title, nama, usia;

  const Notifikasi(
      {@required this.title, @required this.nama, @required this.usia});
}
