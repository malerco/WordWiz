import 'dart:io';

import 'package:flutter/material.dart';

import '../../../configuration/constants.dart';
import '../../../storage/shared_preferences_data_provider.dart';
import '../../navigation/main_navigation.dart';

class MainMenuViewModel extends ChangeNotifier{
  var currentLocale = 'en';
  var _wallpaperId = '1';
  var hasFinishedGames = false;
  final SharedPreferencesDataProvider storageDataProvider;

  MainMenuViewModel({required this.storageDataProvider});

  get wallpaperId => _wallpaperId;

  void checkUnfinishedGames() async {
    String? stringValue = await storageDataProvider.getValue(StorageKeysConstants.hasUnfinishedGame);

    if (stringValue != null){
      hasFinishedGames = bool.parse(stringValue);
      notifyListeners();
    }

  }

  Future<void> getCurrentLocale() async{
    currentLocale = await storageDataProvider.getValue(StorageKeysConstants.language) ?? 'en';
    notifyListeners();
  }

  Future<void> getWallpaper() async{
    _wallpaperId = await storageDataProvider.getValue(StorageKeysConstants.pictureId) ?? '1';
    notifyListeners();
  }

  Future<void> onTapOnContinueGame(BuildContext context) async{
    await Navigator.of(context).pushNamed(MainNavigationNames.continueGameScreen);
    checkUnfinishedGames();
  }


  Future<void> onTapOnNewGame(BuildContext context) async{
    await Navigator.of(context).pushNamed(MainNavigationNames.newGameScreen);
    checkUnfinishedGames();
  }

  void onTapOnSettings(BuildContext context) async{
    await Navigator.of(context).pushNamed(MainNavigationNames.settingsScreen);
    await getCurrentLocale();
    await getWallpaper();
    checkUnfinishedGames();
  }


}

