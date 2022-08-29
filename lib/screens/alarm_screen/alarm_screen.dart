import 'package:wakeup/constants/theme_data.dart';
import 'package:wakeup/services/alarm_scheduler.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:wakeup/stores/alarm_status/alarm_status.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakelock/wakelock.dart';

import '../../main.dart';
import '../../quiz/start_quiz.dart';
import '../../services/media_handler.dart';


class AlarmScreen extends StatelessWidget {
  final ObservableAlarm? alarm;
  final MediaHandler mediaHandler;
  const AlarmScreen({Key? key, required this.alarm, required this.mediaHandler}) : super(key: key);



  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual, overlays: []); // fullscreen
    final now = DateTime.now();
    final format = DateFormat('Hm');
    final snoozeTimes = [5, 10, 15, 20];
    bool playing = true;

    return Scaffold(
      body: Container(
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
                          color: CustomColors.sdSecondaryColorYellow,
                          style: BorderStyle.solid,
                          width: 50))),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.alarm,
                    color: CustomColors.sdAppWhite,
                    size: 32,
                  ),
                  Text(
                    format.format(now),
                    style: TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w900,
                        color:  CustomColors.sdAppWhite),
                  ),
                  Container(
                    width: 250,
                    child: Text(
                      alarm!.name!,
                      maxLines: 3,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: CustomColors.sdAppWhite, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {

              Wakelock.disable();
              AlarmStatus().isAlarm = false;
              AlarmStatus().alarmId = -1;

              AlarmStatus status = AlarmStatus();
              print('alarm_screen: status.isAlarm ${status.isAlarm}');
              print('alarm_screen: list.alarms.length ${list.alarms.length}');
              //Navigator.of(context).pop();
              Navigator.push(context, MaterialPageRoute(builder: (context) => StartQuiz(mediaHandler: mediaHandler, alarm: alarm)),);

            },
            child:
            Text('Start Today', style: TextStyle(fontSize: 25, color: CustomColors.sdTextPrimaryColor)),
            style: ElevatedButton.styleFrom(
              primary: CustomColors.sdAppWhite,
              shape: CircleBorder(),
              padding: EdgeInsets.all(70),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (playing) {
                mediaHandler.stopMusic();
                playing = false;
              } else {
                mediaHandler.playMusic(alarm!);
                playing = true;
              }
            },
            child: Icon(Icons.play_arrow, size: 30, color: Colors.black),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.all(EdgeInsets.all(16)),
              backgroundColor: MaterialStateProperty.all(Colors.white), // <-- Button color
              overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
                if (states.contains(MaterialState.pressed)) return CustomColors.sdSecondaryColorYellow; // <-- Splash color
              }),
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
          // RoundedButton("Stop Music", fontSize: 45, onTap: () async {
          //   mediaHandler.stopMusic();
          //   //await dismissCurrentAlarm();
          // }),
        ],
      ),
    ),
    );
  }



  Future<void> dismissCurrentAlarm() async {
    //mediaHandler.stopMusic();
    Wakelock.disable();

    AlarmStatus().isAlarm = false;
    AlarmStatus().alarmId = -1;
    SystemNavigator.pop();
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



  // @override
  // void initState() {
  //   super.initState();
  //
  //   SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(statusBarColor: Colors.black,));
  //
  //
  // }








}




//
// class MediaState {
//   final MediaItem? mediaItem;
//   final Duration position;
//
//   MediaState(this.mediaItem, this.position);
// }
//
//
//
// /// An [AudioHandler] for playing a single item.
// class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
//   static final _item = MediaItem(
//     id: 'https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3',
//     album: "Science Friday",
//     title: "A Salute To Head-Scratching Science",
//     artist: "Science Friday and WNYC Studios",
//     duration: const Duration(milliseconds: 5739820),
//     artUri: Uri.parse(
//         'https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg'),
//   );
//
//   final _player = AudioPlayer();
//
//   /// Initialise our audio handler.
//   AudioPlayerHandler() {
//     // So that our clients (the Flutter UI and the system notification) know
//     // what state to display, here we set up our audio handler to broadcast all
//     // playback state changes as they happen via playbackState...
//     _player.playbackEventStream.map(_transformEvent).pipe(playbackState);
//     // ... and also the current media item via mediaItem.
//     mediaItem.add(_item);
//
//     // Load the player.
//     _player.setAudioSource(AudioSource.uri(Uri.parse(_item.id)));
//   }
//
//   // In this simple example, we handle only 4 actions: play, pause, seek and
//   // stop. Any button press from the Flutter UI, notification, lock screen or
//   // headset will be routed through to these 4 methods so that you can handle
//   // your audio playback logic in one place.
//
//   @override
//   Future<void> play() => _player.play();
//
//   @override
//   Future<void> pause() => _player.pause();
//
//   @override
//   Future<void> seek(Duration position) => _player.seek(position);
//
//   @override
//   Future<void> stop() => _player.stop();
//
//   /// Transform a just_audio event into an audio_service state.
//   ///
//   /// This method is used from the constructor. Every event received from the
//   /// just_audio player will be transformed into an audio_service state so that
//   /// it can be broadcast to audio_service clients.
//   PlaybackState _transformEvent(PlaybackEvent event) {
//     return PlaybackState(
//       controls: [
//         MediaControl.rewind,
//         if (_player.playing) MediaControl.pause else MediaControl.play,
//         MediaControl.stop,
//         MediaControl.fastForward,
//       ],
//       systemActions: const {
//         MediaAction.seek,
//         MediaAction.seekForward,
//         MediaAction.seekBackward,
//       },
//       androidCompactActionIndices: const [0, 1, 3],
//       processingState: const {
//         ProcessingState.idle: AudioProcessingState.idle,
//         ProcessingState.loading: AudioProcessingState.loading,
//         ProcessingState.buffering: AudioProcessingState.buffering,
//         ProcessingState.ready: AudioProcessingState.ready,
//         ProcessingState.completed: AudioProcessingState.completed,
//       }[_player.processingState]!,
//       playing: _player.playing,
//       updatePosition: _player.position,
//       bufferedPosition: _player.bufferedPosition,
//       speed: _player.speed,
//       queueIndex: event.currentIndex,
//     );
//   }
// }