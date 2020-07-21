

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simply_audio_player/model/playlist.dart';
import 'package:simply_audio_player/service/playlist_storege_service.dart';

class PlaylistStorageServiceImpl implements PlaylistStorageService {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  String _playListFilePath(String path, String name) => '$path/$name.m3u';

  Future<File> _getplayListFile(String name) async {
    final path = await _localPath;
    return File(_playListFilePath(path,name));
  }

  @override
  Future<List<String>> getPlayListsFilePath() async {
    final path = await _localPath;

    return [_playListFilePath(path,'默认播放列表'),
      _playListFilePath(path,'test1'),
      _playListFilePath(path,'test2'),
    ];
  }

  @override
  Future<PlayList> loadPlayList(String filePath) async {
    String filename = filePath.split('/').last;
    String name = filename.substring(0,filename.lastIndexOf("."));
    print(name);

    PlayList playList=PlayList(name, []);

    try {
      final File file = File(filePath);
      // 文件不存在就返回
      if (!(await file.exists())) {
        return playList;
      };

      // LineSplitter Dart语言封装的换行符，此处将文本按行分割
      Stream lines = file.openRead().transform(utf8.decoder).transform(const LineSplitter());
      await for (var line in lines) {
        print(line);
        playList.add(PlayListItem(line, line.split('/').last, null));
      }

      return playList;
    } catch (e) {
      // If encountering an error, return 0
      print('PlaylistStorageServiceImpl.loadPlayList() - Exception: ' + e.toString());
      return playList;
    }
  }

  @override
  Future<void> renamePlayList(PlayList playList, String newName) async {
    final path = await _localPath;
    final File file = File(_playListFilePath(path,playList.name));
    await file.rename(_playListFilePath(path,newName));
  }

  @override
  Future<void> savePlayList(PlayList playList) async {
    final File file = await _getplayListFile(playList.name);
    IOSink isk = file.openWrite(mode: FileMode.write);

    // 多次写入
    for(var i in playList.traces) {
      isk.writeln(i.file);
    }

    await isk.close();
  }

}