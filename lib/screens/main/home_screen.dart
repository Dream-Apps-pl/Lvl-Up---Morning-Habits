import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../../components/alarm_item/alarm_item.dart';
import '../../components/bottom_add_button/bottom_add_button.dart';
import '../../components/default_container/default_container.dart';
import '../edit_alarm/components/edit_alarm_time.dart';
import '../../services/alarm_list_manager.dart';
import '../../services/alarm_scheduler.dart';
import '../../stores/alarm_list/alarm_list.dart';
import '../../stores/observable_alarm/observable_alarm.dart';

class HomeScreen extends StatelessWidget {
  final AlarmList alarms;

  HomeScreen({Key? key, required this.alarms}) : super(key: key);

  bool switchValue = false;
  bool visibleButton = true;

  @override
  Widget build(BuildContext context) {
    final AlarmListManager _manager = AlarmListManager(alarms);

    return DefaultContainer(
      child: Column(
        children: <Widget>[
          Text(
            'Wake Up',
            style: TextStyle(fontSize: 28, color: Colors.white),
          ),
          Flexible(
            child: Observer(
              builder: (context) =>
                  ListView.separated(
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final alarm = alarms.alarms[index];

                      return Dismissible(
                        key: Key(alarm.id.toString()),
                        child: AlarmItem(alarm: alarm, manager: _manager, alarms: alarms,),
                        onDismissed: (_) {
                          AlarmScheduler().clearAlarm(alarm);
                          alarms.alarms.removeAt(index);
                          visibleButton = true;
                          //Visible = !Visible;

                        },
                      );
                    },
                    itemCount: alarms.alarms.length,
                    separatorBuilder: (context, index) => const Divider(),
                  ),
            ),
          ),
          Visibility(
            child:
            BottomAddButton(
              onPressed: () {
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
                    ObservableList<String>.of([]),
                    <String>[]);

                alarms.alarms.add(newAlarm);

                //Navigator.push(context, MaterialPageRoute(builder: (context) => EditAlarmTime(alarm: newAlarm, manager: _manager),
                EditAlarmTime(alarm: newAlarm, manager: _manager);
                // EditAlarm(alarm: newAlarm, manager: _manager,),
                visibleButton = false;
                //Visible = !Visible;

              },
            ),
            visible: visibleButton,
          )
        ],
      ),
    );
  }
}

