import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

Future<AudioHandler> initAudioService() async {
  return await AudioService.init(
    builder: () => MyAudioHandler(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'pl.ryanheise.myapp.channel.audio',
      androidNotificationChannelName: 'Audio Service wakeup',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );
}

class MyAudioHandler extends BaseAudioHandler {
  final _player = AudioPlayer();

  static int nextMediaId = 0;
  final _playlist = ConcatenatingAudioSource(children: [
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/1.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Monday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/2.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Tuesday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/3.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Wednesday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/4.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Thursday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/5.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Friday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/6.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Saturday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
    AudioSource.uri(
      Uri.parse("asset:///assets/audios/7.mp3"),
      tag: MediaItem(
        id: '${nextMediaId++}',
        album: "Wake Up Alarm",
        title: "Sunday",
        artUri: Uri.parse(
            "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
      ),
    ),
  ]);
// int _addedCount = 0;

  MyAudioHandler() {
    _loadPlaylist();
    _notifyAudioHandlerAboutPlaybackEvents();
    _listenForDurationChanges();
    _listenForCurrentSongIndexChanges();
    _listenForSequenceStateChanges();
  }

  Future<void> _loadPlaylist() async {
    try {
      await _player.setAudioSource(_playlist);
    } catch (e) {
      print("Error: $e");
    }
  }

  void _notifyAudioHandlerAboutPlaybackEvents() {
    _player.playbackEventStream.listen((PlaybackEvent event) {
      final playing = _player.playing;
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
        },
        androidCompactActionIndices: const [0, 1, 3],
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[_player.processingState]!,
        repeatMode: const {
          LoopMode.off: AudioServiceRepeatMode.none,
          LoopMode.one: AudioServiceRepeatMode.one,
          LoopMode.all: AudioServiceRepeatMode.all,
        }[_player.loopMode]!,
        shuffleMode: (_player.shuffleModeEnabled)
            ? AudioServiceShuffleMode.all
            : AudioServiceShuffleMode.none,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: event.currentIndex,
      ));
    });
  }

  void _listenForDurationChanges() {
    _player.durationStream.listen((duration) {
      var index = _player.currentIndex;
      final newQueue = queue.value;
      if (index == null || newQueue.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      final oldMediaItem = newQueue[index];
      final newMediaItem = oldMediaItem.copyWith(duration: duration);
      newQueue[index] = newMediaItem;
      queue.add(newQueue);
      mediaItem.add(newMediaItem);
    });
  }

  void _listenForCurrentSongIndexChanges() {
    _player.currentIndexStream.listen((index) {
      final playlist = queue.value;
      if (index == null || playlist.isEmpty) return;
      if (_player.shuffleModeEnabled) {
        index = _player.shuffleIndices![index];
      }
      mediaItem.add(playlist[index]);
    });
  }

  void _listenForSequenceStateChanges() {
    _player.sequenceStateStream.listen((SequenceState? sequenceState) {
      final sequence = sequenceState?.effectiveSequence;
      if (sequence == null || sequence.isEmpty) return;
      final items = sequence.map((source) => source.tag as MediaItem);
      queue.add(items.toList());
    });
  }

  @override
  Future<void> addQueueItems(List<MediaItem> mediaItems) async {
    // manage Just Audio
    final audioSource = mediaItems.map(_createAudioSource);
    _playlist.addAll(audioSource.toList());

    // notify system
    final newQueue = queue.value..addAll(mediaItems);
    queue.add(newQueue);
  }

  @override
  Future<void> addQueueItem(MediaItem mediaItem) async {
    // manage Just Audio
    final audioSource = _createAudioSource(mediaItem);
    _playlist.add(audioSource);

    // notify system
    final newQueue = queue.value..add(mediaItem);
    queue.add(newQueue);
  }

  UriAudioSource _createAudioSource(MediaItem mediaItem) {
    return AudioSource.uri(
      Uri.parse(mediaItem.extras!['url']),
      tag: mediaItem,
    );
  }

  @override
  Future<void> removeQueueItemAt(int index) async {
    // manage Just Audio
    _playlist.removeAt(index);

    // notify system
    final newQueue = queue.value..removeAt(index);
    queue.add(newQueue);
  }

  @override
  Future<void> play() async {
    // final session = await AudioSession.instance;
    // await session.configure(const AudioSessionConfiguration.music());
    // Listen to errors during playback.
    // _playlist.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
    //   print('main_screen: A stream error occurred: $e');});

    try {
      int x = DateTime.now().weekday - 1; //song of a week
      await _player.setAudioSource(_playlist,
          initialIndex: x, initialPosition: Duration.zero);
      await _player.setLoopMode(LoopMode.one);
      await _player.setShuffleModeEnabled(false);

      await _player.play();
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("audio_handler: Error loading playlist: $e");
      print('audio_handler: $stackTrace');
    }

    // _player.play();
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> seek(Duration position) => _player.seek(position);

  @override
  Future<void> skipToQueueItem(int index) async {
    if (index < 0 || index >= queue.value.length) return;
    if (_player.shuffleModeEnabled) {
      index = _player.shuffleIndices![index];
    }
    _player.seek(Duration.zero, index: index);
  }

  @override
  Future<void> skipToNext() => _player.seekToNext();

  @override
  Future<void> skipToPrevious() => _player.seekToPrevious();

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    switch (repeatMode) {
      case AudioServiceRepeatMode.none:
        _player.setLoopMode(LoopMode.off);
        break;
      case AudioServiceRepeatMode.one:
        _player.setLoopMode(LoopMode.one);
        break;
      case AudioServiceRepeatMode.group:
      case AudioServiceRepeatMode.all:
        _player.setLoopMode(LoopMode.all);
        break;
    }
  }

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    if (shuffleMode == AudioServiceShuffleMode.none) {
      _player.setShuffleModeEnabled(false);
    } else {
      await _player.shuffle();
      _player.setShuffleModeEnabled(true);
    }
  }

  @override
  Future customAction(String name, [Map<String, dynamic>? extras]) async {
    if (name == 'dispose') {
      await _player.dispose();
      super.stop();
    }
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    return super.stop();
  }
}









