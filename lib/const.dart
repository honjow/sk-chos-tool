import 'package:flutter/material.dart';

const kFontFamilyFallback = [
  // 'Microsoft YaHei',
  // 'SimHei',
  // 'SimSun',
  '',
];

final ButtonStyle buttonStyle = ButtonStyle(
  shape: WidgetStateProperty.all(
    RoundedRectangleBorder(
      side: const BorderSide(
        width: 1.5,
        color: Colors.blueGrey,
      ),
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  padding: WidgetStateProperty.all(
      const EdgeInsets.symmetric(vertical: 14, horizontal: 8)),
);
