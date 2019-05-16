import 'dart:convert';
import 'package:http/http.dart';
import 'package:meta/meta.dart';

class ApiService {
  static const String serverKey =
      'AAAA0Cg1n0E:APA91bElz_2ptsE8WRkaXJhg9ZB77wzYcoC2Rn-m7g9onREbmWvuDQcSyapSuq_ZdZr-TGhiSDSXdrCJAYOtgf0MYRQua3bmRGUzwCzMuoi-MT2c6VHiOjx6zTPU9M2PjrU9yupdH_nv';
  static final Client client = Client();

  static Future<Response> sendToAll({
    @required String title,
    @required String body,
  }) =>
      sendToTopic(title: title, body: body, topic: 'all');

  static Future<Response> sendToTopic(
          {@required String title,
          @required String body,
          @required String topic}) =>
      sendTo(title: title, body: body, fcmToken: '/topics/$topic');

  static Future<Response> sendTo({
    @required String title,
    @required String body,
    @required String fcmToken,
    @required String usia,
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
