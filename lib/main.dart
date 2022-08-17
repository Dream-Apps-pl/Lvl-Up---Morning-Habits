import 'dart:async';

import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
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
  WidgetsFlutterBinding.ensureInitialized();

  final alarms = await new JsonFileStorage().readList();
  list.setAlarms(alarms);
  list.alarms.forEach((alarm) {
    alarm.loadTracks();
  });

  //WidgetsBinding.instance!.addObserver(LifeCycleListener(list));
  //Flutter 3.0 change
  T? _ambiguate<T>(T? value) => value;
  _ambiguate(WidgetsBinding.instance)!.addObserver(LifeCycleListener(list));


  await AndroidAlarmManager.initialize();

  runApp(MyApp());

  AlarmPollingWorker().createPollingWorker();

  final externalPath = await getExternalStorageDirectory();
  print(externalPath!.path);
  if (!externalPath.existsSync()) externalPath.create(recursive: true);
}

void restartApp() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: Strings.appTitle,
    initialRoute: '/home',
    routes: <String, WidgetBuilder>{
        '/home': (BuildContext context) => new MyApp(),
        '/alarm' : (BuildContext context) => new AlarmScreen(alarm: null,),
        '/clock' : (BuildContext context) => new ClockScreen()
      //'alarm': (_) => AlarmListScreen(),
      // 'quick_alarm': (_) => const AlarmPage(title: "Quick Alarm!"),
      // 'quiz': (_) => const StartQuiz(),
    },
  ));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
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
          create: (context) => MenuInfo(MenuType.clock, icon: Icons.timelapse),
          child: Material(
            child: NeumorphicBackground(
              child: MainScreen(alarms: list),
            ),
          ),
        );
      }),
    );
  }
}
