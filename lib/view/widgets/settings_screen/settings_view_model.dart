import 'package:flutter/material.dart';

import '../../../configuration/constants.dart';
import '../../../storage/shared_preferences_data_provider.dart';

class SettingsScreenViewModel extends ChangeNotifier{
    String _selectedLanguage = 'en';
    String _selectedPicId = '0';

    final SharedPreferencesDataProvider storageDataProvider;

    String get selectedPicId => _selectedPicId;

    String get selectedLanguage => _selectedLanguage;


  set selectedPicId(String value) {
      _selectedPicId = value;
      // notifyListeners();
  }

    set selectedLanguage(String value) {
    _selectedLanguage = value;
    // notifyListeners();
  }

  void updateSelectedPicId(String value){
    _selectedPicId = value;
    notifyListeners();
  }

  void updateSelectedLanguage(String value){
    _selectedLanguage = value;
    notifyListeners();
  }

  SettingsScreenViewModel({required this.storageDataProvider});

    Future<void> init() async{

    }

}