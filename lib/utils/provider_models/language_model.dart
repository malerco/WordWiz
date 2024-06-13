import 'package:flutter/material.dart';

import '../../configuration/constants.dart';
import '../../storage/shared_preferences_data_provider.dart';

class LanguageModel extends ChangeNotifier {
  final SharedPreferencesDataProvider sharedPreferencesDataProvider;
  String? _languageString;
  String? get languageString => _languageString;

  Future<void> setLocale(String locale) async{

    _languageString = await sharedPreferencesDataProvider.getValue(StorageKeysConstants.language);
    if (locale != null && Constants.localeList.contains(locale)) {
      if (_languageString == null){
        _languageString = locale;
        await sharedPreferencesDataProvider.setValue(StorageKeysConstants.language, locale);
      }
    }else{
      if (_languageString == null) {
        _languageString = 'en';
        await sharedPreferencesDataProvider.setValue(
            StorageKeysConstants.language, _languageString ?? 'en');
      }
    }
  }

  Future<void> updateLocale(String locale) async{
    if (_languageString != locale) {
      _languageString = locale;
      await sharedPreferencesDataProvider.setValue(StorageKeysConstants.language, _languageString ?? 'en');
      await sharedPreferencesDataProvider.setValue(StorageKeysConstants.hasUnfinishedGame, 'false');
      notifyListeners();
    }
  }

  LanguageModel({required this.sharedPreferencesDataProvider});

}