import 'package:flutter/material.dart';

const kFontFamilyFallback = [
  // 'Microsoft YaHei',
  // 'SimHei',
  // 'SimSun',
  '',
];

/// Button style with border for general use
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

/// Elevated button style with rounded corners for action buttons
const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 18);
final elevatedButtonStyle = ElevatedButton.styleFrom(
  padding: buttonPadding,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),
  ),
);
