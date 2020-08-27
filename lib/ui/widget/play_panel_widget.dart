import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_audio_player/model/play_mode.dart';
import 'package:simple_audio_player/view_model/player_viewmodel.dart';
import 'package:simple_audio_player/view_model/playlist_viewmodel.dart';

class PlayPanel extends StatelessWidget {

  IconData _getPlayModeIcon(PlayMode playMode) {
    switch(playMode) {
      case PlayMode.in_order:
        return Icons.playlist_play;
      case PlayMode.repeat:
        return Icons.replay;
      case PlayMode.repeat_one:
        return Icons.repeat_one;
      case PlayMode.shuffle:
        return Icons.shuffle;
      case PlayMode.only_one:
        return Icons.looks_one;
    }
    return Icons.playlist_play;
  }

  @override
  Widget build(BuildContext context) {
//    var hugeStyle = Theme.of(context).textTheme.headline1.copyWith(fontSize: 48);
    var playList = Provider.of<PlayListViewModel>(context);

    return SizedBox(
      height: 200,
      child: Container(
        //color: Theme.of(context).dialogBackgroundColor,
        decoration: BoxDecoration(
          color: Theme.of(context).dialogBackgroundColor,
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              // 当前播放音轨名称
              ListTile(
//              leading: Icon(Icons.album),
                title: Consumer<PlayerViewModel>(
                builder: (context, player, child) => Text(
                  '${player.traceFileName}',
                  style: Theme.of(context).textTheme.headline6,
                  ),
                ),
//              subtitle: Consumer<PlayerViewModel>(
//                builder: (context, player, child) => Text(
//                  '${player.traceFilePath}',
//                ),
//              ),
              ),

              // 进度条
              Consumer<PlayerViewModel>(
                builder: (context, player, child) => Padding(
                  padding: const EdgeInsets.only(left: 8, top: 0, right: 5, bottom: 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('${player.positionText}'),
                      Expanded(
                        child: Slider(
                            value: player.position?.inMilliseconds?.toDouble() ?? 0.0,
                            onChanged: (double value) {
                              return player.seek((value / 1000).roundToDouble());
                            },
                            min: 0.0,
                            max: player.duration?.inMilliseconds?.toDouble() ?? 10.0,
                        ),
                      ),
                      Text('${player.durationText}'),
                    ]
                  ),
                ),
              ),

              // 按钮
              Row(
                mainAxisSize: MainAxisSize.min,
                //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[

                  Consumer<PlayListViewModel>(
                    builder: (context, playList, child) => IconButton(
                      onPressed: () { playList.nextPlayMode(); },
                      iconSize: 48.0,
                      icon: Icon(_getPlayModeIcon(playList.playMode)),
                      color: Theme.of(context).accentColor,
                    ),
                  ),

                  Consumer<PlayListViewModel>(
                    builder: (context, playList, child) => IconButton(
                      onPressed: playList.canPrevious() ? ( () { playList.previous(); } ) : null,
                      iconSize: 48.0,
                      icon: Icon(Icons.skip_previous),
                      color: Theme.of(context).accentColor,
                    ),
                  ),

                  Consumer<PlayerViewModel>(
                    builder: (context, player, child) => IconButton(
                        onPressed: playList.canPlay() ? (() {
                          playList.playOrPause();
                        }) : null,
                        iconSize: 64.0,
                        icon: Icon(player.isPlaying?Icons.pause_circle_filled:Icons.play_circle_filled),   //Icons.pause_circle_filled
                        color: Theme.of(context).accentColor,
                    ),
                  ),

                  Consumer<PlayListViewModel>(
                    builder: (context, playList, child) => IconButton(
                      onPressed: playList.canNext() ? ( () { playList.next(); } ) : null,
                      iconSize: 48.0,
                      icon: Icon(Icons.skip_next),
                      color: Theme.of(context).accentColor,
                    ),
                  ),

                  Consumer<PlayerViewModel>(
                    builder: (context, player, child) => IconButton(
                      onPressed: (() {
                        player.mute(!player.isMuted);
                      }),
                      iconSize: 48.0,
                      icon: Icon(player.isMuted?Icons.volume_off:Icons.volume_up),   //Icons.pause_circle_filled
                      color: Theme.of(context).accentColor,
                    ),
                  ),

                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}