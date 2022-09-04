import 'package:desktop_webview_window/desktop_webview_window.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../funcions/token_secret.dart';
import '../VKAPI/login_and_music.dart';
import '../styles/colors.dart';
import 'home.dart';

final Uri _url = Uri.parse('https://vk.com/restore');

Future<void> _launchUrl() async {
  if (!await launchUrl(_url)) {
    throw 'Could not launch $_url';
  }
}

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _MyAppState();
}

class _MyAppState extends State<Login> {
  final loginFieldController = TextEditingController();
  final passwordFieldController = TextEditingController();

  String errorText = '';

  // Функция для авторизации пользователя
  login(String login, String password) async {
    var vkLoginInfo = await vkLogin(login, password);

    setState(() {
      errorText = '';
    });

    // Неправильный логин или пароль
    if (vkLoginInfo['error_type'] == 'username_or_password_is_incorrect') {
      return setState(() {
        errorText = 'Неправильный Логин или Пароль';
      });
    }

    var token;
    var secret;

    if (vkLoginInfo['token'] == null && vkLoginInfo['redirect_uri'] != null) {
      final webview = await WebviewWindow.create();

      webview
        ..setBrightness(Brightness.dark)
        ..setApplicationNameForUserAgent("WebviewExample/1.0.0")
        ..launch(vkLoginInfo['redirect_uri'])
        ..addOnUrlRequestCallback((url) {
          // Отмена авторизации пользователем
          if (url == 'https://oauth.vk.com/blank.html#fail=1') {
            setState(() {
              errorText = 'Вы отменили авторизацию';
            });
            webview.close();
            return;
          }

          // Авторизация прошла успешно
          if (url.startsWith('https://oauth.vk.com/blank.html#success=1')) {
            token = url
                .split('&')
                .asMap()[1]
                ?.split('access_token=')
                .asMap()[1]
                .toString();
            secret = url
                .split('&')
                .asMap()[3]
                ?.split('secret=')
                .asMap()[1]
                .toString();

            validAudioCheckFunc(token, secret);

            webview.close();
            return;
          }
        })
        ..onClose.whenComplete(() {
          setState(() {
            errorText = 'Вы отменили вход';
          });
        });
    } else {
      validAudioCheckFunc(
          vkLoginInfo['token'].toString(), vkLoginInfo['secret'].toString());

      token = vkLoginInfo['token'];
      secret = vkLoginInfo['secret'];
      return;
    }
  }

  validAudioCheckFunc(String token, String secret) async {
    var validAudioCheck = await vkApi(token, secret, 'audio.get', 'count=1');

    if (validAudioCheck!['error'] != null) {
      if (validAudioCheck['error']['error_code'] == 25) {
        return setState(() => {
              errorText =
                  'Отключите защиту от подозрительных приложений в VK ID (VK ID / Безопасность и вход / Защита от подозрительных приложений). Это нужно для работы музыки'
            });
      }
    }

    writeDataTokenAndSecret(token, secret);
    runApp(const Home());
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VK Plus',
      theme: ThemeData(
          fontFamily: 'Gotham',
          primaryColor: Colors.pink,
          primarySwatch: MaterialColor(0xFFFFFFFF, color),
          scaffoldBackgroundColor: const Color(0x00000000)),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset('assets/images/vk_plus_logo.png',
                    height: 300, width: 300),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: loginFieldController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xddcc143c),
                        border: OutlineInputBorder(),
                        labelText: 'Логин',
                        labelStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: passwordFieldController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xddcc143c),
                        border: OutlineInputBorder(),
                        labelText: 'Пароль',
                        labelStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                const TextButton(
                  onPressed: _launchUrl,
                  child: Text('Не помните пароль?',
                      style: TextStyle(color: Color(0xddcc143c))),
                ),
                const SizedBox(height: 10),
                Text(errorText,
                    style: const TextStyle(color: Color(0xddcc143c))),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  width: 200,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        login(loginFieldController.text,
                            passwordFieldController.text);
                      })
                    },
                    style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xddcc143c))),
                    child: const Text('Войти',
                        style: TextStyle(fontSize: 24, color: Colors.white)),
                  ),
                )
                //SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
