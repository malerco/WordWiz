

import 'package:flutter/material.dart';
import 'package:words/view/widgets/app/my_app.dart';

abstract class MainNavigationNames{
  static const loaderWidget = '/';
  static const mainMenu = '/menu';
  static const newGameScreen = '/new_game';
  static const continueGameScreen = '/continue_game';
  static const settingsScreen = '/settings';
}

abstract class ScreenFactory{
  Widget showLoader();
  Widget showMainMenuScreen();
  Widget showNewGameScreen();
  Widget showContinueGameScreen();
  Widget showSettingsScreen();
}

class MainNavigation implements MyAppNavigation{
  final ScreenFactory screenFactory;

  MainNavigation(this.screenFactory);

  @override
  // TODO: implement routes
  Map<String, Widget Function(BuildContext context)> get routes => {
    MainNavigationNames.loaderWidget : (context) => screenFactory.showLoader(),
    MainNavigationNames.mainMenu : (context) => screenFactory.showMainMenuScreen(),
    MainNavigationNames.newGameScreen : (context) => screenFactory.showNewGameScreen(),
    MainNavigationNames.continueGameScreen : (context) => screenFactory.showContinueGameScreen(),
    MainNavigationNames.settingsScreen : (context) => screenFactory.showSettingsScreen(),
  };

  @override
  Route<Object> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      default:
        const widget = Text('Navigation error');
        return MaterialPageRoute(builder: (_) => widget);
    }
  }
}