import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:dart_vlc/dart_vlc.dart';
import 'package:vk_plus/pages/search_music.dart';

import '../VKAPI/login_and_music.dart';
import '../constants/images_href.dart';
import '../funcions/token_secret.dart';
import 'login.dart';
import 'my_music.dart';

class Music extends StatefulWidget {
  const Music({Key? key}) : super(key: key);

  @override
  State<Music> createState() => _MyAppState();
}

class AdjustableScrollController extends ScrollController {
  AdjustableScrollController([int extraScrollSpeed = 40]) {
    super.addListener(() {
      ScrollDirection scrollDirection = super.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = super.offset +
            (scrollDirection == ScrollDirection.reverse
                ? extraScrollSpeed
                : -extraScrollSpeed);
        scrollEnd = min(super.position.maxScrollExtent,
            max(super.position.minScrollExtent, scrollEnd));
        jumpTo(scrollEnd);
      }
    });
  }
}

String formatedTime(int secTime) {
  String getParsedTime(String time) {
    if (time.length <= 1) return "0$time";
    return time;
  }

  int min = secTime ~/ 60;
  int sec = secTime % 60;

  String parsedTime =
      "${getParsedTime(min.toString())}:${getParsedTime(sec.toString())}";

  return parsedTime;
}

Player player = Player(id: 0, commandlineArguments: ['--no-video']);

List<Map<String, String>> musicBarInfo = [{}];
late PageController pageController;

late TextEditingController searchController;

class _MyAppState extends State<Music> {
  // ignore: prefer_const_constructors
  Playlist playlist = Playlist(
    medias: [],
  );

  // ignore: prefer_typing_uninitialized_variables
  late var audioData;
  final listController = ScrollController();
  int count = 15;

  var items = [
    'Удалить',
    'Скачать',
  ];

  void playAudio(int index) {
    player.open(
      playlist,
      autoStart: false,
    );

    player.play();
    player.jumpToIndex(index);
  }

  getAudio() async {
    var tokenAndSecret = await getDataTokenAndSecret();

    if (tokenAndSecret == 'null') {
      runApp(const Login());
    }

    var audio = await vkApi(
        json.decode(tokenAndSecret)['token'].toString(),
        json.decode(tokenAndSecret)['secret'].toString(),
        'audio.get',
        'count=$count');

    count += 15;

    return audio['response']['items'];
  }

  void writeToPlaylist() async {
    var tokenAndSecret = await getDataTokenAndSecret();

    var allAudio = await vkApi(
        json.decode(tokenAndSecret)['token'].toString(),
        json.decode(tokenAndSecret)['secret'].toString(),
        'audio.get',
        'count=6000');

    for (int i = 0;
        i < int.parse(allAudio['response']['count'].toString());
        i++) {
      playlist.medias
          .add(Media.network(allAudio['response']['items'][i]['url']));
      musicBarInfo.add({
        'artist': allAudio['response']['items'][i]['artist'],
        'title': allAudio['response']['items'][i]['title'],
        'img': allAudio['response']['items'][i]['album']?['thumb']
                ?['photo_300'] ??
            noMusicImage
      });
    }
  }

  @override
  void initState() {
    super.initState();

    pageController = PageController();
    searchController = TextEditingController();

    writeToPlaylist();
    audioData = getAudio();

    listController.addListener(() async {
      if (listController.position.maxScrollExtent == listController.offset) {
        setState(() => {audioData = getAudio()});
      }
    });

    listController.addListener(() {
      ScrollDirection scrollDirection =
          listController.position.userScrollDirection;
      if (scrollDirection != ScrollDirection.idle) {
        double scrollEnd = listController.offset +
            (scrollDirection == ScrollDirection.reverse ? 20 : -20);
        scrollEnd = min(listController.position.maxScrollExtent,
            max(listController.position.minScrollExtent, scrollEnd));
        listController.jumpTo(scrollEnd);
      }
    });
  }

  @override
  void dispose() {
    pageController.dispose();
    listController.dispose();
    searchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(controller: pageController, children: [
      const MyMusic(),
      SingleChildScrollView(
        controller: listController,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                    width: 500,
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                          filled: true,
                          fillColor: Color(0xddcc143c),
                          labelText: 'Что сегодня послушаем?',
                          labelStyle: TextStyle(
                              color: Color.fromARGB(195, 255, 255, 255))),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    height: 50,
                    width: 60,
                    child: ElevatedButton(
                      onPressed: () => {setState(() => {})},
                      style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color(0xddcc143c))),
                      child: const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextButton(
                      onPressed: () => {pageController.jumpToPage(0)},
                      child: const Text('Моя музыка',
                          style: TextStyle(
                              fontSize: 24, color: Color(0xddcc143c))),
                    ),
                    TextButton(
                        onPressed: () => {pageController.jumpToPage(1)},
                        child: const Text('Рекомендации',
                            style: TextStyle(
                                fontSize: 24, color: Color(0xFFFFFFFF)))),
                  ]),
              const SizedBox(height: 20),
              FutureBuilder(
                  future: audioData,
                  builder: (context, AsyncSnapshot<dynamic> snapshot) {
                    if (snapshot.hasData) {
                      var data = snapshot.data!;

                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: data.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (index < data.length) {
                              String photo = data[index]['album']?['thumb']
                                          ?['photo_300']
                                      .toString() ??
                                  noMusicImage;

                              return ListTile(
                                onTap: () async {
                                  playAudio(index);
                                },
                                trailing: DropdownButton(
                                  icon: const Icon(Icons.keyboard_arrow_down),
                                  hint: Text(
                                      formatedTime(data[index]['duration'])
                                          .toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 12)),
                                  items: items.map((String items) {
                                    return DropdownMenuItem(
                                      value: items,
                                      child: Text(items),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    debugPrint(newValue.toString());
                                  },
                                ),
                                leading: Container(
                                  width: 50,
                                  height: 70,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: Image.network(photo).image)),
                                ),
                                title: Text(data[index]['title'],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14)),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 7),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(data[index]['artist'],
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              return const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20));
                            }
                          });
                    } else {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xddcc143c)));
                    }
                  }),
            ],
          ),
        ),
      ),
    ]));
  }
}
