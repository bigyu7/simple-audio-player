import 'dart:async';
//import 'dart:io';
//import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:simple_audio_player/model/playlist.dart';
import 'package:simple_audio_player/service/service_locator.dart';
import 'package:simple_audio_player/view_model/playlist_viewmodel.dart';
import 'package:simple_audio_player/ui/widget/play_panel_widget.dart';
import 'package:simple_audio_player/view_model/player_viewmodel.dart';

class PlayListPage extends StatefulWidget {
  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  PlayerViewModel _playerModel = serviceLocator<PlayerViewModel>();
  PlayListViewModel _playListModel = serviceLocator<PlayListViewModel>();
  TextEditingController _controller;
  bool _isListNameEditing = false;    // 是否是在编辑播放列表的名字

  @override
  void initState() {
    _playListModel.loadFromConfig();
    _controller = TextEditingController();
    _isListNameEditing = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _playerModel),
        ChangeNotifierProvider(create: (_) => _playListModel),
//        ChangeNotifierProxyProvider<PlayerViewModel, PlayListViewModel>(
//          create: (_) => _playListModel,
//          update: (_,  player,  playList) {
//            print('*** ChangeNotifierProxyProvider update() *****');
//            return _playListModel;
//          },
//        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: PopupMenuButton<String>(
            icon: Icon(Icons.menu),
            onSelected: (String value) => _choosePlayList(value) ,
            itemBuilder: (BuildContext context) => _buildPlayListPopupMenuEntry(context),
          ),

          title: Consumer<PlayListViewModel>(
            builder: (context, playList, child) => _buidAppBarTitle(playList),
          ),

          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              tooltip: '添加音频文件',
              onPressed: () => _addToPlayList(),
            ),
          ],
        ),
        body: Container(
//        color: Colors.yellow,
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
//                padding: const EdgeInsets.all(32),
                  child: _PlayListView(),
                ),
              ),
              //Divider(height: 4, color: Colors.black),
              PlayPanel()
            ],
          ),
        ),
      ),
    );

  }

  List<PopupMenuEntry<String>> _buildPlayListPopupMenuEntry(BuildContext context) {
    List<PopupMenuEntry<String>> items = [];

    items.add(
        PopupMenuItem<String>(
          value: 'new',
          child: Text('新建播放列表'),
        )
    );
    items.add(
        PopupMenuItem<String>(
          value: 'choose',
          child: Text('选择播放列表'),
        )
    );

    if(_playListModel.hasRecentPlayList) {
      items.add(PopupMenuDivider());
      _playListModel.recentPlayLists.reversed.forEach((filePath) {

        String filename = filePath.split('/').last;
        String name = filename.substring(0,filename.lastIndexOf("."));

        items.add(
            PopupMenuItem<String>(
              value: filePath,
              child: Text(name),
            )
        );
      });
    }

    return items;
  }

  void _choosePlayList(String type) async {
    print('_choosePlayList: '+type);
    switch(type) {
      case 'new':     // 创建一个新的播放列表
        setState(() {
          _playListModel.newPlayList();
        });
        break;
      case 'choose':    // 选择一个.m3u文件
        String filesPath;
        try {
          filesPath = await FilePicker.getFilePath(
            type: FileType.custom,
            allowedExtensions: ['m3u'],
          );
        } on PlatformException catch (e) {
          print("Unsupported operation" + e.toString());
        }
        if (filesPath==null) return;
        if (!mounted) return;
        setState(() {
          _playListModel.loadPlayListFromFile(filesPath);
        });
        break;
      default:
        setState(() {
          _playListModel.loadPlayListFromFile(type);
        });
        break;
    }
  }

  Widget _buidAppBarTitle(PlayListViewModel playList) {
    if(_isListNameEditing) {
      _controller.text = playList.name;
      return TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          focusColor: Colors.white,
          fillColor: Colors.white,
          filled: true,
        ),
        autofocus: true,
        controller: _controller,
        onChanged: (text) {
          print("text field onChanged: $text");
        },
        onSubmitted: (String text) {
          print("text field onSubmitted: $text");
          setState(() {
            playList.changeName(_controller.text.trim());
            _isListNameEditing = false;
          });
        },
      );
    } else {
      return GestureDetector(
        onTap: () {
          setState(() {
            _isListNameEditing = true;
          });
        },
        child: Text(playList.name),
      );
    }
  }

  Future _addToPlayList() async {
    Map<String,String> filesPaths;
    try {
      filesPaths = await FilePicker.getMultiFilePath(
        type: FileType.audio,
      );
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (filesPaths==null) return;
    if (!mounted) return;

    filesPaths.forEach((name, path) {
//      _playListModel.add(PlayListItem(path, path.split('/').last, null));
      print('key: '+name+' value: '+path);
      _playListModel.add(PlayListItem(path, name, null));
    });


  }

}

class _PlayListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var itemNameStyle = Theme.of(context).textTheme.bodyText2;
    var activedItemNameStyle = Theme.of(context).textTheme.bodyText1;
    var _playList = Provider.of<PlayListViewModel>(context);

    return ReorderableListView(
      children: _playList.traces.asMap().map((index, item) => MapEntry(index,
          Dismissible(
            key: Key(item.file),
            // crossAxisEndOffset: 1.0,
            // secondaryBackground: Container(color: Colors.pink),
            dragStartBehavior: DragStartBehavior.down,
            direction: DismissDirection.endToStart,
            background: Container(
              padding: const EdgeInsets.only(right: 30),
              alignment: Alignment.centerRight,
              color: Colors.red,
              child: Text(
                '向左滑动移除音轨',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            onDismissed: (direction) {
              _playList.removePlayListItemAt(index);
    //            print(_list.length);
              Scaffold.of(context).hideCurrentSnackBar();
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('移除成功'),
              ));
            },
            child: ListTile(
              onTap: () {
                if( _playList.isCurrentTrace(index))
                  _playList.playOrPause();
                else _playList.playIndexAndResetStrategy(index);
              },
              leading: _playList.isCurrentTrace(index) ? Icon(Icons.volume_up,color: activedItemNameStyle.color) : (_playList.willPlay(index) ? Icon(Icons.play_arrow):Icon(Icons.block)),
              title: Text(
                item.title,
                style: _playList.isCurrentTrace(index) ? activedItemNameStyle : itemNameStyle,
              ),
    //        subtitle: Text(
    //          _playList.traces[index].file,
    //          //style: itemNameStyle,
    //        ),
            ),

          )
        )).values.toList(),

      onReorder: (int oldIndex, int newIndex) {
//        print("onReorder: $oldIndex --- $newIndex");
        _playList.reorderPlayListItem(oldIndex, newIndex);
      },
    );


  }
}