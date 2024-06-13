

import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:words/storage/shared_preferences_data_provider.dart';
import 'package:words/storage/storage_data_provider.dart';
import 'package:words/view/widgets/app/my_app.dart';

import '../../../configuration/constants.dart';
import '../../../domain/entities/letters.dart';
import '../../../domain/entities/line_points.dart';
import '../../../domain/entities/matrix_point.dart';
import '../../../domain/entities/point.dart';
import '../../../utils/crossword.dart';

class GameScreenViewModel extends ChangeNotifier {
  final SharedPreferencesDataProvider sharedPreferencesDataProvider;
  final StorageDataProvider storageDataProvider;
  final Crossword crosswordClass;
  var currentLocale = 'en';
  final List<List<String>> _origCrossword = [];
  final List<String> _letters = [];
  final List<String> _finalWords = [];
  final List<String> _extraWords = [];
  final List<int> _pressedLettersIndex = [];
  final Map<int, Point> _lettersPoint = {};
  final List<LinePoints> _linesPoint = [];
  var _wallpaperId = '1';
  final List<List<Letters>> _screenCrossword = [];
  final Map<String, List<MatrixPoint>> _wordsPoint = {};
  final List<String> _allWords = [];

  final List<MatrixPoint> _animationLetters = [];
   ColorTween _colorAnimation = ColorTween();

  String _userWordState = 'gone';

  bool _increaseButtonSize = false;

  var _finalUserWordForChecking = '';
  var _finalWordForAnimation = '';

  bool _isDrawing = true;
  bool isCrosswordReady = false;
  bool _isCrosswordFinished = false;

  Offset? _startPoint;
  Offset? _endPoint;


  List<MatrixPoint> get animationLetters => _animationLetters;

  ColorTween get colorAnimation => _colorAnimation;

  get wallpaperId => _wallpaperId;

  bool get isDrawing => _isDrawing;

  bool get isCrosswordFinished => _isCrosswordFinished;

  bool get increaseButtonSize => _increaseButtonSize;



  String get userWordState => _userWordState;

  List<String> get extraWords => _extraWords;

  List<List<String>> get crossword => _origCrossword;

  List<List<Letters>> get screenCrossword => _screenCrossword;

  String get word => _finalUserWordForChecking;

  String get animationWord => _finalWordForAnimation;

  List<String> get letters => _letters;

  List<String> get final_words => _finalWords;

  List<int> get pressedLettersIndex => _pressedLettersIndex;

  Map<int, Point> get lettersPoint => _lettersPoint;

  Map<String, List<MatrixPoint>> get wordsPoint => _wordsPoint;

  List<LinePoints> get linesPoint => _linesPoint;

  Offset? get startPoint => _startPoint;

  Offset? get endPoint => _endPoint;


  GameScreenViewModel({required this.sharedPreferencesDataProvider, required this.storageDataProvider, required this.crosswordClass});

  Future<void> getWallpaper() async{
    _wallpaperId = await sharedPreferencesDataProvider.getValue(StorageKeysConstants.pictureId) ?? '1';
    notifyListeners();
  }

  Future<void> recreateCrossword() async{
    isCrosswordReady = false;
    _isCrosswordFinished = false;

    notifyListeners();

    initCrossword();

  }

  Future<void> initCrossword() async{
    var crosswordResult = await crosswordClass.init(allWords: _allWords);

    Map<String, int> lettersMap = crosswordResult['letters_map'];

    List<String> letters = [];
    lettersMap.keys.forEach((element) {
      final count = lettersMap[element] ?? 0;
      for (int i = 0; i < count; i ++){
        letters.add(element);
      }
    });
    letters.shuffle();
    _clearLettersPoint();
    _setLetters(letters);
    _clearExtraWords();
    _setCrossword(crosswordResult['crossword']);
    _setFinalWords(crosswordResult['words']);
    _setWordsPoint(crosswordResult['words_points']);

    isCrosswordReady = true;
    notifyListeners();

    serialize();
    sharedPreferencesDataProvider.setValue(StorageKeysConstants.hasUnfinishedGame, 'true');
  }

  Future<void> getCurrentLocale() async{
    currentLocale = await sharedPreferencesDataProvider.getValue(StorageKeysConstants.language) ?? 'en';
    notifyListeners();
  }

  Future<void> init() async{
    List<String> listWithWords = await storageDataProvider.readFile('assets/files/${(await sharedPreferencesDataProvider.getValue(StorageKeysConstants.language)) ?? 'en'}.txt');
    _allWords.addAll(listWithWords);
    // _allWords.addAll(await getAllWordsForCrossword((await sharedPreferencesDataProvider.getValue(StorageKeysConstants.language)) ?? 'en'));
    initCrossword();
  }

