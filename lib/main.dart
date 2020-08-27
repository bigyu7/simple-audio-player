import 'package:flutter/material.dart';

import 'package:simple_audio_player/service/service_locator.dart';
import 'package:simple_audio_player/ui/page/playlist_page.dart';

void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simply Audio Player',
      theme: ThemeData(
        // Define the default brightness and colors.
        brightness: Brightness.light,
        //primaryColor: Colors.lightBlue[800],
        //accentColor: Colors.cyan[600],
        dialogBackgroundColor: Colors.grey[200],

        // Define the default font family.
        fontFamily: 'Georgia',

        // Define the default TextTheme. Use this to specify the default
        // text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          //headline1: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
          //headline6: TextStyle(fontSize: 36.0, fontStyle: FontStyle.italic),
          bodyText1: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          //bodyText2: TextStyle(fontSize: 14.0, fontFamily: 'Hind'),
        ),
      ),
      home: PlayListPage(),
    );
  }
}

/*
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Using MultiProvider is convenient when providing multiple objects.
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => PlayerViewModel(),),
        ChangeNotifierProvider(
          create: (context) {
            return PlayListViewModel(PlayList('默认播放列表', []));
          }
        ),
        ChangeNotifierProxyProvider<PlayListViewModel, TraceModel>(
          create: (context) {
            return TraceModel(
              Provider.of<PlayListViewModel>(context, listen: false),
            );
          },
          update: (context, playList, trace) {
            trace.playList=playList;
            return trace;
          },
        )
      ],
      child: MaterialApp(
        title: 'Simply audio player',
//        theme: appTheme,
        initialRoute: '/',
        routes: {
          '/': (context) => PlayListPage(),
//          '/catalog': (context) => MyCatalog(),
//          '/cart': (context) => MyCart(),
        },
      ),
    );
  }
}

 */