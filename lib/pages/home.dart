import 'package:flutter/material.dart';
import 'package:side_navigation/side_navigation.dart';
import 'package:vk_plus/pages/music.dart';

import '../components/musicBar.dart';
import '../styles/colors.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _MainViewState createState() => _MainViewState();
}

class _MainViewState extends State<Home> {
  List<Widget> views = [
    MaterialApp(
        home: Scaffold(
            body: Row(children: const [
      Text('Главная', style: TextStyle(color: Color(0xFFFFFFFF)))
    ]))),
    const Music(),
    MaterialApp(
        home: Scaffold(
            body: Row(children: const [
      Text('. . .', style: TextStyle(color: Color(0xFFFFFFFF)))
    ]))),
  ];

  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'VK Plus',
        theme: ThemeData(
            fontFamily: 'Gotham',
            primaryColor: const Color(0xddcc143c),
            primarySwatch: MaterialColor(0xFFFFFFFF, color),
            scaffoldBackgroundColor: const Color(0x00000000)),
        home: Scaffold(
          bottomNavigationBar: const MusicBar(),
          body: Row(
            children: [
              SideNavigationBar(
                footer: SideNavigationBarFooter(
                    label: TextButton(
                  child: const Text('Настройки',
                      style: TextStyle(fontSize: 15, color: Colors.white)),
                  onPressed: () => {},
                )),
                selectedIndex: selectedIndex,
                items: const [
                  SideNavigationBarItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Лента',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.music_note_rounded,
                    label: 'Музыка',
                  ),
                  SideNavigationBarItem(
                    icon: Icons.settings_rounded,
                    label: 'Настройки',
                  ),
                ],
                onTap: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },
                theme: const SideNavigationBarTheme(
                  backgroundColor: Color.fromARGB(122, 17, 17, 17),
                  togglerTheme: SideNavigationBarTogglerTheme(
                      shrinkIconColor: Color(0xddcc143c),
                      expandIconColor: Color(0xddcc143c)),
                  itemTheme: SideNavigationBarItemTheme(
                      selectedItemColor: Color(0xddcc143c),
                      unselectedItemColor: Colors.white),
                  dividerTheme: SideNavigationBarDividerTheme(
                      mainDividerColor: Color(0xddcc143c),
                      showFooterDivider: false,
                      showMainDivider: false,
                      showHeaderDivider: true),
                ),
              ),

              /// Make it take the rest of the available width
              Expanded(
                child: views.elementAt(selectedIndex),
              ),
            ],
          ),
        ));
  }
}
