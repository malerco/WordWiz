import 'dart:async';
import 'dart:isolate';
import 'dart:math';
import 'dart:ui';

import 'package:words/view/widgets/app/my_app.dart';

import '../domain/entities/matrix_point.dart';



class CrosswordMaker extends Crossword{
  List<String> all_words = [];
  List<String> words = [];
  List<String> wordsFromLetters = [];
  List<String> randomLetters = [];
  List<String> final_words = [];
  int offsetX = 0;
  int offsetY = 0;

  Map<String, List<MatrixPoint>> wordsPoints = {};

  Future<List<List<String>>> removeEmptyColumns(List<List<String>> matrix, List<List<String>> removeList) async{
    List<List<String>> result = [];
    List<int> columnIndices = [];

    for (int col = 0; col < matrix[0].length; col++) {
      bool isEmpty = true;
      for (int row = 0; row < matrix.length; row++) {
        if (matrix[row][col] != '0' && matrix[row][col] != '.' && matrix[row][col] != ':' && matrix[row][col] != '-') {
          isEmpty = false;
          break;
        }
      }

      if (!isEmpty) {
        columnIndices.add(col);
      }
    }


    int countToRemove = 0;
    if (removeList.length < columnIndices.length){
      countToRemove = removeList.length;
    }else{
      countToRemove = columnIndices.length;
    }
    for (int index = 0; index < countToRemove; index ++){
      matrix.remove(removeList[index]);
    }



    for (int row = 0; row < matrix.length; row++) {
      List<String> newRow = [];
      for (int index = 0; index < countToRemove; index ++){
        newRow.add(matrix[row][columnIndices[index]]);
      }

      result.add(newRow);
    }


    return result;

  }


  @override
  Future<Map<String, dynamic>> init({required List<String> allWords}) async{
    all_words.addAll(allWords);

    final receivePort = ReceivePort();
    final completer = Completer<Map<String, dynamic>>();

    await Isolate.spawn(isolateCrosswordInit, {'sendPort': receivePort.sendPort, 'allWords': allWords});

    receivePort.listen((message) {
      completer.complete(message);
      receivePort.close();
    });

    return completer.future;

  }

  static void isolateCrosswordInit(Map<String, dynamic> message) async {
    final SendPort sendPort = message['sendPort'];
    final List<String> allWords = message['allWords'];

    List<String> words = [];
    List<String> wordsFromLetters = [];
    List<String> randomLetters = [];
    List<String> final_words = [];
    int offsetX = 0;
    int offsetY = 0;

    Map<String, List<MatrixPoint>> wordsPoints = {};

    var isCrosswordReady = false;
    Map<String,
        int> letters_counter = {};
    List<List<String>> matrix = [];


    while (!isCrosswordReady) {

      matrix.clear();
      letters_counter.clear();
      words.clear();
      wordsFromLetters.clear();
      final_words.clear();
      randomLetters.clear();
      wordsPoints.clear();

      offsetX = 0;
      offsetY = 0;


      lookingForRandomLetters(allWords, randomLetters);

      setupWordsList(allWords, wordsFromLetters, randomLetters, words);

      matrix = matrixGenerate(words, final_words, wordsPoints);

      offsetX = findEmptyRows(matrix);

      offsetY = findEmptyColumns(matrix);

      setWordPointsInMatrix(wordsPoints, offsetX, offsetY);

      letters_counter = detectHowManyEachLettersKeyboardNedded(randomLetters, final_words);

      int finalCount = 0;
      letters_counter.keys.forEach((element) {
        finalCount += letters_counter[element] ?? 0;
      },);
      if (finalCount <= 9) {
        isCrosswordReady = true;
      }

    }

    sendPort.send({
      'crossword' : matrix,
      'letters_map' : letters_counter,
      'words_points' : wordsPoints,
      'words' : final_words,
    });
  }

