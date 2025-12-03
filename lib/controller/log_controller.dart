import 'package:get/get.dart';

/// Single task log information
class TaskLog {
  final String taskId;
  final String taskName;
  final RxList<String> logs = <String>[].obs;
  final RxBool isRunning = true.obs;
  final RxBool hasError = false.obs;

  TaskLog({
    required this.taskId,
    required this.taskName,
  });

  /// Add a log line, limit to 1000 lines
  void addLog(String line) {
    logs.add(line);
    if (logs.length > 1000) {
      logs.removeAt(0);
    }
  }
}

/// Controller for managing task logs
class LogController extends GetxController {
  final tasks = <TaskLog>[].obs;
  final currentTaskId = ''.obs;
  final isExpanded = false.obs;

  /// Start a new task and return the task object
  TaskLog startTask(String taskName) {
    final task = TaskLog(
      taskId: DateTime.now().millisecondsSinceEpoch.toString(),
      taskName: taskName,
    );
    tasks.add(task);
    currentTaskId.value = task.taskId;
    isExpanded.value = true; // Auto expand
    return task;
  }

  /// Complete a task and auto-collapse after 3 seconds
  void completeTask(String taskId, {bool hasError = false}) {
    final task = tasks.firstWhereOrNull((t) => t.taskId == taskId);
    if (task != null) {
      task.isRunning.value = false;
      task.hasError.value = hasError;

      // Auto-collapse after 3 seconds if no tasks are running
      Future.delayed(const Duration(seconds: 3), () {
        final hasRunningTasks = tasks.any((t) => t.isRunning.value);
        if (!hasRunningTasks) {
          isExpanded.value = false;
        }
      });
    }
  }

  /// Remove a task from the list
  void removeTask(String taskId) {
    tasks.removeWhere((t) => t.taskId == taskId);
    if (tasks.isEmpty) {
      isExpanded.value = false;
    } else if (currentTaskId.value == taskId && tasks.isNotEmpty) {
      currentTaskId.value = tasks.first.taskId;
    }
  }

  /// Clear all tasks
  void clearAll() {
    tasks.clear();
    isExpanded.value = false;
  }
}
