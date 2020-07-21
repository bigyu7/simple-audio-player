
import 'package:simply_audio_player/model/playlist.dart';

abstract class PlaylistStorageService {
  Future<PlayList> loadPlayList(String filepath);
  Future<void> savePlayList(PlayList playList);
  Future<void> renamePlayList(PlayList playList, String newName);
  Future<List<String>> getPlayListsFilePath();
}