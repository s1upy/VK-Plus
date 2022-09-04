import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:vk_plus/funcions/token_secret.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'pages/home.dart';
import 'pages/login.dart';

void main(List<String> args) async {
  // Инициализация VLC плеера, с помощью которого будет воспроизводиться аудио
  await DartVLC.initialize();

  // Для работы WebView (страницы с духэтапкой)
  if (runWebViewTitleBarWidget(args)) {
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();

  // Получение токена из файла
  var tokenAndSecret = await getDataTokenAndSecret();

  // Если токена нет, то показывается страница логина
  if (tokenAndSecret == 'null') {
    runApp(const Login());
  } else {
    runApp(const Home());
  }
}
