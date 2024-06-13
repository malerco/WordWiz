import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words/storage/shared_preferences_data_provider.dart';
import 'package:words/storage/storage_data_provider.dart';
import 'package:words/utils/provider_models/language_model.dart';
import 'package:words/utils/provider_models/wallpaper_model.dart';
import 'package:words/view/widgets/game_screen/game_screen_view_model.dart';
import 'package:words/view/widgets/game_screen/game_screen_widget.dart';
import 'package:words/view/widgets/settings_screen/settings_screen.dart';
import 'package:words/view/widgets/settings_screen/settings_view_model.dart';

import '../main.dart';
import '../utils/crossword.dart';
import '../view/navigation/main_navigation.dart';
import '../view/widgets/app/my_app.dart';
import '../view/widgets/loader/loader_view_model.dart';
import '../view/widgets/loader/loader_widget.dart';
import '../view/widgets/main_menu/main_menu_view_model.dart';
import '../view/widgets/main_menu/main_menu_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

AppFactory makeAppFactory() => _AppFactoryDefault();

class _AppFactoryDefault implements AppFactory {
  final _diContainer = _DIContainer();

  _AppFactoryDefault();
  @override
  Widget makeApp() => MultiProvider(
      providers: [
        ChangeNotifierProvider(create:  (context) => LanguageModel(sharedPreferencesDataProvider: _diContainer._makeSharedPreferencesDataProvider()),),
        ChangeNotifierProvider(create: (context) =>  WallpaperModel(storageDataProvider: _diContainer._makeSharedPreferencesDataProvider())..getWallpaper(),)
      ],
      child: MyApp(navigation: _diContainer._makeMyAppNavigation()));
}

class _DIContainer{
  final Future<SharedPreferences> _sharedPreferences = SharedPreferences.getInstance();

  _DIContainer();

  SharedPreferencesDataProvider _makeSharedPreferencesDataProvider() => DefaultSharedPreferencesDataProvider(_sharedPreferences);

  StorageDataProvider _makeStorageDataProvider() => DefaultStorageDataProvider();

  ScreenFactory _makeScreenFactory() => _DefaultScreenFactory(this);
  MyAppNavigation _makeMyAppNavigation() =>
      MainNavigation(_makeScreenFactory());

  LoaderViewModel _makeLoaderViewModel(BuildContext context) => LoaderViewModel(

      context: context,
      );

  MainMenuViewModel _makeMenuViewModel() => MainMenuViewModel(
    storageDataProvider: _makeSharedPreferencesDataProvider()
  );

  GameScreenViewModel _makeGameScreenViewModel() => GameScreenViewModel(
    crosswordClass: CrosswordMaker(),
    storageDataProvider: _makeStorageDataProvider(),
    sharedPreferencesDataProvider: _makeSharedPreferencesDataProvider()
  );

  SettingsScreenViewModel _makeSettingsScreenModel() => SettingsScreenViewModel(
    storageDataProvider: _makeSharedPreferencesDataProvider(),
  );
}

class _DefaultScreenFactory implements ScreenFactory{
  final _DIContainer _diContainer;

  _DefaultScreenFactory(this._diContainer);

  @override
  Widget showLoader(){
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => _diContainer._makeLoaderViewModel(context),
          lazy: false,
        ),
      ],
      child: const LoaderWidget(),
    );
  }

  @override
  Widget showMainMenuScreen(){
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeMenuViewModel()..checkUnfinishedGames()..getCurrentLocale()..getWallpaper(),
      child: const MainMenuWidget(),
    );
  }

  @override
  Widget showContinueGameScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeGameScreenViewModel()..restoreCrossword()..getWallpaper(),
      child: const GameScreenWidget(),
      lazy: false,
    );
  }

  @override
  Widget showNewGameScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeGameScreenViewModel()..init()..getWallpaper(),
      child: const GameScreenWidget(),
      lazy: false,
    );
  }

  @override
  Widget showSettingsScreen() {
    return ChangeNotifierProvider(
      create: (context) => _diContainer._makeSettingsScreenModel(),
      child: const SettingsScreen(),
    );
  }
}