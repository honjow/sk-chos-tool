import 'dart:convert';
import 'dart:io';

import 'package:get/get.dart';
import 'package:process_run/process_run.dart';
import 'package:sk_chos_tool/controller/log_controller.dart';

/// Execute command with real-time log capture
///
/// If LogController is not registered, falls back to regular run() without logging
Future<void> runWithLog({
  required String command,
  required String taskName,
  bool runInShell = true,
  bool verbose = false,
}) async {
  // Fallback to regular run if LogController is not available
  if (!Get.isRegistered<LogController>()) {
    final results = await run(
      command,
      verbose: verbose,
      runInShell: runInShell,
    );
    if (results.isNotEmpty && results.first.exitCode != 0) {
      throw Exception(
        'Command failed with exit code ${results.first.exitCode}: $command',
      );
    }
    return;
  }

  final logController = Get.find<LogController>();
  final task = logController.startTask(taskName);

  try {
    // Start process
    final process = await Process.start(
      'bash',
      ['-c', command],
      runInShell: runInShell,
    );

    // Capture stdout
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        task.addLog(line);
      },
    );

    // Capture stderr
    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(
      (line) {
        task.addLog('[ERROR] $line');
      },
    );

    // Wait for process to complete
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      task.addLog('Process exited with code $exitCode');
      logController.completeTask(task.taskId, hasError: true);
      throw Exception('Command failed with exit code $exitCode: $command');
    }

    task.addLog('✓ Completed successfully');
    logController.completeTask(task.taskId);
  } catch (e) {
    task.addLog('✗ Error: $e');
    logController.completeTask(task.taskId, hasError: true);
    rethrow;
  }
}
