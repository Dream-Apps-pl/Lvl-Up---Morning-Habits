import 'dart:async';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:wakeup/screens/main/home_screen.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'screens/alarm_screen/alarm_screen.dart';
import 'services/alarm_polling_worker.dart';
import 'services/file_proxy.dart';
import 'services/life_cycle_listener.dart';
import 'services/audio_handler.dart';
import 'stores/alarm_list/alarm_list.dart';
import 'stores/alarm_status/alarm_status.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';
import 'utils/schedule_notifications.dart';

class Strings {
  static const String appTitle = 'Wake Up Alarm';
}

AlarmList list = AlarmList();
MyAudioHandler audioHandler = MyAudioHandler();

var playingSoundPath = ValueNotifier<String>("");

NotificationAppLaunchDetails? notificationAppLaunchDetails;
ScheduleNotifications notifications = ScheduleNotifications(
    'wakeup_notification',
    'Wake-up Alarm Notication',
    'Alerts on scheduled alarm events',
    appIcon: 'notification_logo');

Future<void> main() async {

  runApp(
    Phoenix(
          child: MyApp(),
        ),
    );

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
  print('main: path: ${externalPath!.path}');
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
  void initState() {
    super.initState();

  }


  @override
  void dispose() {
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wake Up',
      themeMode: ThemeMode.light,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color.fromRGBO(0, 0, 0, 1),
      ),
      home: Observer(builder: (context) {
        AlarmStatus2 status = AlarmStatus2();
        print('main: status.isAlarm ${status.isAlarm}');
        print('main: list.alarms.length ${list.alarms.length}');
        if (status.isAlarm) {
          final id = status.alarmId;
          final alarm = list.alarms.firstWhere((alarm) => alarm.id == id,
              orElse: () => ObservableAlarm());

          audioHandler.play;
          Wakelock.enable();

          print('main: uruchamiam alarm! ');

          return AlarmScreen(alarm: alarm, audioHandler: audioHandler,);
        }
        return HomeScreen(alarms: list);

        //   ChangeNotifierProvider<MenuInfo>(
        //   create: (context) => MenuInfo(MenuType.alarm, icon: Icons.timelapse), //Default open menu
        //   child: Material(
        //     child: NeumorphicBackground(
        //       child: MainScreen(alarms: list),
        //     ),
        //   ),
        // );
      }),
    );
  }



}
