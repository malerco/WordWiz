
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;


abstract class StorageDataProvider{
  Future<List<String>> readFile(String filePath);
}

class DefaultStorageDataProvider implements StorageDataProvider{
  @override
  Future<List<String>> readFile(String filePath) async {
    try {
      String content = await rootBundle.loadString(filePath);

      List<String> lines = LineSplitter.split(content).toList();

      return lines;
    } catch (e) {

      return [];
    }
  }
}