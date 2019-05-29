import 'dart:convert';

import 'package:http/http.dart';
import 'package:meta/meta.dart';

class ApiService {
  static const String serverKey =
      'AAAA8m4GClk:APA91bGdv0XcmMsgfVm-WpD1SlykZHPZhuNiP9JTmJNtBcVvz6RMYF3fDigZdR6I8feTqSvOjX0cXQ-g0fI_zsY8bEZYHD5Hdw8e0UYbLU2UMwoL1i4lixPO6FJ4hEFakHxD_3yWnHkZ';
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
