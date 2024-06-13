import 'package:flutter/material.dart';

class Constants{
  static const assets = 'assets/';
  static const gameScreen = 'assets/game_screen.jpg';
  static const otherWords = 'assets/other_words.png';
  static const hammer = 'assets/hammer.png';
  static const shuffle = 'assets/shuffle.png';
  static const menuTitle = 'Word Wiz';
  static const gameButtonsWidth = 50.0;
  static const gameButtonsHeight = 50.0;
  static const localeList = ['be', 'de', 'en', 'es', 'fr', 'hi', 'ru', 'uk'];
}

class LocaleConstants{
  static const continueGame = 'continue_game';
  static const newGame = 'new_game';
  static const settings = 'settings';
  static const gameFinished = 'game_finished';
  static const createNew = 'create_new';
  static const extraWords = 'extra_words';
  static const languageSelection = 'language_selection';
  static const backgroundSelection = 'background_selection';
  static const apply = 'apply';
}

class StorageKeysConstants{
  static const language = 'language';
  static const pictureId = 'picture_id';
  static const screenCrossword = 'screen_crossword';
  static const origCrossword = 'orig_crossword';
  static const letters = 'letters';
  static const finalWords = 'final_words';
  static const extraWords = 'extra_words';
  static const lettersPoint = 'letters_point';
  static const hasUnfinishedGame = 'has_unfinished_game';
  static const serializedJson = 'serialzed_json';
  static const wordsPoint = 'words_point';
}

class ColorConstants{
  static const menuButtonColor = Color.fromRGBO(224, 219, 209, 0.6);
}