  static Map<String, int> detectHowManyEachLettersKeyboardNedded(List<String> randomLetters, List<String> final_words) {
    Map<String, int> letters_counter = {};
    for (String s in randomLetters){
      if (letters_counter[s] != null){

      }else{
        letters_counter[s] = 0;
      }
    }
    for (String word in final_words){
      Map<String, int> counter = {};
      var word_letters = word.split('');
      for (String s in word_letters){
        if (counter[s] != null){
          counter[s] = (counter[s] ?? 0) + 1;
          if ((counter[s] ?? 0 ) > (letters_counter[s] ?? 0)){
            letters_counter[s] = counter[s] ?? 0;
          }
        }else{
          counter[s] = 1;
          if ((counter[s] ?? 0 ) > (letters_counter[s] ?? 0)){
            letters_counter[s] = counter[s] ?? 0;
          }
        }
      }
    }
    return letters_counter;
  }

  static void setWordPointsInMatrix(Map<String, List<MatrixPoint>> wordsPoints, int offsetX, int offsetY) {

    wordsPoints.forEach((key, List<MatrixPoint> value) {
      for (MatrixPoint point in value){
        point.x = point.x + offsetX;
        point.y = point.y + offsetY;
      }
    });
  }

  static List<List<String>> matrixGenerate(List<String> words, List<String> final_words, Map<String, List<MatrixPoint>> wordsPoints) {

    int longestLength = words.map((word) => word.length).reduce((value, element) => value > element ? value : element);

    List<List<String>> matrix = List.generate(13, (_) => List<String>.filled(13, '0'));

    int index = words.indexWhere((element) => element.length == longestLength);

    List<String> letters = words[index].toLowerCase().split('');

    final_words.add(words[index].toLowerCase());

    int o = 0;
    List<MatrixPoint> matrixList = [];

    if (o-1 > 0) {
      matrix[longestLength][o - 1] = '-';
    }


      for (int i = 0; i < letters.length; i++) {
        matrix[longestLength - 1][o] = '.';
        matrix[longestLength][o] = letters[i];
        matrixList.add(MatrixPoint(x: longestLength, y: o, value: letters[i]));
        matrix[longestLength + 1][o] = '.';
        o += 1;
      }

    if (o < matrix.length)
      matrix[longestLength][o] = '-';

    wordsPoints[words[index].toLowerCase()] = matrixList;

    words.removeAt(index);

    for (int i = 0; i < 6; i ++) {
      words.shuffle();

        lookingForPlace(matrix, 'vertical', words, final_words, wordsPoints);

        lookingForPlace(matrix, 'horizontal',  words, final_words, wordsPoints);

    }

    int listIndex = 0;
    bool isRowEmpty = true;
    List<List<String>> removeIndexes = [];

    print(final_words);

    for (List<String> list in matrix) {
      isRowEmpty = true;
      for (String s in list) {
        if (s != '0' && s != '.' && s != ':' && s != '-')
          isRowEmpty = false;
      }
      if (isRowEmpty){
        removeIndexes.add(list);
      }
      listIndex++;
    }
    return matrix;
  }

  static void setupWordsList(List<String> allWords, List<String> wordsFromLetters, List<String> randomLetters, List<String> words) {
     // Преобразуем список слов в множество для более эффективного поиска
    Set<String> wordSet = allWords.toSet();

    // Находим все слова, которые можно составить из выбранных букв
    wordsFromLetters = wordSet.where((word) => word.split('').every((letter) => randomLetters.contains(letter.toLowerCase()))).toList();



    while (wordsFromLetters.length < 10){

        _setupWordsListFromRandomLetters(allWords, wordSet, wordsFromLetters, randomLetters);
    }

    words.addAll(wordsFromLetters.toList());
  }

  static void lookingForRandomLetters(List<String> allWords, List<String> randomLetters) {
    Random random = Random();
    randomLetters.addAll(allWords[random.nextInt(allWords.length)].split(''));
    if (randomLetters.length < 4){
      var word = allWords[random.nextInt(allWords.length)].split('');
      for (int i = randomLetters.length; i < 4; i++){
        int index = random.nextInt(word.length);
        randomLetters.add(word[index]);
        word.removeAt(index);
      }
    }
  }

