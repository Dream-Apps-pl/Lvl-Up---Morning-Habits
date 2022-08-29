import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:mobx/mobx.dart';
import 'package:wakeup/widgets/alarm_item/alarm_item.dart';
import 'package:wakeup/screens/edit_alarm/edit_alarm.dart';
import 'package:wakeup/services/alarm_list_manager.dart';
import 'package:wakeup/services/alarm_scheduler.dart';
import 'package:wakeup/stores/alarm_list/alarm_list.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';

import '../../main.dart';
import '../../stores/alarm_status/alarm_status.dart';
import 'home_screen.dart';

class AlarmListScreen extends StatelessWidget {
  final AlarmList alarms;

  const AlarmListScreen({Key? key, required this.alarms}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final AlarmListManager _manager = AlarmListManager(alarms);

    return Container(
      padding: EdgeInsets.only(left: 32, right: 32, top: 64, bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          NeumorphicText(
            "Wake Up",
            style: NeumorphicStyle(
              depth: 3,
              intensity: 14,
            ),
            textStyle: NeumorphicTextStyle(
                fontSize: 42, //customize size here
                fontWeight: FontWeight.w900
                // AND others usual text style properties (fontFamily, fontWeight, ...)
                ),
          ),
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  Observer(
                    builder: (context) => ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final alarm = alarms.alarms[index];

                        return Dismissible(
                          key: Key(alarm.id.toString()),
                          child: AlarmItem(alarm: alarm, manager: _manager),
                          onDismissed: (_) {
                            AlarmScheduler().clearAlarm(alarm);
                            alarms.alarms.removeAt(index);
                          },
                        );
                      },
                      itemCount: alarms.alarms.length,
                      //
                      separatorBuilder: (context, index) => const Divider(),
                    ),
                  ),
                  NeumorphicButton(
                    margin: EdgeInsets.only(top: 50),
                    style: NeumorphicStyle(
                      boxShape: NeumorphicBoxShape.circle(),
                      depth: 2,
                      intensity: 0.7,
                    ),
                    child: NeumorphicIcon(
                      Icons.add_circle,
                      size: 80,
                      style: NeumorphicStyle(color: Colors.white70),
                    ),
                    onPressed: () {

                      // HomeScreen().setState(() {
                      //   HomeScreen().visibleButton = false;
                      // });
                      addAlarm(context, _manager);

                    },
                  ),
                ],
              ),
            ),
          ),

          // BottomAddButton(
          //   onPressed: () {
          //     },
          // )
        ],
      ),
    );
  }



  void addAlarm(context, _manager) {
    TimeOfDay tod = TimeOfDay.fromDateTime(DateTime.now());

    final newAlarm = ObservableAlarm.dayList(
        alarms.alarms.length,
        'Alarm',
        tod.hour,
        tod.minute,
        0.9,
        false,
        true,
        List.filled(7, false),
        ObservableList<String>.of([]), <String>[]);

        alarms.alarms.add(newAlarm);

      AlarmStatus status = AlarmStatus();
      print('alarm_list_screen: status.isAlarm ${status.isAlarm}');
      print('alarm_list_screen: list.alarms.length ${list.alarms.length}');

        Navigator.push(context, MaterialPageRoute(builder: (context) => EditAlarm(alarm: newAlarm, manager: _manager,),),);

  }
}
