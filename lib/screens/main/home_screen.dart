import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mobx/mobx.dart';
import '../../components/alarm_item/alarm_item.dart';
import '../../components/bottom_add_button/bottom_add_button.dart';
import '../../components/default_container/default_container.dart';
import '../../constants/theme_data.dart';
import '../../main.dart';
import '../edit_alarm/components/edit_alarm_time.dart';
import '../../services/alarm_list_manager.dart';
import '../../services/alarm_scheduler.dart';
import '../../stores/alarm_list/alarm_list.dart';
import '../../stores/observable_alarm/observable_alarm.dart';

bool isPermission = false;
// final String permission = "false";

class HomeScreen extends StatefulWidget {
   final AlarmList alarms;

  HomeScreen({Key? key, required this.alarms}) : super(key: key);


  @override
  State<StatefulWidget> createState() {return HomeScreenState();}
}

class HomeScreenState extends State<HomeScreen> {

  bool switchValue = false;
  bool visibleButton = true;
  bool _isVisible = true;


  void hidePermission() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  // getSharedPreferences() async {
  //   final SharedPreferences prefs = await SharedPreferences.getInstance();
  //
  //   isPermission = prefs.getBool(permission) ?? false;
  // }

  checkOverlays() async {
    if (!await FlutterForegroundTask.canDrawOverlays) {

    }
    else{
      hidePermission();
      isPermission = true;
      // prefs.setBool(permission, true);
      print('SYSTEM_ALERT_WINDOW permission true!');
    }
  }

  @override
  void initState() {
    super.initState();

    try {
      checkOverlays();
    }
    catch(a) {}

    // Timer(Duration(seconds: 2), () async {
    //   print('main: Jestem tu initState');
    //   await askPermission();
    // });
  }

  Future askPermission() async {

    // "android.permission.SYSTEM_ALERT_WINDOW" permission must be granted for
    // onNotificationPressed function to be called.
    //
    // When the notification is pressed while permission is denied,
    // the onNotificationPressed function is not called and the app opens.
    //
    // If you do not use the onNotificationPressed or launchApp function,
    // you do not need to write this code.
    if (!await FlutterForegroundTask.canDrawOverlays) {
      final isGranted = await FlutterForegroundTask.openSystemAlertWindowSettings();
      if (!isGranted) {
        print('SYSTEM_ALERT_WINDOW permission denied!');
        isPermission = false;
        // prefs.setBool(permission, false);
        return false;
      }
      else {
        hidePermission();
        isPermission = true;
        // prefs.setBool(permission, true);
        print('SYSTEM_ALERT_WINDOW permission true!');
      }
    } else {
      hidePermission();
      isPermission = true;
      // prefs.setBool(permission, true);
      print('SYSTEM_ALERT_WINDOW permission true!');
    }
  }


  @override
  Widget build(BuildContext context) {
    final AlarmListManager _manager = AlarmListManager(widget.alarms);

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
                      final alarm = widget.alarms.alarms[index];

                      return Dismissible(
                        key: Key(alarm.id.toString()),
                        child: AlarmItem(alarm: alarm, manager: _manager, alarms: widget.alarms,),
                        onDismissed: (_) {
                          AlarmScheduler().clearAlarm(alarm);
                          widget.alarms.alarms.removeAt(index);
                          visibleButton = true;
                          //Visible = !Visible;

                        },
                      );
                    },
                    itemCount: widget.alarms.alarms.length,
                    separatorBuilder: (context, index) => const Divider(),
                  ),
            ),
          ),
            BottomAddButton(
              onPressed: () {
                TimeOfDay tod = TimeOfDay.fromDateTime(DateTime.now());
                final newAlarm = ObservableAlarm.dayList(
                    widget.alarms.alarms.length,
                    'Alarm',
                    tod.hour,
                    tod.minute,
                    0.9,
                    false,
                    true,
                    List.filled(7, false),
                    ObservableList<String>.of([]),
                    <String>[]);

                widget.alarms.alarms.add(newAlarm);

                //Navigator.push(context, MaterialPageRoute(builder: (context) => EditAlarmTime(alarm: newAlarm, manager: _manager),
                EditAlarmTime(alarm: newAlarm, manager: _manager);

                // EditAlarm(alarm: newAlarm, manager: _manager,),
                visibleButton = false;
                //Visible = !Visible;

              },
            ),
      Visibility(
        visible: _isVisible,
      child: Padding(
        padding: const EdgeInsets.only(top: 300.0),
        child:
          ElevatedButton(
            onPressed: () {

              try {
                askPermission();
              }
              catch(a) {}

            },
            child:
              Text('Please Allow this app to be over other apps!', style: TextStyle(fontSize: 12, color: CustomColors.sdTextPrimaryColor)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(255, 255, 255, 1),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
             ),
          ),
            // style: ElevatedButton.styleFrom(
            //   primary: CustomColors.sdAppWhite,
            //   shape: CircleBorder(),
            //   padding: EdgeInsets.all(50),
            // ),
          ),

        ],
      ),
    );
  }


}

