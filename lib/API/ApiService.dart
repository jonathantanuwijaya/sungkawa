import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class ApiService {
  static const String serverKey =
      'AAAAT3fyzbc:APA91bFE7txvrXjyJoVx7S3q-zoTArUrrDuaY2X_iPR8HIK2H6Ry_exwBzdDBv_Cd1P2tn1e3WHo4xKpM7g9CNtQQ1Ug2de_EY1iF87D2DZiJ_kfJ2z-7gidICdgMJY4gGXyRyTcbXKK';
  static final Client client = Client();

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic({@required String title,
    @required String body,
    @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
  }) =>
      client.post('https://fcm.googleapis.com/fcm/send',
          body: json.encode({
            'notification': {'body': '$body', 'title': '$title'},
            'priority': 'high',
            'data': {
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done',
            },
            'to': '$fcmToken',
          }),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'key=$serverKey'
          });
}
