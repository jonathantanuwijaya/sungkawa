import 'package:intl/intl.dart';

class Utilities {
  String convertTimestamp(int timestamp) {
    var now = new DateTime.now();
    var dateFormat = new DateFormat('dd/MM/yy');
    var timeFormat = new DateFormat('HH:mm');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var text = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      text = timeFormat.format(date);
    } else {
      text = dateFormat.format(date);
    }
    return text;
  }

  String convertCommentTimestamp(int timestamp) {
    var now = new DateTime.now();
    var timeFormat = new DateFormat('HH:mm');
    var dateFormat = new DateFormat('d/M');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var text = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      text = timeFormat.format(date);
    } else {
      text = dateFormat.format(date);
    }
    return text;
  }
}
