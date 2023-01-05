import 'dart:async';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:alarm/alarm.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:app_to_foreground/app_to_foreground.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakeup/services/file_proxy.dart';
import 'package:wakeup/stores/alarm_status/alarm_status.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';

import '../main.dart';

class AlarmScheduler {
  clearAlarm(ObservableAlarm alarm) {
    print("alarm_scheduler: clearAlarm: ${alarm.id}");
    for (var i = 0; i < 7; i++) {
      if (Platform.isAndroid) {
        AndroidAlarmManager.cancel(alarm.id! * 7 + i);
      }
    }
  }

  /*
    To wake up the device and run something on top of the lockscreen,
    this currently requires the hack from here to be implemented:
    https://github.com/flutter/flutter/issues/30555#issuecomment-501597824
  */
  Future<void> scheduleAlarm(ObservableAlarm alarm) async {
    final days = alarm.days;

    final scheduleId = alarm.id! * 7;

    print("alarm_scheduler: scheduleId: $scheduleId");
    print("alarm_scheduler: days.length: ${days.length}");

    bool repeatAlarm = false;

    for (var i = 0; i < days.length; i++) {
      if (Platform.isAndroid) {
        await AndroidAlarmManager.cancel(scheduleId + i);
      }

      print("alarm_scheduler: alarm.active: ${alarm.active}");
      print("alarm_scheduler: days[$i]: ${days[i]}");

      if (alarm.active! && days[i]) {
        // Repeat alarm
        print("alarm_scheduler: Alarm active for day $i");

        repeatAlarm = true;
        final targetDateTime = nextWeekday(i + 1, alarm.hour!, alarm.minute!);
        await newShot(targetDateTime, scheduleId + i);
      } else if (alarm.active! && !repeatAlarm && i == days.length - 1) {
        // One time alarm
        var checkedDay = DateTime.now();
        var targetDateTime = DateTime(checkedDay.year, checkedDay.month,
            checkedDay.day, alarm.hour!, alarm.minute!);

        if (targetDateTime.millisecondsSinceEpoch <
            checkedDay.millisecondsSinceEpoch) // Time past?
          targetDateTime =
              targetDateTime.add(Duration(days: 1)); // Prepare for next day

        print("alarm_scheduler: targetDateTime ${targetDateTime.toString()}");
        await newShot(targetDateTime, scheduleId + i);
      }
    }
  }

  DateTime nextWeekday(int weekday, alarmHour, alarmMinute) {
    var checkedDay = DateTime.now();

    if (checkedDay.weekday == weekday) {
      final todayAlarm = DateTime(checkedDay.year, checkedDay.month,
          checkedDay.day, alarmHour, alarmMinute);

      if (checkedDay.isBefore(todayAlarm)) {
        return todayAlarm;
      }
      return todayAlarm.add(Duration(days: 7));
    }

    while (checkedDay.weekday != weekday) {
      checkedDay = checkedDay.add(Duration(days: 1));
    }

    return DateTime(checkedDay.year, checkedDay.month, checkedDay.day,
        alarmHour, alarmMinute);
  }

  static SendPort? uiSendPort;

  // The callback for our alarm
  @pragma('vm:entry-point')
  static void callback(int id) async {
    print('callbackvm');
    final alarmId = callbackToAlarmId(id);

    createAlarmFlag(alarmId);
    // This will be null if we're running in the background.
    uiSendPort ??= IsolateNameServer.lookupPortByName(isolateName);
    uiSendPort?.send(null);
  }

  /// Because each alarm might need to be able to schedule up to 7 android alarms (for each weekday)
  /// a means is required to convert from the actual callback ID to the ID of the alarm saved
  /// in internal storage. To do so, we can assign a range of 7 per alarm and use ceil to get to
  /// get the alarm ID to access the list of songs that could be played
  static int callbackToAlarmId(int callbackId) {
    return (callbackId / 7).floor();
  }

  /// Creates a flag file that the main isolate can find on life cycle change
  /// For now just abusing the FileProxy class for testing
  static void createAlarmFlag(int id) async {
    print('alarm_scheduler: Creating a new alarm flag for ID $id');
    final dir = await getApplicationDocumentsDirectory();
    JsonFileStorage.toFile(File(dir.path + "/$id.alarm")).writeList([]);

    final alarms = await new JsonFileStorage().readList();
    var alarm = alarms.firstWhere((element) => element.id == id);

    if (alarm.active! && Platform.isAndroid) {
      print('alarm_scheduler: Jestem tu 1');
      restartApp();
      Timer(Duration(seconds: 2), () {
        print('alarm_scheduler: Jestem tu 2');
        AppToForeground.appToForeground();
      });
      return;
    }

    // final hours = alarm.hour.toString().padLeft(2, '0');
    // final minutes = alarm.minute.toString().padLeft(2, '0');

    // await notifications.init(onSelectNotification: (String? payload) async {
    //   // if (payload == null || payload.trim().isEmpty) return null;
    //   print('alarm_scheduler: notification payload $payload');
    //   throw Exception('alarm_scheduler: New Notification');
    //   // return;
    // });
    //
    // await notifications.getNotificationAppLaunchDetails().then((details) {
    //   notificationAppLaunchDetails = details;
    // });

    // notifications.show(
    //   id: id,
    //   icon: 'notification_logo',
    //   importance: Importance.max,
    //   priority: Priority.high,
    //   ticker: 'ticker',
    //   title: '$hours:$minutes',
    //   body: alarm.name,
    //   sound: RawResourceAndroidNotificationSound(''),
    //   payload: id.toString(),
    // );
  }

  Future<void> newShot(DateTime targetDateTime, int id) async {
    if (Platform.isAndroid) {
      await AndroidAlarmManager.oneShotAt(
        targetDateTime,
        id,
        callback,
        exact: true,
        wakeup: true,
        alarmClock: true,
        rescheduleOnReboot: true,
      );
    } else {
      await Alarm.set(
          alarmDateTime: targetDateTime,
          assetAudio: 'assets/audios/1.mp3',
          notifTitle: 'Lvl-Up',
          notifBody: 'wake up!',
          onRing: (() {
            AlarmStatus2().isAlarm = true;
          }));
    }
  }
}
