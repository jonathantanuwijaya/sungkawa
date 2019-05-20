import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class ApiService {
  static const String serverKey =
      'AAAAi82Y9Do:APA91bFy6oFBsNyvLcxklu6wAUeWnC8NWP8gzLeR7Jyz37neUBIza1UvdakV6MGINnWQcvO8bAvqMgp311rabqX8ZSVJMM-3fVu5mZJoqh6rnuOfxzA5huH_4ySBSSkAHAbK8hJhxT9V';
  static final Client client = Client();

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
}