  static int findEmptyRows(List<List<String>> matrix) {
    int offsetX = 0;
    int emptyRowsBeforeLetters = 0;
    int emptyRowsAfterLetters = 0;
    for (List<String> list in matrix){
      bool isRowEmpty = true;
      for (String s in list) {
        if (s != '0' && s != '.' && s != ':' && s != '-')
          isRowEmpty = false;
      }
      if (isRowEmpty){
        emptyRowsBeforeLetters += 1;
      }else{
        break;
      }
    }

    for (int i = matrix.length - 1; i >= 0; i --){
      bool isRowEmpty = true;
      for (String s in matrix[i]) {
        if (s != '0' && s != '.' && s != ':' && s != '-')
          isRowEmpty = false;
      }
      if (isRowEmpty){
        emptyRowsAfterLetters += 1;
      }else{
        break;
      }
    }

    if (emptyRowsBeforeLetters > emptyRowsAfterLetters) {
      int finalCount = emptyRowsBeforeLetters -
          ((emptyRowsAfterLetters + emptyRowsBeforeLetters) ~/ 2);
      offsetX = -finalCount;

      for (int index = 0; index < finalCount; index ++){
        final first = matrix[0];
        matrix.removeAt(0);
        matrix.add(first);
      }
    }else if (emptyRowsBeforeLetters < emptyRowsAfterLetters) {

      int finalCount = emptyRowsAfterLetters -
          ((emptyRowsAfterLetters + emptyRowsBeforeLetters) ~/ 2);
      offsetX = finalCount;
      for (int index = 0; index < finalCount; index ++){
        final last = matrix.removeLast();
        matrix.insert(0, last);
      }

    }


    return offsetX;
  }


  static void _setupWordsListFromRandomLetters(List<String> allWords, Set<String> wordSet, List<String> wordsFromLetters, List<String> randomLetters) {
    lookingForRandomLetters(allWords, randomLetters);

    wordsFromLetters.addAll(wordSet.where((word) => word.split('').every((letter) => randomLetters.contains(letter.toLowerCase()))).toList());

  }

  static int findEmptyColumns(List<List<String>> matrix){
    int offsetY = 0;
    int emptyColumnsBeforeLetters = 0;
    int emptyColumnsAfterLetters = 0;

    for (int col = 0; col < matrix[0].length; col++) {
      bool isEmpty = true;
      for (int row = 0; row < matrix.length; row++) {
        if (matrix[row][col] != '0' && matrix[row][col] != '.' && matrix[row][col] != ':' && matrix[row][col] != '-') {
          isEmpty = false;
          break;
        }
      }

      if (isEmpty) {
        emptyColumnsBeforeLetters += 1;
      }else{
        break;
      }
    }

    for (int col = matrix[0].length - 1; col >= 0; col--) {
      bool isEmpty = true;
      for (int row = 0; row < matrix.length; row++) {
        if (matrix[row][col] != '0' && matrix[row][col] != '.' && matrix[row][col] != ':' && matrix[row][col] != '-') {
          isEmpty = false;
          break;
        }
      }

      if (isEmpty) {
        emptyColumnsAfterLetters += 1;
      }else{
        break;
      }
    }


    if (emptyColumnsBeforeLetters > emptyColumnsAfterLetters){
      int finalCount = emptyColumnsBeforeLetters - ((emptyColumnsAfterLetters + emptyColumnsBeforeLetters) ~/ 2);
      offsetY = -finalCount;
      for (int index = 0; index < finalCount; index ++){

        // Сдвиг влево
        for (var i = 0; i < matrix.length; i++) {
          final firstElement = matrix[i][0]; // Получаем первый элемент
          for (var j = 0; j < matrix[i].length - 1; j++) {
            matrix[i][j] = matrix[i][j + 1]; // Сдвигаем элементы влево
          }
          matrix[i][matrix[i].length - 1] = firstElement; // Добавляем первый элемент в конец
        }
      }
    }else if (emptyColumnsBeforeLetters < emptyColumnsAfterLetters){

      int finalCount = emptyColumnsAfterLetters - ((emptyColumnsBeforeLetters + emptyColumnsAfterLetters) ~/ 2);
      offsetY = finalCount;
      for (int index = 0; index < finalCount; index ++){
        // Сдвиг вправо
        for (var i = 0; i < matrix.length; i++) {
          final lastElement = matrix[i][matrix[i].length - 1]; // Получаем последний элемент
          for (var j = matrix[i].length - 1; j > 0; j--) {
            matrix[i][j] = matrix[i][j - 1]; // Сдвигаем элементы вправо
          }
          matrix[i][0] = lastElement; // Добавляем последний элемент в начало
        }

      }
    }
    return offsetY;
  }

