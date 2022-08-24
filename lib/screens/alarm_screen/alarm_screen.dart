import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakeup/constants/theme_data.dart';
import 'package:wakeup/services/alarm_scheduler.dart';
import 'package:wakeup/utils/widget_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wakeup/stores/alarm_status/alarm_status.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakeup/widgets/rounded_button.dart';
import 'package:wakelock/wakelock.dart';

import '../../common.dart';
import '../../main.dart';
import '../../quiz/start_quiz.dart';
import '../../widgets/alarm_item/alarm_item.dart';
import '../main/clock_screen.dart';
import '../main/alarm_list_screen.dart';


class AlarmScreen extends StatefulWidget {
  final ObservableAlarm? alarm;
  const AlarmScreen({Key? key, required this.alarm}) : super(key: key);

  @override
  AlarmScreenState createState() => AlarmScreenState(alarm: alarm);

}

class AlarmScreenState extends State<AlarmScreen> {
  final ObservableAlarm? alarm;

  final MyAppState mainState = new MyAppState();

  AlarmScreenState({Key? key, required this.alarm}) : super();


  static int nextMediaId = 0;
  late AudioPlayer player;
  final playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/1.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Monday",
        artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/2.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Tuesday",
        artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/3.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Wednesday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/4.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Thursday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/5.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Friday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/6.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Saturday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/7.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Sunday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
  ]);
  int _addedCount = 0;



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: []); // fullscreen
    final now = DateTime.now();
    final format = DateFormat('Hm');
    final snoozeTimes = [5, 10, 15, 20];

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Center(
            child: Container(
              width: 325,
              height: 325,
              decoration: ShapeDecoration(
                  shape: CircleBorder(
                      side: BorderSide(
                          color: CustomColors.sdPrimaryBgLightColor,
                          style: BorderStyle.solid,
                          width: 50))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: CustomColors.sdPrimaryColor,
                    size: 32,
                  ),
                  Text(
                    format.format(now),
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color: CustomColors.sdPrimaryColor),
                  ),
                  Container(
                    width: 250,
                    child: Text(
                      alarm!.name!,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: CustomColors.sdPrimaryColor, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          RoundedButton("Start Today", fontSize: 55, onTap: () async {
            //mediaHandler.stopMusic();

            Wakelock.disable();
            AlarmStatus().isAlarm = false;
            AlarmStatus().alarmId = -1;

            AlarmStatus status = AlarmStatus();
            print('alarm_screen: status.isAlarm ${status.isAlarm}');
            print('alarm_screen: list.alarms.length ${list.alarms.length}');
            Navigator.of(context).pop();
            //Navigator.push(context, MaterialPageRoute(builder: (context) => StartQuiz()),);

            //await dismissCurrentAlarm();
          }),
          NeumorphicButton(
            padding: EdgeInsets.all(18),
            style: NeumorphicStyle(
              boxShape: NeumorphicBoxShape.circle(),
              shape: NeumorphicShape.flat,
              depth: 2,
              intensity: 0.7,
            ),
            child: Icon(
              player.playing ? Icons.pause : Icons.play_arrow,
            ),
            onPressed: () {

              setState(() {
                // If the video is playing, pause it.
                if (player.playing) {
                  player.pause();
                  print('alarm_screen: PAUSE');
                } else {
                  player.play();
                  print('alarm_screen: PLAY');
                }
              });

              //menuInfo.updateMenu();
            },
          ),

          // SizedBox(
          //   height: 0,
          // ),
          // GestureDetector(
          //   onTap: () async {
          //     await rescheduleAlarm(5);
          //   },
          //   child: text("Snooze", textColor: CustomColors.sdPrimaryColor),
          // ),
          // Row(
          //   crossAxisAlignment: CrossAxisAlignment.center,
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: snoozeTimes
          //       .map((minutes) => RoundedButton(
          //             "+$minutes\m",
          //             fontSize: 24,
          //             onTap: () async {
          //               await rescheduleAlarm(minutes);
          //             },
          //           ))
          //       .toList(),
          // ),
          SizedBox(
            height: 45,
          ),
          // RoundedButton("Stop Music", fontSize: 45, onTap: () async {
          //   mediaHandler.stopMusic();
          //   //await dismissCurrentAlarm();
          // }),
        ],
      ),
    );
  }

  Future<void> dismissCurrentAlarm() async {
    //mediaHandler.stopMusic();
    Wakelock.disable();

    AlarmStatus().isAlarm = false;
    AlarmStatus().alarmId = -1;
    SystemNavigator.pop();
  }

  Future<void> rescheduleAlarm(int minutes) async {
    // Re-schedule alarm
    var checkedDay = DateTime.now();
    var targetDateTime = DateTime(checkedDay.year, checkedDay.month,
        checkedDay.day, alarm!.hour!, alarm!.minute!);
    await AlarmScheduler()
        .newShot(targetDateTime.add(Duration(minutes: minutes)), alarm!.id!);
    dismissCurrentAlarm();
  }



  @override
  void initState() {
    super.initState();

    player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black,));
    init();

    try {
      play();
    } catch (e, stackTrace) {
      print('alarm_screen: $stackTrace');
    }

  }

  void init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    player.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('main_screen: A stream error occurred: $e');});

    try {
      int x = DateTime.now().weekday - 1; //song of a week
      await player.setAudioSource(playlist, initialIndex: x, initialPosition: Duration.zero);
      await player.setLoopMode(LoopMode.one);
      await player.setShuffleModeEnabled(false);

      //await play();
      // await _player.play();

    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("main_screen: Error loading playlist: $e");
      print('main_screen: $stackTrace');
    }
  }

  // Request audio play
  void play() async {
    if (mounted) {
      await player.play();
    }

  }

  // Request audio pause
  void pause() async {
    if (mounted) {
      await player.pause();
    }
  }

  @override
  void dispose() async {
    if (mounted) {
      await player.dispose();
    }
    print('main_screen: Dispose Audio Player');
    super.dispose();
  }

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          player.positionStream,
          player.bufferedPositionStream,
          player.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));








}