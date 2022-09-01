import 'package:mobx/mobx.dart';

part 'alarm_status.g.dart';

class AlarmStatus2 extends _AlarmStatus2 with _$AlarmStatus2 {
  static final AlarmStatus2 _instance = AlarmStatus2._();

  factory AlarmStatus2() {
    return _instance;
  }

  AlarmStatus2._();
}

abstract class _AlarmStatus2 with Store {
  @observable
  bool isAlarm = false;

  int? alarmId;
}