  Future<void> restoreCrossword() async{
    List<String> listWithWords = await storageDataProvider.readFile('assets/files/${(await sharedPreferencesDataProvider.getValue(StorageKeysConstants.language)) ?? 'en'}.txt');
    _allWords.addAll(listWithWords);
    await deserialize();

  }

  bool isPointInsideCircle(double x1, double y1, double radius, double x2, double y2) {
    double distanceSquared = (x2 - x1) * (x2 - x1) + (y2 - y1) * (y2 - y1);
    double radiusSquared = radius * radius;
    return distanceSquared <= radiusSquared;
  }

  void onTapDownCircleKeyboard(TapDownDetails details){
    final double touchX = details.localPosition.dx;
    final double touchY = details.localPosition.dy;
    final lettersPoint = _lettersPoint;
    for (int i in lettersPoint.keys){
      if (lettersPoint[i] != null) {
        Point point = lettersPoint[i]!;
        bool isInside = isPointInsideCircle(point.x, point.y, 20, touchX, touchY);
        if (isInside) {
          _isDrawing = true;
          _addPressedLetters(i);
          // pressedLettersIndex.add(i);
          _setStartPoint(Offset(lettersPoint[i]!.x, lettersPoint[i]!.y));
          // startPoint = Offset(lettersPoint[i]!.x, lettersPoint[i]!.y); //+ радиус
        }
      }
    }
  }

  void onPanUpdateCircleKeyboard(DragUpdateDetails details){
    final lettersPoint = _lettersPoint;
    final pressedLettersIndex = _pressedLettersIndex;
    if (_startPoint != null) {
      for (int i in lettersPoint.keys) {
        if (lettersPoint[i] != null) {

          Point point = lettersPoint[i]!;
          bool isInside = isPointInsideCircle(
              point.x, point.y, 20, details.localPosition.dx,
              details.localPosition.dy);
          if (isInside) {

            if (!pressedLettersIndex.contains(i)) {
              _addPressedLetters(i);

              _addLinesPoint(LinePoints(startX: _startPoint!.dx, startY: startPoint!.dy, endX: lettersPoint[i]!.x, endY: lettersPoint[i]!.y));

              _setStartPoint(
                  Offset(lettersPoint[i]!.x, lettersPoint[i]!.y));

            }else{

              if (pressedLettersIndex.length > 1) {
                if (pressedLettersIndex[pressedLettersIndex.length -
                    2] == i) {
                  _removePressedLetters(pressedLettersIndex[pressedLettersIndex.length - 1]);
                  _setStartPoint(
                      Offset(lettersPoint[i]!.x, lettersPoint[i]!.y));
                }
              }
            }
          }
        }
      }
    }else{
      final double touchX = details.localPosition.dx;
      final double touchY = details.localPosition.dy;

      final lettersPoint = _lettersPoint;
      for (int i in lettersPoint.keys){
        if (lettersPoint[i] != null) {
          Point point = lettersPoint[i]!;
          bool isInside = isPointInsideCircle(point.x, point.y, 25, touchX, touchY);
          if (isInside) {
            _isDrawing = true;
            _addPressedLetters(i);

            _setStartPoint(Offset(lettersPoint[i]!.x, lettersPoint[i]!.y));

          }
        }
      }
    }


    if (_startPoint != null)
      _setEndPoint(Offset(details.localPosition.dx,
          details.localPosition.dy));

  }

  void onPanEndCircleKeyboard(DragEndDetails details){
    _checkWord(word);
    _isDrawing = false;
    _setStartPoint(null);
    _setEndPoint(null);
    _clearPressedLetters();
    _clearLinesPoint();
  }

  void onTapUpCircleKeyboard(TapUpDetails details){
    _checkWord(word);
    _isDrawing = false;
    _setStartPoint(null);
    _setEndPoint(null);
    _clearPressedLetters();
    _clearLinesPoint();
  }

