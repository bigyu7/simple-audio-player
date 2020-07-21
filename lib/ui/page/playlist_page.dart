import 'dart:async';
//import 'dart:io';
//import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:simply_audio_player/model/playlist.dart';
import 'package:simply_audio_player/service/service_locator.dart';
import 'package:simply_audio_player/view_model/playlist_viewmodel.dart';
import 'package:simply_audio_player/ui/widget/play_panel_widget.dart';
import 'package:simply_audio_player/view_model/player_viewmodel.dart';

class PlayListPage extends StatefulWidget {
  @override
  _PlayListPageState createState() => _PlayListPageState();
}

class _PlayListPageState extends State<PlayListPage> {
  PlayerViewModel _playerModel = serviceLocator<PlayerViewModel>();
  PlayListViewModel _playListModel = serviceLocator<PlayListViewModel>();

  @override
  void initState() {
    _playListModel.loadFromConfig();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => _playerModel),
        ChangeNotifierProvider(create: (_) => _playListModel),
      ],
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.menu),
            tooltip: 'Navigation menu',
            onPressed: null,
          ),
          title: Consumer<PlayListViewModel>(
            builder: (context, playList, child) => Text(
              '${playList.name}'
            ),
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

  Future _addToPlayList() async {
    var path;
    try {
      path = await FilePicker.getFilePath(
        type: FileType.audio,
      );
    } on PlatformException catch (e) {
      print("Unsupported operation" + e.toString());
    }
    if (path==null) return;
    if (!mounted) return;

    _playListModel.add(PlayListItem(path, path.split('/').last, null));

  }

}

class _PlayListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    var itemNameStyle = Theme.of(context).textTheme.headline6;
    var itemNameStyle = Theme.of(context).textTheme.bodyText2;
    var activedItemNameStyle = Theme.of(context).textTheme.bodyText1;
    var _playList = Provider.of<PlayListViewModel>(context);

    return ListView.builder(
      itemCount: _playList.traces.length,
      itemBuilder: (context, index) => ListTile(
        onTap: () {
          _playList.playIndex(index);
        },
        leading: _playList.isCurrentTrace(index) ? Icon(Icons.volume_up,color: activedItemNameStyle.color):Icon(Icons.play_arrow),
        title: Text(
          _playList.traces[index].title,
          style: _playList.isCurrentTrace(index) ? activedItemNameStyle : itemNameStyle,
        ),
//        subtitle: Text(
//          _playList.traces[index].file,
//          //style: itemNameStyle,
//        ),
      ),
    );
  }
}