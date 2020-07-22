
import 'package:path_provider/path_provider.dart';
import 'package:simply_audio_player/model/playlist.dart';
import 'package:simply_audio_player/service/playlist_storege_service.dart';

class MockPlaylistStorageService implements PlaylistStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  String _playListFilePath(String path, String name) => '$path/$name.m3u';

  @override
  Future<PlayList> loadPlayList(String filepath) async {
    String filename = filepath.split('/').last;
    String name = filename.substring(0,filename.lastIndexOf("."));
    print(name);

    PlayList playList=PlayList(filepath, name, []);
    return playList;
  }

  @override
  Future<void> renamePlayList(PlayList playList, String newName) {
    print('renamePlayList(): '+newName);
  }

  @override
  Future<void> savePlayList(PlayList playList) {
    print('savePlayList(): '+playList.toString());
  }

  @override
  Future<List<String>> getPlayListsFilePath() async {
    final path = await _localPath;

    return [_playListFilePath(path,'默认播放列表'),
      _playListFilePath(path,'test1'),
      _playListFilePath(path,'test2'),
    ];
  }

}