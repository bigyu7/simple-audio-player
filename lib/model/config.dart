
import 'dart:convert';

import 'package:simply_audio_player/model/play_mode.dart';

class Config {
  String playListFilePath;
  PlayMode playMode;

  bool get isEmptyPlayListFilePath => (playListFilePath==null||playListFilePath.isEmpty);

  Config() {
    playListFilePath='';
    playMode=PlayMode.in_order;
  }

  Config.fromJson(Map<String, dynamic> json)
      : playListFilePath = json['playListFilePath']
        , playMode = ( enumFromString<PlayMode>(PlayMode.values, json['playMode']) ?? PlayMode.in_order)
  ;

  Map<String, dynamic> toJson() =>
      {
        'playListFilePath': playListFilePath,
        'playMode': enumToString(playMode),
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

}
