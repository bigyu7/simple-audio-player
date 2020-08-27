
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_audio_player/model/config.dart';

import 'config_storage_service.dart';

class ConfigStorageServiceImpl implements ConfigStorageService {
  static const sharedPrefConfigKey = 'config';
  static const defaultPlayListName = '默认播放列表';

  Future<void> _save(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }

  Future<String> _read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return Future<String>.value(prefs.getString(key) ?? '');
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<String> get _defaultPlayListFilePath async {
    final path = await _localPath;
    return '$path/$defaultPlayListName.m3u';
  }

  @override
  Future<Config> loadConfig() async {
    String jsonString = await _read(sharedPrefConfigKey);
    print('loadConfig() raw string: '+jsonString);
    Config config;
    if (jsonString == '') {
      config = Config();
      config.setCurrentPlayList(await _defaultPlayListFilePath);
    } else {
      final codeList = jsonDecode(jsonString);
      config = Config.fromJson(codeList);
      if(config.isEmptyPlayListFilePath) {
        config.setCurrentPlayList(await _defaultPlayListFilePath);
      }
    }
    print('loadConfig() config: '+config.toString());
    return config;
  }

  @override
  Future<void> saveConfig(Config config) async {
    String jsonString = jsonEncode(config.toJson());
    print('saveConfig(): '+jsonString);
    return _save(sharedPrefConfigKey, jsonString);
  }

  @override
  Future<String> newPlayListFilePath() async {
    final path = await _localPath;
    String filePath = '$path/$defaultPlayListName.m3u';
    int i=0;
    while (await File(filePath).exists()) {
      i++;
      filePath = '$path/$defaultPlayListName$i.m3u';
    }
    return filePath;
  }
  
}