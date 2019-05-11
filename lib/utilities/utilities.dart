import 'package:intl/intl.dart';

class Utilities {
  String convertTimestamp(int timestamp) {
    var now = new DateTime.now();
    var format = new DateFormat('HH:mm');
    var date = new DateTime.fromMicrosecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var timeText = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      timeText = format.format(date);
    } else {
      timeText = diff.inDays.toString() + ' HARI YANG LALU';
    }
    return timeText;
  }
}
