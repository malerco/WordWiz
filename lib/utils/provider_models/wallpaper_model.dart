import 'package:flutter/material.dart';

import '../../configuration/constants.dart';
import '../../storage/shared_preferences_data_provider.dart';

class WallpaperModel with ChangeNotifier {

  final SharedPreferencesDataProvider storageDataProvider;

  WallpaperModel({required this.storageDataProvider});

  var _wallpaperId = '1';

  get wallpaperId => _wallpaperId;

  set wallpaperId(value) {
    _wallpaperId = value;
    storageDataProvider.setValue(StorageKeysConstants.pictureId, _wallpaperId);
    notifyListeners();
  }

  Future<void> getWallpaper() async{
    _wallpaperId = await storageDataProvider.getValue(StorageKeysConstants.pictureId) ?? '1';
    notifyListeners();
  }
}