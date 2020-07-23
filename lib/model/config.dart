
import 'dart:convert';

import 'package:simply_audio_player/model/play_mode.dart';

class Config {
  static const int recentCount = 10;    // max recent playlist count
  String _playListFilePath;
  PlayMode playMode;
  int currentTraceIndex;
  final List<String> _recentPlayLists=[];

  bool get isEmptyPlayListFilePath => (_playListFilePath==null||_playListFilePath.isEmpty);
  String get playListFilePath => _playListFilePath;

  bool get hasRecentPlayList => _recentPlayLists.isNotEmpty;
  List<String> get recentPlayLists => _recentPlayLists;

  Config() {
    _playListFilePath='';
    playMode=PlayMode.in_order;
    currentTraceIndex = -1;
  }

  Config.fromJson(Map<String, dynamic> json) {
    _playListFilePath = json['playListFilePath'];
    playMode = ( enumFromString<PlayMode>(PlayMode.values, json['playMode']) ?? PlayMode.in_order);
    currentTraceIndex = json['currentTraceIndex']??-1;
    var list = jsonDecode(json['recentPlayLists']??'[]');
    assert(list is List);
    (list as List).forEach((e) => _recentPlayLists.add(e.toString()));
  }


  Map<String, dynamic> toJson() =>
      {
        'playListFilePath': _playListFilePath,
        'playMode': enumToString(playMode),
        'currentTraceIndex': currentTraceIndex,
        'recentPlayLists': jsonEncode(_recentPlayLists),
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  void _addToRecent(String filePath) {
    _recentPlayLists.removeWhere((element) => filePath==element);
    _recentPlayLists.add(filePath);

    if(_recentPlayLists.length>recentCount) _recentPlayLists.removeRange(0, _recentPlayLists.length-recentCount);
  }

  // 设置当前播放列表，如果和当前一样，就返回false
  bool setCurrentPlayList(String filePath) {
    if(_playListFilePath==filePath) return false;

    // 新的当前，如果在最近列表中，就清除
    _recentPlayLists.removeWhere((element) => filePath==element);

    // 将当前加到最近列表
    if(!isEmptyPlayListFilePath) _addToRecent(_playListFilePath);

    // 设为新的当前
    _playListFilePath = filePath;
    return true;
  }

  void renameCerrentPlayList(String filePath) {
    _playListFilePath = filePath;
  }

}
