import 'dart:async';
import 'package:bitsdojo_window/bitsdojo_window.dart';
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
      final position = appWindow.position;
      final size = appWindow.size;
      final isMaximized = appWindow.isMaximized;

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

      logger.i(
          'Restoring window state: ${width}x$height, maximized: $wasMaximized');

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

      // Show window
      appWindow.show();

      // Restore maximized state with delay
      if (wasMaximized) {
        Future.delayed(const Duration(milliseconds: 100), () {
          appWindow.maximize();
        });
      }
    } catch (e) {
      logger.e('Failed to restore window state: $e');
      // Fallback to defaults
      appWindow.minSize = const Size(800, 400);
      appWindow.size = const Size(1024, 576);
      appWindow.alignment = Alignment.center;
      appWindow.show();
    }
  }

  /// Dispose resources
  static void dispose() {
    _debounceTimer?.cancel();
  }
}
