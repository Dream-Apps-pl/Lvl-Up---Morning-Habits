import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
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

import '../../main.dart';
import '../../quiz/start_quiz.dart';
import '../../widgets/alarm_item/alarm_item.dart';
import '../main/clock_screen.dart';
import '../main/alarm_list_screen.dart';


final assetsAudioPlayer = AssetsAudioPlayer();

class AlarmScreen extends StatefulWidget {
  final ObservableAlarm? alarm;
  const AlarmScreen({Key? key, required this.alarm}) : super(key: key);

  @override
  MyAppState createState() => MyAppState(alarm: alarm);

}

class MyAppState extends State<AlarmScreen> {
  final ObservableAlarm? alarm;

  MyAppState({Key? key, required this.alarm}) : super();


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
            // Navigator.of(context).pop();
            Navigator.push(context, MaterialPageRoute(builder: (context) => StartQuiz()),);
            //await dismissCurrentAlarm();
          }),
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
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

    super.initState();

    openPlayer();
  }

  var _currentAssetPosition = -1;

  late AssetsAudioPlayer _assetsAudioPlayer;


  void openPlayer() async {

    int x = DateTime.now().weekday - 1;
    //await _assetsAudioPlayer.playlistPlayAtIndex();

    await _assetsAudioPlayer.open(
        Playlist(audios: audios, startIndex: x),
        showNotification: true,
        autoStart: true,
        loopMode: LoopMode.single
    );

  }

  void _playPause() {
    _assetsAudioPlayer.playOrPause();
  }

  @override
  void dispose() {
    _assetsAudioPlayer.stop();
    super.dispose();
  }

  Audio find(List<Audio> source, String fromPath) {
    return source.firstWhere((element) => element.path == fromPath);
  }


  //final List<StreamSubscription> _subscriptions = [];
  final audios = <Audio>[

    Audio(
      'assets/audios/1.mp3',
      //playSpeed: 2.0,
      metas: Metas(
        id: 'Monday',
        title: 'Monday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
      ),
    ),
    Audio(
      'assets/audios/2.mp3',
      //playSpeed: 2.0,
      metas: Metas(
        id: 'Tuesday',
        title: 'Tuesday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
      ),
    ),
    Audio(
      'assets/audios/3.mp3',
      metas: Metas(
        id: 'Wednesday',
        title: 'Wednesday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.asset('assets/images/country.jpg'),
      ),
    ),
    Audio(
      'assets/audios/4.mp3',
      metas: Metas(
        id: 'Thursday',
        title: 'Thursday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
    Audio(
      'assets/audios/5.mp3',
      metas: Metas(
        id: 'Friday',
        title: 'Friday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://beyoudancestudio.ch/wp-content/uploads/2019/01/apprendre-danser.hiphop-1.jpg'),
      ),
    ),
    Audio(
      'assets/audios/6.mp3',
      metas: Metas(
        id: 'Saturday',
        title: 'Saturday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg'),
      ),
    ),
    Audio(
      'assets/audios/7.mp3',
      metas: Metas(
        id: 'Sunday',
        title: 'Sunday',
        artist: 'Wake Up Alarm',
        album: 'Wake Up',
        image: const MetasImage.network(
            'https://99designs-blog.imgix.net/blog/wp-content/uploads/2017/12/attachment_68585523.jpg'),
      ),
    ),
  ];




}