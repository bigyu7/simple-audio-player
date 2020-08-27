

import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:simple_audio_player/model/playlist.dart';
import 'package:simple_audio_player/service/playlist_storege_service.dart';

class PlaylistStorageServiceImpl implements PlaylistStorageService {
//
//  Future<String> get _localPath async {
//    final directory = await getApplicationDocumentsDirectory();
//
//    return directory.path;
//  }
//
//  String _playListFilePath(String path, String name) => '$path/$name.m3u';
//
//  Future<File> _getplayListFile(String name) async {
//    final path = await _localPath;
//    return File(_playListFilePath(path,name));
//  }

  @override
  Future<List<String>> getPlayListsFilePath() async {
    return [];
  }

  @override
  Future<PlayList> loadPlayList(String filePath) async {
    String filename = filePath.split('/').last;
    String name = filename.substring(0,filename.lastIndexOf("."));

    PlayList playList=PlayList(filePath, name, []);

    try {
      final File file = File(filePath);
      // 文件不存在就返回
      if (!(await file.exists())) {
        print('PlaylistStorageServiceImpl.loadPlayList() - file not exist! filePath: '+filePath);
        return playList;
      };

      // LineSplitter Dart语言封装的换行符，此处将文本按行分割
      Stream lines = file.openRead().transform(utf8.decoder).transform(const LineSplitter());
      await for (var line in lines) {
        //print(line);
        playList.add(PlayListItem(line, line.split('/').last, null));
      }

      return playList;
    } catch (e) {
      // If encountering an error, return 0
      print('PlaylistStorageServiceImpl.loadPlayList() - Exception: ' + e.toString() + ' filePath: '+filePath);
      return playList;
    }
  }

  @override
  Future<void> renamePlayList(PlayList playList, String newName) async {
    final File file = File(playList.filePath);

    String path = playList.filePath.substring(0, playList.filePath.lastIndexOf('/'));
    String filename = playList.filePath.split('/').last;
    String ext = filename.substring(filename.lastIndexOf("."));

    String newFilePath = '$path/$newName$ext';
    print('new file path: '+newFilePath);

    if (await file.exists()) {
      await file.rename(newFilePath);
    }
    playList.filePath = newFilePath;
    playList.name = newName;
  }

  @override
  Future<void> savePlayList(PlayList playList) async {
    final File file = File(playList.filePath);
    IOSink isk = file.openWrite(mode: FileMode.write);

    // 多次写入
    for(var i in playList.traces) {
      isk.writeln(i.file);
    }

    await isk.close();
  }

}