import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
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
import '../main/clock_screen.dart';

class AlarmScreen extends StatelessWidget {
  final ObservableAlarm? alarm;

  const AlarmScreen({Key? key, required this.alarm}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]); // fullscreen
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
          MaterialButton(
            onPressed: () async {

              mediaHandler.stopMusic();
              Wakelock.disable();
              AlarmStatus().isAlarm = false;
              AlarmStatus().alarmId = -1;
              Navigator.pushNamed(context, '/clock');

            },
            color: const Color(0xffffffff),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.0),
            ),
            padding: const EdgeInsets.all(16),
            textColor: const Color(0xff3a57e8),
            height: 5,
            minWidth: MediaQuery.of(context).size.width * 0.5,
            child: const Text(
              "Start Quiz!",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                fontStyle: FontStyle.normal,
              ),
            ),
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
          RoundedButton("Dismiss", fontSize: 45, onTap: () async {
            await dismissCurrentAlarm();
          }),
        ],
      ),
    );
  }

  Future<void> dismissCurrentAlarm() async {
    mediaHandler.stopMusic();
    Wakelock.disable();

    AlarmStatus().isAlarm = false;
    AlarmStatus().alarmId = -1;
    SystemNavigator.pop();
  }

  void goToQuiz() async {
    mediaHandler.stopMusic();
    Wakelock.disable();

    AlarmStatus().isAlarm = false;
    AlarmStatus().alarmId = -1;
    //SystemNavigator.pop();
    //Navigator.push(context, MaterialPageRoute(builder: (context) => MyApp()),);
    //Navigator.pushNamed(context, '/clock');
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
}
