import 'package:flutter/material.dart';
import 'package:dart_vlc/dart_vlc.dart';
import '../constants/images_href.dart';
import '../pages/music.dart';

class MusicBar extends StatefulWidget {
  const MusicBar({Key? key}) : super(key: key);

  @override
  State<MusicBar> createState() => _MyAppState();
}

class _MyAppState extends State<MusicBar> {
  PositionState trackState = PositionState();
  IconData playOrPauseIcon = Icons.play_arrow_rounded;
  String img = noMusicImage;
  String title = 'Вы не включили музыку :(';
  String artist = 'Музыка - это прекрасно';

  double volume = player.general.volume;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      player.positionStream.listen((PositionState state) {
        setState(() => trackState = state);
      });

      player.playbackStream.listen((PlaybackState state) {
        if (state.isPlaying) {
          //debugPrint(musicBarInfo[player.current.index! + 1]['title'].toString());
          setState(() => {
                playOrPauseIcon = Icons.pause_rounded,
                img = musicBarInfo[player.current.index! + 1]['img'].toString(),
                if (musicBarInfo[player.current.index! + 1]['title']
                        .toString()
                        .length >
                    20)
                  {
                    title =
                        '${musicBarInfo[player.current.index! + 1]['title'].toString().substring(0, 20)}...'
                  }
                else
                  {
                    title = musicBarInfo[player.current.index! + 1]['title']
                        .toString()
                  },
                if (musicBarInfo[player.current.index! + 1]['artist']
                        .toString()
                        .length >
                    20)
                  {
                    artist =
                        '${musicBarInfo[player.current.index! + 1]['artist'].toString().substring(0, 20)}...'
                  }
                else
                  {
                    artist = musicBarInfo[player.current.index! + 1]['artist']
                        .toString()
                  },
              });
        } else {
          setState(() => playOrPauseIcon = Icons.play_arrow_rounded);
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(122, 17, 17, 17),
      alignment: Alignment.center,
      height: 50,
      child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
                width: 40,
                height: 40,
                child: Image(image: Image.network(img).image)),
            const SizedBox(width: 5),
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14)),
                  Text(artist,
                      style: const TextStyle(color: Colors.grey, fontSize: 10))
                ]),
            const SizedBox(width: 5),
            IconButton(
              onPressed: () => player.previous(),
              icon: const Icon(
                Icons.skip_previous_rounded,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => player.playOrPause(),
              icon: Icon(
                playOrPauseIcon,
                color: Colors.white,
              ),
            ),
            IconButton(
              onPressed: () => player.next(),
              icon: const Icon(
                Icons.skip_next_rounded,
                color: Colors.white,
              ),
            ),
            SizedBox(
                width: 500,
                child: Slider(
                    min: 0,
                    max: trackState.duration?.inMilliseconds.toDouble() ?? 1.0,
                    value:
                        trackState.position?.inMilliseconds.toDouble() ?? 0.0,
                    onChanged: (double position) => player.seek(
                          Duration(
                            milliseconds: position.toInt(),
                          ),
                        ))),
            SizedBox(
                width: 200,
                child: Slider(
                  value: volume,
                  onChanged: (value) {
                    player.setVolume(value);
                    setState(() => volume = value);
                  },
                  min: 0.0,
                  max: 1.0,
                  divisions: 5,
                ))
          ]),
    );
  }
}
