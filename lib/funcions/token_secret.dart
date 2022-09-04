import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

import '../VKAPI/login_and_music.dart';

Future<String> getDataTokenAndSecret() async {
  String data = 'null';

  final directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/VK_Plus_Data.json');

  if (!file.existsSync()) {
    return data;
  } else {
    var validAudioCheck = await vkApi(
        json.decode(file.readAsStringSync())['token'],
        json.decode(file.readAsStringSync())['secret'],
        'audio.get',
        'count=1');

    if (validAudioCheck!['error'] != null) {
      if (validAudioCheck['error']['error_code'] == 25) {
        return data;
      }
    } else {
      data = await file.readAsString();
    }
  }

  return data;
}

void writeDataTokenAndSecret(String token, String secret) async {
  final directory = await getApplicationDocumentsDirectory();
  File file = File('${directory.path}/VK_Plus_Data.json');

  file.writeAsString('{ "token": "$token", "secret": "$secret" }');
}
