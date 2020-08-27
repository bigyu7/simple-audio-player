
import 'package:path_provider/path_provider.dart';
import 'package:simple_audio_player/model/config.dart';

import 'config_storage_service.dart';

class MockConfigStorageService implements ConfigStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  @override
  Future<Config> loadConfig() async {
    final path = await _localPath;
    Config config=Config();
    config.setCurrentPlayList('$path/默认播放列表.m3u');
    print('loadConfig(): '+config.toString());
    return config;
  }

  @override
  Future<void> saveConfig(Config config) async {
    print('saveConfig(): '+config.toString());
  }

  @override
  Future<String> newPlayListFilePath() {
    // TODO: implement newPlayListFilePath
    throw UnimplementedError();
  }

}