import 'package:flutter/material.dart';
import 'package:wakeup/constants/theme_data.dart';
import 'package:wakeup/services/alarm_list_manager.dart';
import 'package:wakeup/services/alarm_scheduler.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakeup/widgets/dialog_container/dialog_container.dart';

class EditAlarm extends StatelessWidget {
  final ObservableAlarm? alarm;
  final AlarmListManager? manager;

  EditAlarm({this.alarm, this.manager});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print('edit_alarm: onWillPop $alarm');
        await manager!.saveAlarm(alarm!);
        await AlarmScheduler().scheduleAlarm(alarm!);
        return true;
      },
      child: DialogContainer(
        child: SingleChildScrollView(
          child: Column(children: [
            Text(
              'Set Alarm',
              style:
                  TextStyle(color: CustomColors.sdPrimaryColor, fontSize: 28),
            ),
            SizedBox(
              height: 10,
            ),
            // Observer(
            //   builder: (context) => Neumorphic(
            //     style: NeumorphicStyle(
            //       shape: NeumorphicShape.concave,
            //       // boxShape: NeumorphicBoxShape.roundRect(BorderRadius.circular(12)),
            //       depth: this.alarm!.active! ? 2 : 1,
            //       intensity: this.alarm!.active! ? 9 : 2,
            //     ),
            //     child: Padding(
            //       padding: const EdgeInsets.all(20),
            //       child: Column(
            //         children: <Widget>[
            //           //EditAlarmHead(alarm: this.alarm!),
            //           Divider(),
            //           EditAlarmTime(alarm: this.alarm!), //Time edite
            //           //Divider(),
            //           //text("repeat", fontSize: CustomFontSize.textSizeSmall),
            //           //EditAlarmDays(alarm: this.alarm!),
            //           //Divider(),
            //           SizedBox(
            //             height: 10,
            //           ),
            //           //EditAlarmMusic(alarm: this.alarm!),
            //           Divider(),
            //           Row(
            //               mainAxisAlignment: MainAxisAlignment.center,
            //               children: [
            //             //Expanded(child: EditAlarmSlider(alarm: this.alarm!)),
            //             SimpleButton("Done", onPressed: () async {
            //               await manager!.saveAlarm(alarm!);
            //
            //               AlarmStatus status = AlarmStatus();
            //               print('edit_alarm: status.isAlarm ${status.isAlarm}');
            //               print('edit_alarm: list.alarms.length ${list.alarms.length}');
            //
            //               await AlarmScheduler().scheduleAlarm(alarm!);
            //
            //               print('edit_alarm2: status.isAlarm ${status.isAlarm}');
            //               print('edit_alarm2: list.alarms.length ${list.alarms.length}');
            //
            //               Navigator.pop(context);
            //             })
            //           ])
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ]),
        ),
      ),
    );
  }
}
