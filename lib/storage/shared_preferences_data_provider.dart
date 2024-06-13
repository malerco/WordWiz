import 'package:shared_preferences/shared_preferences.dart';
import 'package:words/configuration/constants.dart';

abstract class SharedPreferencesDataProvider{

  Future<String?> getValue(String key);
  Future<void> setValue(String key, String value);
}

class DefaultSharedPreferencesDataProvider implements SharedPreferencesDataProvider{
  final Future<SharedPreferences> _sharedPreferences;

  DefaultSharedPreferencesDataProvider(this._sharedPreferences);

  Future<SharedPreferences> getInstance() async{
    return await _sharedPreferences;
  }


  @override
  Future<String?> getValue(String key) async{
    String? returnValue;
    await _sharedPreferences.then((value) => returnValue = value.getString(key));
    return returnValue;
  }

  @override
  Future<void> setValue(String key, String value) async{
    (await _sharedPreferences).setString(key, value);
  }


}