  void _shakeWordOrNot(){
    _finalWordForAnimation = _finalUserWordForChecking;
    _finalUserWordForChecking = '';
    if (_userWordState == 'shaking') {
      Future.delayed(const Duration(milliseconds: 300)).then((value) {
        _finalWordForAnimation = '';
        _userWordState = 'gone';
        notifyListeners();
      });
    }else{
      if (_userWordState == 'guessed'){
        Future.delayed(const Duration(milliseconds: 300)).then((value) {
          _finalWordForAnimation = '';
          _userWordState = 'gone';
          notifyListeners();
        });
      }else if (_userWordState == 'swiping'){
        Future.delayed(const Duration(milliseconds: 1000)).then((value) {
          _finalWordForAnimation = '';
          _userWordState = 'gone';
          notifyListeners();
        });
      }
    }
  }

  void _setWordsPoint(Map<String, List<MatrixPoint>> wordsPoint) {
    _wordsPoint.clear();
    _wordsPoint.addAll(wordsPoint);
  }

  void _setFinalWords(List<String> words) {
    _finalWords.clear();
    _finalWords.addAll(words);
  }

  void _checkWord(String word) {

    if (final_words.contains(word)) {

      _userWordState = 'guessed';

      List<MatrixPoint> pointsList = _wordsPoint[word] ?? [];
      for (MatrixPoint point in pointsList) {

        _screenCrossword[point.x][point.y].value = point.value;
        _screenCrossword[point.x][point.y].visible = true;
        _screenCrossword[point.x][point.y].color = Colors.green;

      }

      serialize();
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 750)).then((value) {
        for (MatrixPoint point in pointsList) {

          _screenCrossword[point.x][point.y].color = Colors.white;

        }

        notifyListeners();


      },);

