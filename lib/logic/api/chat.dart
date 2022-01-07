import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:americonictv_mobile/data/auth/user_data.dart';

abstract class ChatApi {
  static Future getChatsWithUser(String userId) async {
    final response = jsonDecode((await http.get(
            'https://video.americonictv.com/admin/plugin/API/get.json.php?APIName=chat2_chat'
            '&user=${User.instance.user}&pass=${User.instance.pass}&to_users_id=$userId&encodedPass=true'))
        .body);

    print(response);

    return response;
  }

  static Future searchForUsers(String searchTerm) async => jsonDecode((await http.get(
          'https://video.americonictv.com/plugin/API/get.json.php?APIName=users_list'
          '&APISecret=b50659819eb61ceae567ecd5dd51ea31&rowCount=3&searchPhrase=$searchTerm'))
      .body);

  static Future newMessage(String userId, String message) async =>
      jsonDecode((await http.post(
              'https://video.americonictv.com/admin/plugin/API/set.json.php?APIName=chat2_message&users_id=$userId'
              '&user=${User.instance.user}&pass=${User.instance.pass}&encodedPass=true',
              body: {'message': message}))
          .body);
}