//OLD
//   Future<void> playMusic(ObservableAlarm alarm) async {
//
//     // if (alarm.musicPaths!.length == 0) {
//     //   await playDeviceDefaultTone(alarm);
//     // }
//     // else {
//
//
//
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.music());
//     // Listen to errors during playback.
//     _currentPlayer.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
//       print('main_screen: A stream error occurred: $e');});
//
//     try {
//       int x = DateTime.now().weekday - 1; //song of a week
//       await _currentPlayer.setAudioSource(playlist, initialIndex: x, initialPosition: Duration.zero);
//       await _currentPlayer.setLoopMode(LoopMode.one);
//       await _currentPlayer.setShuffleModeEnabled(false);
//
//       await _currentPlayer.play();
//
//     } catch (e, stackTrace) {
//       // Catch load errors: 404, invalid url ...
//       print("main_screen: Error loading playlist: $e");
//       print('main_screen: $stackTrace');
//     }
//
//
//       // init();
//
//       // try {
//       //   play();
//       // } catch (e, stackTrace) {
//       //   print('alarm_screen: $stackTrace');
//       // }
//
//
//       // Get random path from list of alarm sounds
//       // final path = await getRandomPath(alarm);
//       //
//       // final playerStarted = await playSingle(alarm, path);
//
//       // print("vibration can start: $playerStarted");
//       // if (playerStarted) {
//         print("vibration started");
//         // Start vibration
//         //await Vibration.vibrate(pattern: [500, 1000, 500, 2000], repeat: 1, intensities: [1, 255]);
//       // }
//     // }
//   }
//
//
//
//
//
//   void init() async {
//     final session = await AudioSession.instance;
//     await session.configure(const AudioSessionConfiguration.music());
//     // Listen to errors during playback.
//     _currentPlayer.playbackEventStream.listen((event) {}, onError: (Object e, StackTrace stackTrace) {
//       print('main_screen: A stream error occurred: $e');});
//
//     try {
//       int x = DateTime.now().weekday - 1; //song of a week
//       await _currentPlayer.setAudioSource(playlist, initialIndex: x, initialPosition: Duration.zero);
//       await _currentPlayer.setLoopMode(LoopMode.one);
//       await _currentPlayer.setShuffleModeEnabled(false);
//
//       await _currentPlayer.play();
//
//     } catch (e, stackTrace) {
//       // Catch load errors: 404, invalid url ...
//       print("main_screen: Error loading playlist: $e");
//       print('main_screen: $stackTrace');
//     }
//   }
//
//
//
//   Stream<PositionData> get _positionDataStream =>
//       Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
//           _currentPlayer.positionStream,
//           _currentPlayer.bufferedPositionStream,
//           _currentPlayer.durationStream,
//               (position, bufferedPosition, duration) => PositionData(
//               position, bufferedPosition, duration ?? Duration.zero));
//
//
//
//   void play() async {
//     await _currentPlayer.play();
//   }
//
//   // Request audio pause
//   void pause() async {
//       await _currentPlayer.pause();
//   }
//
//   @override
//   void dispose() async {
//       await _currentPlayer.dispose();
//     print('main_screen: Dispose Audio Player');
//     // super.dispose();
//   }
//
//
//
//
//
//   /// This function initializes the music player with a sound path and
//   /// starts playing based on the given alarm configuration.
//   /// @param alarm - An ObservableAlarm object holding ringtone description
//   /// @param path - File path of sound to be played. This can be a local path or remote url.
//   Future<bool> playSingle(ObservableAlarm alarm, String path) async {
//
//     // Prevent duplicate sounds
//     if (_currentPlayer.playing) await _currentPlayer.stop();
//     _currentPlayer.setLoopMode(LoopMode.one);
//     // Initialize audio source
//     if (path.startsWith("http")) {
//       //Online file
//       AudioSource? source;
//       final pathExt = path.split(".").last;
//       if (livestreamFormats.contains(pathExt)) {
//         // Stream source
//         if (pathExt == "mdp") {
//           // DASH stream source
//           source = DashAudioSource(Uri.parse(path));
//         } else if (pathExt == "m3u8") {
//           // HLS stream source
//           source = HlsAudioSource(Uri.parse(path));
//         }
//       } else if (audioFormats.contains(pathExt)) {
//         // Media file like .mp3 source
//         source = ProgressiveAudioSource(Uri.parse(path));
//       } else
//         return false;
//
//       if (source != null) {
//         playingSoundPath.value =
//             path; // Notifies UI isolate path is ready to play
//         try {
//           await _currentPlayer.setAudioSource(source);
//         } on PlayerException catch (e) {
//           // iOS/macOS: maps to NSError.code
//           // Android: maps to ExoPlayerException.type
//           // Web: maps to MediaError.code
//           print("Error code: ${e.code}");
//           // iOS/macOS: maps to NSError.localizedDescription
//           // Android: maps to ExoPlaybackException.getMessage()
//           // Web: a generic message
//           print("Error message: ${e.message}");
//           await playDeviceDefaultTone(alarm);
//           return true;
//         }
//         await _currentPlayer.play();
//       }
//     } else {
//       print("progressiveVolume aaa: ${alarm.progressiveVolume!}");
//       playingSoundPath.value =
//           path; // Notifies UI isolate path is ready to play
//       final absPath = File(path).absolute.path; // Initialize absolute path
//       await _currentPlayer.setFilePath(absPath);
//       await _currentPlayer.play();
//     }
//
//     print("media_handler: progressiveVolume: ${alarm.progressiveVolume!}");
//     // Initialize player volume
//     if (alarm.progressiveVolume!)
//       await increaseVolumeProgressively(alarm.volume!);
//     else
//       await _currentPlayer.setVolume(alarm.volume!);
//
//     return true;
//   }
//
//   /// This function stops the music player
//   Future<void> stopMusic() async {
//     // Notifies UI isolate that nothing is currently playing
//     playingSoundPath.value = "";
//     // Pause the music instead of stopping... Well i dunno whats up but the
//     // developer of the player recommends it.
//     if (_currentPlayer.playing) await _currentPlayer.pause();
//     // Cancel progressive volume timer if active
//     if (volumeTimer != null && volumeTimer!.isActive) volumeTimer!.cancel();
//     // Stop default ringtone player if active
//     await FlutterRingtonePlayer.stop();
//     //Stop ongoing vibration.
//     await Vibration.cancel();
//   }
//
//   /// This function increases the device volume progressively from
//   /// low to highest pitch.
//   /// @param volume - The initial volume
//   Future<void> increaseVolumeProgressively(double volume) async {
//     print("media_handler: volume aaa: $volume");
//     volumeTimer = Timer.periodic(Duration(seconds: 2), (timer) async {
//       volume += 0.1;
//       print("media_handler: volume: $volume");
//       if (volume == 1) {
//         // Max volume reached
//         timer.cancel();
//       } else {
//            print("media_handler: volume: $volume");
//         // Increase the volume
//         await _currentPlayer.setVolume(volume);
//       }
//     });
//   }
// }




// static int nextMediaId = 0;
// final _playlist = ConcatenatingAudioSource(children: [
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/1.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Monday",
//       artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/2.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Tuesday",
//       artUri: Uri.parse("https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/3.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Wednesday",
//       artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/4.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Thursday",
//       artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/5.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Friday",
//       artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/6.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Saturday",
//       artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
//   AudioSource.uri(
//     Uri.parse("asset:///assets/audios/7.mp3"),
//     tag: MediaItem(
//       id: '${nextMediaId++}',
//       album: "Wake Up Alarm",
//       title: "Sunday",
//       artUri: Uri.parse( "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg"),
//     ),
//   ),
// ]);
// int _addedCount = 0;