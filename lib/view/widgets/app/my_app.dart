import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n_delegate.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:words/utils/provider_models/language_model.dart';
import 'package:words/utils/provider_models/wallpaper_model.dart';

import '../../navigation/main_navigation.dart';

abstract class MyAppNavigation {
  Map<String, Widget Function(BuildContext)> get routes;
  Route<Object> onGenerateRoute(RouteSettings settings);
}

abstract class Crossword{
  Future<Map<String, dynamic>> init({required List<String> allWords});
}

class MyApp extends StatelessWidget {

  final MyAppNavigation navigation;
  const MyApp({super.key, required this.navigation});


  @override
  Widget build(BuildContext context) {

    return Consumer2<LanguageModel, WallpaperModel>(
      builder: (context, languageModel, wallpaperModel, child) {
        return MaterialApp(
          title: 'Word Wiz',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          debugShowCheckedModeBanner: false,

          localizationsDelegates: [
            FlutterI18nDelegate(
              translationLoader: FileTranslationLoader(
                basePath: 'assets/locales',
                fallbackFile: 'en.json', // Файл для языка по умолчанию
              ),
              missingTranslationHandler: (key, locale) {
                // print('Missing translation for key: $key, locale: $locale');
              },
            ),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('es', ''),
            Locale('ru', ''),
            // Добавьте другие поддерживаемые языки здесь
          ],
          localeResolutionCallback: (locale, supportedLocales) {
            if (languageModel.languageString == null) {
              languageModel.setLocale(locale?.languageCode ?? 'en');
            }
            return Locale(languageModel.languageString ?? 'en');
          },
          routes: navigation.routes,
          initialRoute: MainNavigationNames.loaderWidget,
          onGenerateRoute: navigation.onGenerateRoute,
        );
      },
    );
  }


}