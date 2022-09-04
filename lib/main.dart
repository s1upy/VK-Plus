import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:vk_plus/funcions/token_secret.dart';
import 'package:dart_vlc/dart_vlc.dart';

import 'pages/home.dart';
import 'pages/login.dart';

void main(List<String> args) async {
  await DartVLC.initialize();

  if (runWebViewTitleBarWidget(args)) {
    return;
  }
  WidgetsFlutterBinding.ensureInitialized();

  var tokenAndSecret = await getDataTokenAndSecret();

  if (tokenAndSecret == 'null') {
    runApp(const Login());
  } else {
    runApp(const Home());
  }
}