  static void lookingForPlace(List<List<String>> matrix, String orientation, List<String> words, List<String> final_words, Map<String, List<MatrixPoint>> wordsPoints) {

    if (orientation == 'vertical'){

      for (int i = 0; i < matrix.length; i++){
        for (int j = 0; j < matrix.length; j++){

          if (matrix[j][i] != '0' && matrix[j][i] != '.' && matrix[j][i] != ':' && matrix[j][i] != '-') {

            List<String>? wordsString;

            if (words.any((element) => element.contains(matrix[j][i]))) {
              wordsString = words.where(
                    (element) => element.toLowerCase().contains(matrix[j][i]),
              ).toList();
            } else {
              wordsString = null;
            }
            if (wordsString != null) {

              for (int index = 0; index < wordsString.length; index ++){
                String wordString = wordsString[index];

                List<String> word = wordString.toLowerCase().split('');

                int letterIndex = word.indexWhere((element) =>
                element == matrix[j][i]);
                bool isGood = true;
                int li = 0;

                if (j - letterIndex < 0){
                  continue;
                }else {
                  if (matrix.length < (j - letterIndex + word.length)) {
                    continue;
                  } else {
                    int count = 0;
                    for (int k = j - letterIndex; k <
                        (j - letterIndex + word.length); k++) {


                      if (matrix[k][i] != '0') {
                        if (matrix[k][i] == '.' || matrix[k][i] == ':') {
                          count += 1;
                        } else {
                          if (matrix[k][i] != word[li] || matrix[k][i] == '-')
                            isGood = false;
                        }
                      }

                      li += 1;
                    }
                    if (count > 1) {
                      isGood = false;
                    }


                    if (j - letterIndex + word.length < matrix.length) {
                      if (matrix[j - letterIndex + word.length ][i] != '0' &&
                          matrix[j - letterIndex + word.length ][i] != '.' &&
                          matrix[j - letterIndex + word.length ][i] != ':') {
                        isGood = false;
                      }
                    }


                    if (isGood) {

                      List<MatrixPoint> matrixList = [];
                      int li = 0;
                      if (j - letterIndex > 0) {
                        if (matrix[j - letterIndex - 1][i] == '0' ||
                            matrix[j - letterIndex - 1][i] == '.' ||
                            matrix[j - letterIndex - 1][i] == ':')
                          matrix[j - letterIndex - 1][i] = '-';
                      }
                      for (int k = j - letterIndex; k <
                          (j - letterIndex + word.length); k++) {
                        matrix[k][i] = word[li];
                        matrixList.add(MatrixPoint(x: k, y: i, value: word[li]));
                        if (i > 0) {
                          if (matrix[k][i - 1] == '0') {
                            matrix[k][i - 1] = '.';
                          } else if (matrix[k][i - 1] == '.') {
                            matrix[k][i - 1] = ':';
                          } else if (matrix[k][i - 1] == ':') {
                            matrix[k][i - 1] = '-';
                          }
                        }

                        if (i + 1 < matrix.length) {
                          if (matrix[k][i + 1] == '0') {
                            matrix[k][i + 1] = '.';
                          } else if (matrix[k][i + 1] == '.') {
                            matrix[k][i + 1] = ':';
                          } else if (matrix[k][i + 1] == ':') {
                            matrix[k][i + 1] = '-';
                          }
                        }
                        li += 1;
                      }

                      if (j - letterIndex + word.length < matrix.length) {
                        if (matrix[j - letterIndex + word.length][i] == '0' ||
                            matrix[j - letterIndex + word.length][i] == '.' ||
                            matrix[j - letterIndex + word.length][i] == ':')
                          matrix[j - letterIndex + word.length][i] = '-';
                      }


                      final_words.add(wordString);
                      wordsPoints[wordString] = matrixList;
                      words.remove(wordString);
                      return;
                    }
                  }
                }
              }

            }else{

            }
          }
        }
      }
    }else if (orientation == 'horizontal'){
      for (int i = 0; i < matrix.length; i++){
        for (int j = 0; j < matrix.length; j++){

          if (matrix[j][i] != '0' && matrix[j][i] != '.' && matrix[j][i] != ':' && matrix[j][i] != '-') {
            List<String>? wordsString;
            if (words.any((element) => element.contains(matrix[i][j]))) {
              wordsString = words.where(
                    (element) => element.toLowerCase().contains(matrix[i][j]),
              ).toList();
            } else {
              wordsString = null;
            }
            if (wordsString != null) {

              for (int index = 0; index < wordsString.length; index ++){
                String wordString = wordsString[index];
                List<String> word = wordString.toLowerCase().split('');

                int letterIndex = word.indexWhere((element) =>
                element == matrix[i][j]);
                bool isGood = true;
                int li = 0;

                if (j - letterIndex < 0){
                  continue;
                }else {
                  if (matrix.length < (j - letterIndex + word.length)) {
                    continue;
                  } else {
                    int count = 0;
                    for (int k = j - letterIndex; k <
                        (j - letterIndex + word.length); k++) {
                      if (matrix[i][k] != '0') {
                        if (matrix[i][k] == '.' || matrix[i][k] == ':') {
                          count += 1;
                        } else {
                          if (matrix[i][k] != word[li] || matrix[i][k] == '-')
                            isGood = false;
                        }
                      }

                      li += 1;
                    }

                    if (count > 3) {
                      isGood = false;
                    }

                    if (j - letterIndex + word.length < matrix.length) {
                      if (matrix[i][j - letterIndex + word.length ] != '0' &&
                          matrix[i][j - letterIndex + word.length ] != '.' &&
                          matrix[i][j - letterIndex + word.length ] != ':') {
                        isGood = false;
                      }
                    }

                    if (j - letterIndex - 1 >= 0) {
                      if (matrix[i][j - letterIndex - 1] != '0') {
                        isGood = false;
                      }
                    }

                    if (isGood) {

                      List<MatrixPoint> matrixList = [];
                      if (j - letterIndex > 0) {
                        if (matrix[i][j - letterIndex - 1] == '0' ||
                            matrix[i][j - letterIndex - 1] == '.' ||
                            matrix[i][j - letterIndex - 1] == ':')
                          matrix[i][j - letterIndex - 1] = '-';
                      }

                      int li = 0;
                      for (int k = j - letterIndex; k <
                          j - letterIndex + word.length; k++) {
                        matrix[i][k] = word[li];
                        matrixList.add(MatrixPoint(x: i, y: k, value: word[li]));

                        if (i > 0) {
                          if (matrix[i - 1][k] == '0') {
                            matrix[i - 1][k] = '.';
                          } else if (matrix[i - 1][k] == '.') {
                            matrix[i - 1][k] = ':';
                          } else if (matrix[i - 1][k] == ':') {
                            matrix[i - 1][k] = '-';
                          }
                        }

                        if (i + 1 < matrix.length) {
                          if (matrix[i + 1][k] == '0') {
                            matrix[i + 1][k] = '.';
                          } else if (matrix[i + 1][k] == '.') {
                            matrix[i + 1][k] = ':';
                          } else if (matrix[i + 1][k] == ':') {
                            matrix[i + 1][k] = '-';
                          }
                        }

                        li += 1;
                      }

                      if (j - letterIndex + word.length < matrix.length) {
                        if (matrix[i][j - letterIndex + word.length] == '0' ||
                            matrix[i][j - letterIndex + word.length] == '.' ||
                            matrix[i][j - letterIndex + word.length] == ':')
                          matrix[i][j - letterIndex + word.length] = '-';
                      }


                      final_words.add(wordString);
                      wordsPoints[wordString] = matrixList;

                      words.remove(wordString);
                      return;
                    }
                  }
                }
              }

            }else{

            }
          }
        }
      }
    }
  }


}