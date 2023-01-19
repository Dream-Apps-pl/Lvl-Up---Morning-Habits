import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakelock/wakelock.dart';
import 'package:wakeup/screens/main/home_screen.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';

import 'screens/alarm_screen/alarm_screen.dart';
import 'services/alarm_polling_worker.dart';
import 'services/audio_handler.dart';
import 'services/file_proxy.dart';
import 'services/life_cycle_listener.dart';
import 'stores/alarm_list/alarm_list.dart';
import 'stores/alarm_status/alarm_status.dart';
import 'utils/schedule_notifications.dart';

class Strings {
  static const String appTitle = 'Wake Up Alarm';
}

/// The name associated with the UI isolate's [SendPort].
const String isolateName = 'isolate';

/// A port used to communicate from a background isolate to the UI isolate.
ReceivePort port = ReceivePort();

AlarmList list = AlarmList();
MyAudioHandler audioHandler = MyAudioHandler();

var playingSoundPath = ValueNotifier<String>("");

NotificationAppLaunchDetails? notificationAppLaunchDetails;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
  );
  runApp(
    Phoenix(
      child: MyApp(),
    ),
  );

  final alarms = await new JsonFileStorage().readList();

  list.setAlarms(alarms);
  list.alarms.forEach((alarm) {
    alarm.loadTracks();
  });

  //Flutter 3.0 change
  T? _ambiguate<T>(T? value) => value;
  _ambiguate(WidgetsBinding.instance)!.addObserver(LifeCycleListener(list));

  // Register the UI isolate's SendPort to allow for communication from the
  // background isolate.
  IsolateNameServer.registerPortWithName(
    port.sendPort,
    isolateName,
  );
  if (Platform.isAndroid) {
    await AndroidAlarmManager.initialize();
  }

  AlarmPollingWorker().createPollingWorker();

  final externalPath = Platform.isAndroid
      ? await getExternalStorageDirectory() //FOR ANDROID
      : await getApplicationSupportDirectory(); //FOR iOS
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
  static SendPort? uiSendPort;

  @override
  void initState() {
    super.initState();
    // if (Platform.isIOS) {
    Alarm.init();
    // }
    callback();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // The callback for our alarm
  @pragma('vm:entry-point')
  static Future<void> callback() async {
    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
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
          if (mounted && Platform.isAndroid) {
            audioHandler.play();
          }
          Wakelock.enable();

          print('main: uruchamiam alarm! ');

          return AlarmScreen(
            alarm: alarm,
            audioHandler: audioHandler,
          );
        }
        return HomeScreen(alarms: list);
      }),
    );
  }
}
