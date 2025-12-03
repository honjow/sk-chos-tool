import 'dart:async';
import 'package:window_manager/window_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:sk_chos_tool/utils/log.dart';

/// Window state persistence manager
class WindowStateManager {
  static const String _keyX = 'window_x';
  static const String _keyY = 'window_y';
  static const String _keyWidth = 'window_width';
  static const String _keyHeight = 'window_height';
  static const String _keyMaximized = 'window_maximized';

  static Timer? _debounceTimer;

  /// Save window state immediately
  static Future<void> saveWindowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final position = await windowManager.getPosition();
      final size = await windowManager.getSize();
      final isMaximized = await windowManager.isMaximized();

      await prefs.setDouble(_keyX, position.dx);
      await prefs.setDouble(_keyY, position.dy);
      await prefs.setDouble(_keyWidth, size.width);
      await prefs.setDouble(_keyHeight, size.height);
      await prefs.setBool(_keyMaximized, isMaximized);

      // 强制提交
      await prefs.reload();

      logger.d(
          'Window state saved: ${size.width}x${size.height}, maximized: $isMaximized');
    } catch (e) {
      logger.e('Failed to save window state: $e');
    }
  }

  /// Schedule a save with debounce (for frequent events like resize/move)
  static void scheduleSave() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      saveWindowState();
    });
  }

  /// Restore window state
  static Future<void> restoreWindowState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Default values
      const defaultWidth = 800.0;
      const defaultHeight = 550.0;

      // Get saved values
      final x = prefs.getDouble(_keyX);
      final y = prefs.getDouble(_keyY);
      final width = prefs.getDouble(_keyWidth) ?? defaultWidth;
      final height = prefs.getDouble(_keyHeight) ?? defaultHeight;
      final wasMaximized = prefs.getBool(_keyMaximized) ?? false;

      logger.i(
          'Restoring window state: ${width}x$height, maximized: $wasMaximized');

      // Restore size
      await windowManager.setSize(Size(width, height));

      // Restore position if saved
      if (x != null && y != null) {
        await windowManager.setPosition(Offset(x, y));
      } else {
        // Center window if no saved position
        await windowManager.center();
      }

      // Restore maximized state
      if (wasMaximized) {
        await windowManager.maximize();
      }
    } catch (e) {
      logger.e('Failed to restore window state: $e');
      // Fallback to defaults - center the window
      await windowManager.center();
    }
  }

  /// Dispose resources
  static void dispose() {
    _debounceTimer?.cancel();
  }
}
