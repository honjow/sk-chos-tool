import 'package:flutter/material.dart';

const kFontFamilyFallback = [
  // 'Microsoft YaHei',
  // 'SimHei',
  // 'SimSun',
  '',
];

// ==================== Text Styles ====================

/// Text styles used throughout the app
class AppTextStyles {
  /// Title style for item widgets (16px, semi-bold)
  static const itemTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// Description style for item widgets (12px, grey)
  static const itemDescription = TextStyle(
    fontSize: 12,
    color: Colors.grey,
  );

  /// Menu title style (24px, normal weight)
  static const menuTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.normal,
    fontFamilyFallback: kFontFamilyFallback,
  );
}

// ==================== Padding Constants ====================

/// Padding constants used throughout the app
class AppPadding {
  /// Standard padding for item widgets (vertical: 16, horizontal: 20)
  static const itemPadding = EdgeInsets.symmetric(vertical: 16, horizontal: 20);

  /// Small padding (all: 8)
  static const smallPadding = EdgeInsets.all(8.0);

  /// Padding for action button items (vertical: 12, horizontal: 20)
  static const actionItemPadding =
      EdgeInsets.symmetric(vertical: 12, horizontal: 20);

  /// Padding for elevated buttons (horizontal: 20, vertical: 18)
  static const buttonPadding =
      EdgeInsets.symmetric(horizontal: 20, vertical: 18);
}

// ==================== Size Constants ====================

/// Size constants used throughout the app
class AppSizes {
  /// Size for loading indicator
  static const loadingIndicatorSize = 24.0;

  /// Width of the menu sidebar
  static const menuWidth = 240.0;
}

// ==================== Button Styles ====================

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
final elevatedButtonStyle = ElevatedButton.styleFrom(
  padding: AppPadding.buttonPadding,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),
  ),
);
