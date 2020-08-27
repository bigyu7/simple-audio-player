
import 'package:simple_audio_player/model/config.dart';

abstract class ConfigStorageService {
  Future<Config> loadConfig();
  Future<void> saveConfig(Config config);

  Future<String> newPlayListFilePath();
}