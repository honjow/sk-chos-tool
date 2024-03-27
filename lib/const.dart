import 'package:flutter/material.dart';

const kFontFamilyFallback = [
  'Microsoft YaHei',
  'SimHei',
  'SimSun',
];

final ButtonStyle buttonStyle = ButtonStyle(
  shape: MaterialStateProperty.all(
    RoundedRectangleBorder(
      side: const BorderSide(
        width: 1.5,
        color: Colors.blueGrey,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(vertical: 14, horizontal: 8)),
);
