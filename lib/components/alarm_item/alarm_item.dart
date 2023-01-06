import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import '../../constants/theme_data.dart';
import '../../services/alarm_list_manager.dart';
import '../../services/alarm_scheduler.dart';
import '../../stores/alarm_list/alarm_list.dart';
import '../../stores/observable_alarm/observable_alarm.dart';

const dates = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];

class AlarmItem extends StatelessWidget {
  final AlarmList alarms;
  final ObservableAlarm alarm;
  final AlarmListManager manager;

  AlarmItem(
      {Key? key,
      required this.alarm,
      required this.manager,
      required this.alarms})
      : super(key: key);

  // late String hours = '10';
  // late String minutes = '10';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final time = await showTimePicker(
            context: context,
            // Uncomment when will show default as input
            // initialEntryMode: TimePickerEntryMode.input, 
            initialTime: TimeOfDay(hour: alarm.hour!, minute: alarm.minute!));
        if (time == null) {
          return;
        }
        alarm.hour = time.hour;
        alarm.minute = time.minute;

        print('edit_alarm_time: $alarm');
        await manager.saveAlarm(alarm);
        await AlarmScheduler().scheduleAlarm(alarm);
        // return true;
      },
      // () =>
      // Navigator.push(context, MaterialPageRoute(builder: (context) => EditAlarmTime(alarm: this.alarm, manager: manager))),
      //EditAlarm(alarm: this.alarm, manager: manager))),
      child: Observer(
        builder: (context) => Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(alarm.name!),
                    Text(
                      '${alarm.hour.toString().padLeft(2, '0')}:${alarm.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w800, //FontWeight.bold,
                          color: CustomColors.sdTextPrimaryColor),
                    ),
                    //DateRow(alarm: alarm)
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.delete_forever, color: Colors.deepOrange),
                  onPressed: () {
                    AlarmScheduler().clearAlarm(alarm);
                    alarms.alarms.removeAt(0);
                    //alarm.active = !alarm.active!;
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DateRow extends StatelessWidget {
  final ObservableAlarm alarm;
  final List<bool> dayEnabled;

  DateRow({
    Key? key,
    required this.alarm,
  })  : dayEnabled = [
          alarm.monday!,
          alarm.tuesday!,
          alarm.wednesday!,
          alarm.thursday!,
          alarm.friday!,
          alarm.saturday!,
          alarm.sunday!
        ],
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      size: Size(150, 25),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: dates.asMap().entries.map((indexStringPair) {
          final dayString = indexStringPair.value;
          final index = indexStringPair.key;
          return Text(
            dayString,
            style: TextStyle(
                fontWeight:
                    dayEnabled[index] ? FontWeight.bold : FontWeight.normal),
          );
        }).toList(),
      ),
    );
  }
}
