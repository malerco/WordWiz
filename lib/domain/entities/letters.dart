import 'package:flutter/material.dart';

class Letters{
  String value;
  bool visible;
  Color color = Colors.white;

  Letters({required this.value, required this.visible});

  Map<String, dynamic> toJson(){
    return {
      'value' : value,
      'visible' : visible,
    };
  }

  factory Letters.fromJson(Map<String,dynamic> json){
    return Letters(value: json['value'] as String, visible: json['visible'] as bool);
  }
}