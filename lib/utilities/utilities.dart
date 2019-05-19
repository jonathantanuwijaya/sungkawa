import 'package:intl/intl.dart';

class Utilities {
  String convertPostTimestamp(int timestamp) {
    var now = new DateTime.now();
    var timeFormat = new DateFormat('HH:mm');
    var dateFormat = new DateFormat('dd-MM-yy');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp);
    var diff = now.difference(date);
    var timeText = '';

    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      timeText = timeFormat.format(date);
    } else {
      timeText = dateFormat.format(date);
    }
    return timeText;
  }

  String convertCommentTimestamp(int timestamp) {
    var now = new DateTime.now();
    var timeFormat = new DateFormat('HH:mm');
    var dateFormat = new DateFormat('d-M-yy');
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