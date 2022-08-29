import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wakeup/stores/observable_alarm/observable_alarm.dart';
import 'package:wakeup/constants/global.dart';
import 'package:vibration/vibration.dart';

import '../common.dart';
import '../main.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';

class MediaHandler {
  late AudioPlayer _currentPlayer;
  Timer? volumeTimer;

  MediaHandler() {
    _currentPlayer = AudioPlayer();
  }

  /// This function returns a random path from a list of alarm sound paths
  /// @param alarm - An ObservableAlarm object with a list of sound paths
  /// @returns String - a random path
  Future<String> getRandomPath(ObservableAlarm alarm) async {
    final entry = Random().nextInt(alarm.musicPaths!.length);
    return alarm.musicPaths![entry];
  }

  /// Play device default alarm tone
  Future<void> playDeviceDefaultTone(ObservableAlarm alarm) async {

    await FlutterRingtonePlayer.play(
      android: AndroidSounds.alarm,
      ios: IosSounds.glass,
      looping: true, // Android only - API >= 28
      volume: alarm.volume!, // Android only - API >= 28
      asAlarm: false, // Android only - all APIs
    );
  }

  /// This function initializes and play the sound player using a list of alarm sounds
  /// or it plays device default tone when no sound is specified in alarm.
  /// @param alarm - An ObservableAlarm object
  Future<void> playMusic(ObservableAlarm alarm) async {

    if (alarm.musicPaths!.length == 0) {
      await playDeviceDefaultTone(alarm);
    }
    else {

      // init();
      //
      // try {
      //   // play();
      // } catch (e, stackTrace) {
      //   print('alarm_screen: $stackTrace');
      // }


      // Get random path from list of alarm sounds
      final path = await getRandomPath(alarm);
      final playerStarted = await playSingle(alarm, path);

      print("vibration can start: $playerStarted");
      if (playerStarted) {
        print("vibration started");
        // Start vibration
        await Vibration.vibrate(
            pattern: [500, 1000, 500, 2000], repeat: 1, intensities: [1, 255]);
      }
    }
  }





  void init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    _currentPlayer.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
      print('main_screen: A stream error occurred: $e');});

    try {
      int x = DateTime.now().weekday - 1; //song of a week
      await _currentPlayer.setAudioSource(playlist, initialIndex: x, initialPosition: Duration.zero);
      await _currentPlayer.setLoopMode(LoopMode.one);
      await _currentPlayer.setShuffleModeEnabled(false);

      //await play();
      // await _currentPlayer.play();

    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("main_screen: Error loading playlist: $e");
      print('main_screen: $stackTrace');
    }
  }



  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _currentPlayer.positionStream,
          _currentPlayer.bufferedPositionStream,
          _currentPlayer.durationStream,
              (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));



  void play() async {
    await _currentPlayer.play();
  }

  // Request audio pause
  void pause() async {
      await _currentPlayer.pause();
  }

  @override
  void dispose() async {
      await _currentPlayer.dispose();
    print('main_screen: Dispose Audio Player');
    // super.dispose();
  }

  //Media Player playlist
  static int nextMediaId = 0;
  // late AudioPlayer player;
  final playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/1.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Monday",
        artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/2.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Tuesday",
        artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/3.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Wednesday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/4.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Thursday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/5.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Friday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/6.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Saturday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/7.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Sunday",
        artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
  ]);
  int _addedCount = 0;


  /// This function initializes the music player with a sound path and
  /// starts playing based on the given alarm configuration.
  /// @param alarm - An ObservableAlarm object holding ringtone description
  /// @param path - File path of sound to be played. This can be a local path or remote url.
  Future<bool> playSingle(ObservableAlarm alarm, String path) async {

    // Prevent duplicate sounds
    if (_currentPlayer.playing) await _currentPlayer.stop();
    _currentPlayer.setLoopMode(LoopMode.one);
    // Initialize audio source
    if (path.startsWith("http")) {
      //Online file
      AudioSource? source;
      final pathExt = path.split(".").last;
      if (livestreamFormats.contains(pathExt)) {
        // Stream source
        if (pathExt == "mdp") {
          // DASH stream source
          source = DashAudioSource(Uri.parse(path));
        } else if (pathExt == "m3u8") {
          // HLS stream source
          source = HlsAudioSource(Uri.parse(path));
        }
      } else if (audioFormats.contains(pathExt)) {
        // Media file like .mp3 source
        source = ProgressiveAudioSource(Uri.parse(path));
      } else
        return false;

      if (source != null) {
        playingSoundPath.value =
            path; // Notifies UI isolate path is ready to play
        try {
          await _currentPlayer.setAudioSource(source);
        } on PlayerException catch (e) {
          // iOS/macOS: maps to NSError.code
          // Android: maps to ExoPlayerException.type
          // Web: maps to MediaError.code
          print("Error code: ${e.code}");
          // iOS/macOS: maps to NSError.localizedDescription
          // Android: maps to ExoPlaybackException.getMessage()
          // Web: a generic message
          print("Error message: ${e.message}");
          await playDeviceDefaultTone(alarm);
          return true;
        }
        await _currentPlayer.play();
      }
    } else {
      print("progressiveVolume aaa: ${alarm.progressiveVolume!}");
      playingSoundPath.value =
          path; // Notifies UI isolate path is ready to play
      final absPath = File(path).absolute.path; // Initialize absolute path
      await _currentPlayer.setFilePath(absPath);
      await _currentPlayer.play();
    }

    print("media_handler: progressiveVolume: ${alarm.progressiveVolume!}");
    // Initialize player volume
    if (alarm.progressiveVolume!)
      await increaseVolumeProgressively(alarm.volume!);
    else
      await _currentPlayer.setVolume(alarm.volume!);

    return true;
  }

  /// This function stops the music player
  Future<void> stopMusic() async {
    // Notifies UI isolate that nothing is currently playing
    playingSoundPath.value = "";
    // Pause the music instead of stopping... Well i dunno whats up but the
    // developer of the player recommends it.
    if (_currentPlayer.playing) await _currentPlayer.pause();
    // Cancel progressive volume timer if active
    if (volumeTimer != null && volumeTimer!.isActive) volumeTimer!.cancel();
    // Stop default ringtone player if active
    await FlutterRingtonePlayer.stop();
    //Stop ongoing vibration.
    await Vibration.cancel();
  }

  /// This function increases the device volume progressively from
  /// low to highest pitch.
  /// @param volume - The initial volume
  Future<void> increaseVolumeProgressively(double volume) async {
    print("media_handler: volume aaa: $volume");
    volumeTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
      volume += 0.1;
      print("media_handler: volume: $volume");
      if (volume == 1) {
        // Max volume reached
        timer.cancel();
      } else {
           print("media_handler: volume: $volume");
        // Increase the volume
        await _currentPlayer.setVolume(volume);
      }
    });
  }
}
