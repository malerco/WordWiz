import 'package:flutter/cupertino.dart';
import 'package:words/view/navigation/main_navigation.dart';

import '../../../configuration/constants.dart';
import '../../../storage/shared_preferences_data_provider.dart';

class LoaderViewModel extends ChangeNotifier{
  final BuildContext context;

  LoaderViewModel({required this.context}){
    loadingTimeout();
  }



  void loadingTimeout(){
    Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      Navigator.of(context).pushReplacementNamed(MainNavigationNames.mainMenu);
    });
  }
}