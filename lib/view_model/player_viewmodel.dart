import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:audioplayer/audioplayer.dart';

enum PlayerState { stopped, playing, paused }

class PlayerViewModel extends ChangeNotifier {
  AudioPlayer _audioPlayer;
  PlayerState _playerState;
  Duration _duration;
  Duration _position;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  bool _isMuted = false;
  String _localFilePath='';

  Function _callback;

  PlayerViewModel() {
    _playerState = PlayerState.stopped;
    _isMuted = false;
    _localFilePath='';
    initAudioPlayer();
  }

  String get traceFilePath => _localFilePath==null?'':_localFilePath;
  String get traceFileName => (_localFilePath==null||_localFilePath.isEmpty)?'':_localFilePath.split('/').last;

  get canPlay => _localFilePath!=null && _localFilePath.isNotEmpty;
  get isPlaying => _playerState == PlayerState.playing;
  get isPaused => _playerState == PlayerState.paused;
  get isMuted => _isMuted;

  String _formatDuration(Duration d) {
    int seconds = d.inSeconds%60;
    int minutes = (d.inSeconds/60).floor();
    int hours = (minutes/60).floor();
    return hours>0?'$hours ${minutes%60}:$seconds':'${minutes%60}:$seconds';
  }

  get durationText => _duration != null ? _formatDuration(_duration) : '';
  get positionText => _position != null ? _position.toString().split('.').first : '';

  get duration => _duration;
  get position => _position;

  void initAudioPlayer() {
    _audioPlayer = AudioPlayer();
    _positionSubscription = _audioPlayer.onAudioPositionChanged.listen((p) {
        _position = p;
        notifyListeners();
      }
    );
    _audioPlayerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((s) {
          if (s == AudioPlayerState.PLAYING) {
            _duration = _audioPlayer.duration;
            notifyListeners();
          } else if (s == AudioPlayerState.STOPPED) {
            _position = _duration;
            _playerState = PlayerState.stopped;
            notifyListeners();
            _onComplete();
          }
        }, onError: (msg) {
            _playerState = PlayerState.stopped;
            _duration = Duration(seconds: 0);
            _position = Duration(seconds: 0);
            notifyListeners();
        }
    );
  }

  void _onComplete() {
    print('** player _onComplete() **');
    if(_callback!=null) {
      print('** player _onComplete()  callback **');
      _callback();
    }
  }

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    _audioPlayer.stop();
    super.dispose();
  }

  Future playLocalFile(String filePath, Function callback) async {
    final file = File(filePath);

    //print('playLocalFile() - '+filePath);
    if (await file.exists()) {
        await stop();
        _localFilePath = file.path;
        _callback = callback;
        play();
    } else {
      _localFilePath = '';
      stop();
    }
  }

  Future play() async {
    if(canPlay) {
      //print('play() - '+_localFilePath);
      await _audioPlayer.play(_localFilePath, isLocal: true);
      _playerState = PlayerState.playing;
      notifyListeners();
    }
  }

  Future pause() async {
    //print('pause() - '+_localFilePath);
    await _audioPlayer.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future stop() async {
    //print('stop() - '+_localFilePath);
    _callback = null;
    await _audioPlayer.stop();
    _playerState = PlayerState.stopped;
    _position = Duration(seconds: 0);
    notifyListeners();
  }

  Future seek(double seconds) async {
    if(_playerState==PlayerState.stopped) return;
    await _audioPlayer.seek(seconds);
    _position = Duration(seconds: seconds.floor());
    notifyListeners();
  }

  Future mute(bool muted) async {
    await _audioPlayer.mute(muted);
    _isMuted = muted;
    notifyListeners();
  }

}