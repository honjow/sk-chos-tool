import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

/// Window state persistence manager
class WindowStateManager {
  static const String _keyX = 'window_x';
  static const String _keyY = 'window_y';
  static const String _keyWidth = 'window_width';
  static const String _keyHeight = 'window_height';
  static const String _keyMaximized = 'window_maximized';

  /// Save current window state
  static Future<void> saveWindowState() async {
    final prefs = await SharedPreferences.getInstance();
    final position = appWindow.position;
    final size = appWindow.size;

    await prefs.setDouble(_keyX, position.dx);
    await prefs.setDouble(_keyY, position.dy);
    await prefs.setDouble(_keyWidth, size.width);
    await prefs.setDouble(_keyHeight, size.height);
    await prefs.setBool(_keyMaximized, appWindow.isMaximized);
  }

  /// Restore window state
  static Future<void> restoreWindowState() async {
    final prefs = await SharedPreferences.getInstance();

    // Default values
    const defaultWidth = 1024.0;
    const defaultHeight = 576.0;
    const minWidth = 800.0;
    const minHeight = 400.0;

    // Get saved values
    final x = prefs.getDouble(_keyX);
    final y = prefs.getDouble(_keyY);
    final width = prefs.getDouble(_keyWidth) ?? defaultWidth;
    final height = prefs.getDouble(_keyHeight) ?? defaultHeight;
    final wasMaximized = prefs.getBool(_keyMaximized) ?? false;

    // Set minimum size
    appWindow.minSize = const Size(minWidth, minHeight);

    // Restore size
    appWindow.size = Size(width, height);

    // Restore position if saved
    if (x != null && y != null) {
      appWindow.position = Offset(x, y);
    } else {
      // Center window if no saved position
      appWindow.alignment = Alignment.center;
    }

    // Restore maximized state
    if (wasMaximized) {
      appWindow.maximize();
    }

    appWindow.show();
  }
}
