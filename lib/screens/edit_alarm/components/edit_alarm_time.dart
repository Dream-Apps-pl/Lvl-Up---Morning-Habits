import 'package:wakeup/constants/theme_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';

class EditAlarmTime extends StatelessWidget {
  final ObservableAlarm alarm;

  const EditAlarmTime({Key? key, required this.alarm}) : super(key: key);


  Future<void> showTPicker(context) async {
    // This is your function
    await Future.delayed(Duration(seconds: 1)); //2sec delay
    showPicker(context);
  }

  showPicker(context) async {
    // This is your function
    final time = await showTimePicker(
              context: context,
              initialTime: TimeOfDay(hour: alarm.hour!, minute: alarm.minute!));
          if (time != null) {
            alarm.hour = time.hour;
            alarm.minute = time.minute;
          }
  }



  @override
  Widget build(context) {
    return FutureBuilder(
      // Waiting your async function to finish
      future: showTPicker(context),
      builder: (context, snapshot) {
        // Async function finished
        if (snapshot.connectionState == ConnectionState.done) {
          // To access the function data when is done
          // you can take it from **snapshot.data**
          return Center(
            child: GestureDetector(
              child: Observer(builder: (context) {
                final hours = alarm.hour.toString().padLeft(2, '0');
                final minutes = alarm.minute.toString().padLeft(2, '0');
                return Text(
                  '$hours:$minutes',
                  style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.w800,
                      color: CustomColors.sdPrimaryColor),
                );
              }),
              onTap: () => showPicker(context),
              //     () async {
              //   final time = await showTimePicker(
              //       context: context,
              //       initialTime: TimeOfDay(hour: alarm.hour!, minute: alarm.minute!));
              //   if (time != null) {
              //     alarm.hour = time.hour;
              //     alarm.minute = time.minute;
              //   }
              // },
            ),
          );
        } else {
          // Show loading during the async function finish to process
          return Scaffold();
        }
        }

    );
  }



}
