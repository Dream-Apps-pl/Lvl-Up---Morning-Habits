import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakeup/quiz/start_quiz.dart';
import 'package:wakeup/screens/main/alarm_list_screen.dart';
import 'package:wakeup/screens/main/clock_screen.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakeup/screens/main/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'common.dart';
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

AlarmList list = AlarmList();
MediaHandler mediaHandler = MediaHandler();
var playingSoundPath = ValueNotifier<String>("");
NotificationAppLaunchDetails? notificationAppLaunchDetails;
ScheduleNotifications notifications = ScheduleNotifications(
    'wakeup_notification',
    'Wake-up Alarm Notication',
    'Alerts on scheduled alarm events',
    appIcon: 'notification_logo');

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(Phoenix(
          child: MyApp(),
        ),
    );
  //     MaterialApp(
  //     debugShowCheckedModeBanner: false,
  //     initialRoute: 'home',
  //     routes: {
  //       'home': (_) => MainScreen(alarms: list,),
  //       'clock': (_) => ClockScreen(),
  //       'alarm': (_) => AlarmListScreen(alarms: list,),
  //       'quiz': (_) => StartQuiz(),
  //     }
  // ));



  WidgetsFlutterBinding.ensureInitialized();


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
  print('main_screen: ${externalPath!.path}');
  if (!externalPath.existsSync()) externalPath.create(recursive: true);
}

void restartApp() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  MyAppState createState() => MyAppState();
}

class MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();

  }


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
        print('main_screen: status.isAlarm ${status.isAlarm}');
        print('main_screen: list.alarms.length ${list.alarms.length}');
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



// Audio find(List<Audio> source, String fromPath) {
//   return source.firstWhere((element) => element.path == fromPath);
// }
//
// final audios = <Audio>[
//   Audio(
//     'assets/audios/1.mp3',
//     //playSpeed: 2.0,
//     metas: Metas(
//       id: 'Monday',
//       title: 'Monday',
//       artist: 'Wake Up Alarm',
//       album: 'Wake Up',
//       image: const MetasImage.network(
//           'https://static.radio.fr/images/broadcasts/cb/ef/2075/c300.png'),
//     ),
//   ),
// Audio.network(
//   'https://files.freemusicarchive.org/storage-freemusicarchive-org/music/Music_for_Video/springtide/Sounds_strange_weird_but_unmistakably_romantic_Vol1/springtide_-_03_-_We_Are_Heading_to_the_East.mp3',
//   metas: Metas(
//     id: 'Online',
//     title: 'Online',
//     artist: 'Florent Champigny',
//     album: 'OnlineAlbum',
//     // image: MetasImage.network('https://www.google.com')
//     image: MetasImage.network(
//         'https://image.shutterstock.com/image-vector/pop-music-text-art-colorful-600w-515538502.jpg'),
//   ),
// ),
// ];


}
