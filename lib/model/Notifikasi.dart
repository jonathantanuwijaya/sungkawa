import 'package:flutter/material.dart';

@immutable
class Notifikasi {
  final String title, nama;

  const Notifikasi({
    @required this.title,
    @required this.nama,
  });
}
