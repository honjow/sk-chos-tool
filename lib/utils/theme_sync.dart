import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sk_chos_tool/utils/log.dart';

/// Syncs Flutter theme colors with native header bar
class ThemeSync {
  static const MethodChannel _channel = MethodChannel('sk_chos_tool/theme');

  /// Notify native side that Flutter is ready
  static Future<void> notifyFlutterReady() async {
    try {
      await _channel.invokeMethod('flutterReady');
    } catch (e) {
      logger.w('Failed to notify Flutter ready: $e');
    }
  }

  /// Update native header bar color based on Flutter theme
  static Future<void> updateHeaderBarColor(BuildContext context) async {
    try {
      final theme = Theme.of(context);
      final backgroundColor = theme.scaffoldBackgroundColor;

      // Convert Color to RGBA values
      final r = backgroundColor.red;
      final g = backgroundColor.green;
      final b = backgroundColor.blue;
      final a = backgroundColor.alpha;

      // Send to native side
      await _channel.invokeMethod('updateHeaderBarColor', {
        'r': r,
        'g': g,
        'b': b,
        'a': a,
      });

      logger.d('Updated header bar color: rgba($r, $g, $b, $a)');
    } catch (e) {
      logger.w('Failed to update header bar color: $e');
    }
  }
}
