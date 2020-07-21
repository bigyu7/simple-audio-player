import 'package:get_it/get_it.dart';

import 'package:simply_audio_player/service/playlist_storage_service_impl.dart';
//import 'package:simply_audio_player/service/playlist_storage_service_mock.dart';
import 'package:simply_audio_player/service/playlist_storege_service.dart';

import 'package:simply_audio_player/service/config_storage_service.dart';
//import 'package:simply_audio_player/service/config_storage_service_mock.dart';
import 'package:simply_audio_player/service/config_storage_service_impl.dart';

import 'package:simply_audio_player/view_model/player_viewmodel.dart';
import 'package:simply_audio_player/view_model/playlist_viewmodel.dart';

// Using GetIt is a convenient way to provide services and view models
// anywhere we need them in the app.
GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // services
  //serviceLocator.registerLazySingleton<ConfigStorageService>(() => MockConfigStorageService());
  //serviceLocator.registerLazySingleton<PlaylistStorageService>(() => MockPlaylistStorageService());
  serviceLocator.registerLazySingleton<ConfigStorageService>(() => ConfigStorageServiceImpl());
  serviceLocator.registerLazySingleton<PlaylistStorageService>(() => PlaylistStorageServiceImpl());

  // view models
  serviceLocator.registerLazySingleton<PlayerViewModel>(() => PlayerViewModel());
  serviceLocator.registerFactory<PlayListViewModel>(() => PlayListViewModel());
}
