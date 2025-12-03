import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Helper class for showing consistent snackbars across the app
class SnackbarHelper {
  /// Show success snackbar with green check icon
  static void showSuccess(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor:
            Get.theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
        icon: const Icon(Icons.check, color: Colors.green),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show error snackbar with red error icon
  static void showError(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: Colors.red.withValues(alpha: 0.9),
        icon: const Icon(Icons.error, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show info snackbar with blue info icon
  static void showInfo(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor:
            Get.theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
        icon: const Icon(Icons.info, color: Colors.blue),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Show warning snackbar with orange warning icon
  static void showWarning(String title, String message) {
    Get.showSnackbar(
      GetSnackBar(
        title: title,
        message: message,
        backgroundColor: Colors.orange.withValues(alpha: 0.9),
        icon: const Icon(Icons.warning, color: Colors.white),
        snackPosition: SnackPosition.BOTTOM,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
