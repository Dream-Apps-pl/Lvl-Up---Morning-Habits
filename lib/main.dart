import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:wakeup/quiz/start_quiz.dart';
import 'package:wakeup/screens/main/alarm_list_screen.dart';
import 'package:wakeup/screens/main/clock_screen.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakeup/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'constants/theme_data.dart';
import 'enums.dart';
import 'models/menu_info.dart';
import 'screens/alarm_screen/alarm_screen.dart';
import 'services/alarm_polling_worker.dart';
import 'services/file_proxy.dart';
import 'services/life_cycle_listener.dart';
import 'services/media_handler.dart';
import 'stores/alarm_list/alarm_list.dart';
import 'stores/alarm_status/alarm_status.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';
import 'utils/schedule_notifications.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class Strings {
  static const String appTitle = 'Wake Up Alarm';
}
final assetsAudioPlayer = AssetsAudioPlayer();

AlarmList list = AlarmList();
MediaHandler mediaHandler = MediaHandler();
var playingSoundPath = ValueNotifier<String>("");
NotificationAppLaunchDetails? notificationAppLaunchDetails;
ScheduleNotifications notifications = ScheduleNotifications(
    'wakeup_notification',
    'Wake-up Alarm Notication',
    'Alerts on scheduled alarm events',
    appIcon: 'notification_logo');

void main() async {

  runApp(
      Phoenix(
        child: MyApp(),
      ));

  WidgetsFlutterBinding.ensureInitialized();

  //Open Audio notification action
  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    return true;
  });


  final alarms = await new JsonFileStorage().readList();
  list.setAlarms(alarms);
  list.alarms.forEach((alarm) {
    alarm.loadTracks();
  });


  //Flutter 3.0 change
  T? _ambiguate<T>(T? value) => value;
  _ambiguate(WidgetsBinding.instance)!.addObserver(LifeCycleListener(list));


  await AndroidAlarmManager.initialize();


  AlarmPollingWorker().createPollingWorker();

  final externalPath = await getExternalStorageDirectory();
  print(externalPath!.path);
  if (!externalPath.existsSync()) externalPath.create(recursive: true);
}

void restartApp() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return NeumorphicApp(
      debugShowCheckedModeBanner: false,
      title: 'Wake Up',
      themeMode: ThemeMode.light,
      theme: NeumorphicThemeData(
          defaultTextColor: Color(0xFF303E57),
          accentColor: Color(0xFF7B79FC),
          variantColor: CustomColors.sdAppBackgroundColor,
          baseColor: CustomColors.sdAppBackgroundColor, // Color(0xFFF8F9FC),
          depth: 8,
          intensity: 0.5,
          lightSource: LightSource.topLeft),
      home: Observer(builder: (context) {
        AlarmStatus status = AlarmStatus();
        print('status.isAlarm ${status.isAlarm}');
        print('list.alarms.length ${list.alarms.length}');
        if (status.isAlarm) {
          final id = status.alarmId;
          final alarm = list.alarms.firstWhere((alarm) => alarm.id == id,
              orElse: () => ObservableAlarm());

          mediaHandler.playMusic(alarm);
          Wakelock.enable();

          return Material(
              child: NeumorphicBackground(child: AlarmScreen(alarm: alarm)));
        }
        return ChangeNotifierProvider<MenuInfo>(
          create: (context) => MenuInfo(MenuType.alarm, icon: Icons.timelapse), //Default open menu
          child: Material(
            child: NeumorphicBackground(
              child: MainScreen(alarms: list),
            ),
          ),
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _assetsAudioPlayer = AssetsAudioPlayer.newPlayer();

    super.initState();

    // openPlayer();
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