      if (_checkIsCrosswordFinished()){
        _isCrosswordFinished = true;
        sharedPreferencesDataProvider.setValue(StorageKeysConstants.hasUnfinishedGame, 'false');
        notifyListeners();
      }
    }else{
      if (_allWords.contains(word)){

        if (!_extraWords.contains(word)){
          _userWordState = 'swiping';
          _extraWords.add(word);
          serialize();
        }else{
          _userWordState = 'shaking';
          startIncreaseButtonSize();
        }

      }else {

        _userWordState = 'shaking';
      }
    }
    _shakeWordOrNot();
  }

  void _setCrossword(List<List<String>> crossword) {
    _origCrossword.clear();
    _screenCrossword.clear();
    _origCrossword.addAll(crossword);
    for (List<String> list in _origCrossword) {
      List<Letters> lettersModels = [];
      for (String s in list) {
        lettersModels.add(Letters(value: s, visible: false));
      }
      _screenCrossword.add(lettersModels);
    }

  }

  void serialize(){

    Map<String, dynamic> json = {
      StorageKeysConstants.origCrossword : _origCrossword.map((list) => list.toList()).toList(),
      StorageKeysConstants.screenCrossword : _screenCrossword.map((list) => list.map((e) => e.toJson()).toList()).toList(),
      StorageKeysConstants.extraWords : _extraWords,
      StorageKeysConstants.letters : _letters,
      StorageKeysConstants.finalWords : _finalWords,
      StorageKeysConstants.lettersPoint : _lettersPoint.map((key, value) => MapEntry(key.toString(), value.toJson())),
      StorageKeysConstants.wordsPoint : _wordsPoint.map((key, list) => MapEntry(key.toString(), list.map((e) => e.toJson()).toList())),
    };

    sharedPreferencesDataProvider.setValue(StorageKeysConstants.serializedJson, jsonEncode(json));
    
  }

  Future<void> deserialize() async{
    String jsonString = await sharedPreferencesDataProvider.getValue(StorageKeysConstants.serializedJson) ?? '{}';
    
    Map<String,dynamic> json = jsonDecode(jsonString);

    _origCrossword.clear();
    List<List<String>> deserializedData = (json[StorageKeysConstants.origCrossword] as List<dynamic>).map<List<String>>(
            (list) => (list as List<dynamic>).map<String>((item) => item.toString()).toList()).toList();

    _origCrossword.addAll(deserializedData);

    _screenCrossword.clear();
    _screenCrossword.addAll((json[StorageKeysConstants.screenCrossword] as List<dynamic>).map((list) => (list as List<dynamic>).map<Letters>((letter) => Letters.fromJson(letter as Map<String, dynamic>)).toList()).toList());

    _extraWords.clear();
    _extraWords.addAll((json[StorageKeysConstants.extraWords] as List<dynamic>).map((e) => e as String));

    _finalWords.clear();
    _finalWords.addAll((json[StorageKeysConstants.finalWords] as List<dynamic>).map((e) => e as String));

    _letters.clear();
    _letters.addAll((json[StorageKeysConstants.letters] as List<dynamic>).map((e) => e as String));

    final deserializedMap = json[StorageKeysConstants.lettersPoint].map<int, Point>((key, value) => MapEntry(int.parse(key), Point.fromJson(value)));
    _lettersPoint.addAll(deserializedMap);


    Map<String, List<MatrixPoint>> deserializedWordsPoint = (json[StorageKeysConstants.wordsPoint] as Map<String, dynamic>).map((key, value) {
      return MapEntry(key, (value as List).map((item) => MatrixPoint.fromJson(item)).toList());
    });
    _wordsPoint.clear();
    _wordsPoint.addAll(deserializedWordsPoint);


    isCrosswordReady = true;
    notifyListeners();
  }

  void _setStartPoint(Offset? point) {
    _startPoint = point;
    notifyListeners();
  }

  void _setEndPoint(Offset? point) {
    _endPoint = point;
    notifyListeners();
  }

  void _setLetters(List<String> list) {
    _letters.clear();
    _letters.addAll(list);

  }

  void _clearLettersList() {
    _letters.clear();
    notifyListeners();
  }

  void _setLettersPoint(Map<int, Point> lettersPoint) {
    _lettersPoint.clear();
    _lettersPoint.addAll(lettersPoint);

  }

  void _addLinesPoint(LinePoints point) {
    _linesPoint.add(point);

    notifyListeners();
  }

  void _clearLinesPoint() {
    _linesPoint.clear();
    notifyListeners();
  }

  void _clearLettersPoint() {
    _lettersPoint.clear();

  }

  void _addPressedLetters(int index) {
    if (index < _letters.length) {
      _pressedLettersIndex.add(index);
      _finalUserWordForChecking += _letters[index];
      notifyListeners();
    }
  }

  void _removePressedLetters(int index) {
    if (_pressedLettersIndex.length > 1) {
      if (index < _letters.length) {
        _pressedLettersIndex.remove(index);
        _finalUserWordForChecking = _finalUserWordForChecking.substring(0, _finalUserWordForChecking.length - 1);
        if (_linesPoint.length > 0)
          _linesPoint.removeLast();
        notifyListeners();
      }
    }
  }

  void _clearPressedLetters() {
    _pressedLettersIndex.clear();

    notifyListeners();
  }

  bool _checkIsCrosswordFinished(){
    final List<MatrixPoint> invisibleLetters = [];
    for (int i = 0; i < screenCrossword[0].length; i ++){
      for (int j = 0; j < screenCrossword.length; j ++){
        if (screenCrossword[i][j].value != '.' && screenCrossword[i][j].value != ':' && screenCrossword[i][j].value != '-' && screenCrossword[i][j].value != '0'){
          if (!screenCrossword[i][j].visible)
            invisibleLetters.add(MatrixPoint(x: i, y: j, value: ''));
        }
      }
    }
    return invisibleLetters.length == 0;
  }

  void showRandomLetter(){
    final List<MatrixPoint> invisibleLetters = [];
    for (int i = 0; i < screenCrossword[0].length; i ++){
      for (int j = 0; j < screenCrossword.length; j ++){
        if (screenCrossword[i][j].value != '.' && screenCrossword[i][j].value != ':' && screenCrossword[i][j].value != '-' && screenCrossword[i][j].value != '0'){
          if (!screenCrossword[i][j].visible)
            invisibleLetters.add(MatrixPoint(x: i, y: j, value: ''));
        }
      }
    }
    if (invisibleLetters.length > 0) {
      final point = invisibleLetters[Random().nextInt(invisibleLetters.length)];
      screenCrossword[point.x][point.y].visible = true;
      screenCrossword[point.x][point.y].color = Colors.green;
      serialize();
      notifyListeners();

      Future.delayed(const Duration(milliseconds: 750)).then((value) {
        screenCrossword[point.x][point.y].color = Colors.white;
        notifyListeners();
      },);

      if (_checkIsCrosswordFinished()){
        _isCrosswordFinished = true;
        sharedPreferencesDataProvider.setValue(StorageKeysConstants.hasUnfinishedGame, 'false');
        notifyListeners();
      }
    }
  }

  void shuffleLetters(){
    _letters.shuffle();
    notifyListeners();
  }

  void _clearExtraWords(){
    _extraWords.clear();
  }

  void addExtraWords(String word){
    _extraWords.add(word);
  }

  void startIncreaseButtonSize() {
    _increaseButtonSize = true;

    notifyListeners();
    Future.delayed(const Duration(milliseconds: 1500)).then((value) {
      _increaseButtonSize = false;

      notifyListeners();
    });

  }


}
