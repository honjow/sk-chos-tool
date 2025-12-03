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
  final panelHeight = 250.0.obs; // 添加可调节高度
  final isDragging = false.obs; // 拖动状态
  final userInteracted = false.obs; // 用户交互标记

  // 高度限制
  static const double minHeight = 100.0;
  static const double maxHeight = 600.0;
  static const double collapsedHeight = 40.0;

  /// Start a new task and return the task object
  TaskLog startTask(String taskName) {
    final task = TaskLog(
      taskId: DateTime.now().millisecondsSinceEpoch.toString(),
      taskName: taskName,
    );
    tasks.add(task);
    currentTaskId.value = task.taskId;
    isExpanded.value = true; // Auto expand
    userInteracted.value = false; // 重置用户交互标记
    return task;
  }

  /// Complete a task and auto-collapse after 3 seconds
  void completeTask(String taskId, {bool hasError = false}) {
    final task = tasks.firstWhereOrNull((t) => t.taskId == taskId);
    if (task != null) {
      task.isRunning.value = false;
      task.hasError.value = hasError;

      // Auto-collapse after 3 seconds if no tasks are running AND user hasn't interacted
      Future.delayed(const Duration(seconds: 3), () {
        final hasRunningTasks = tasks.any((t) => t.isRunning.value);
        // 只有在没有运行任务且用户未交互时才自动关闭
        if (!hasRunningTasks && !userInteracted.value) {
          isExpanded.value = false;
        }
      });
    }
  }

  /// Remove a task from the list
  void removeTask(String taskId) {
    userInteracted.value = true; // 标记用户交互
    tasks.removeWhere((t) => t.taskId == taskId);
    if (tasks.isEmpty) {
      isExpanded.value = false;
    } else if (currentTaskId.value == taskId && tasks.isNotEmpty) {
      currentTaskId.value = tasks.first.taskId;
    }
  }

  /// Clear all tasks
  void clearAll() {
    userInteracted.value = true; // 标记用户交互
    tasks.clear();
    isExpanded.value = false;
  }

  /// Switch to a task (called when clicking tab)
  void switchToTask(String taskId) {
    userInteracted.value = true; // 切换tab算用户交互
    currentTaskId.value = taskId;
  }

  /// Update panel height (called during drag)
  void updateHeight(double delta) {
    final newHeight = panelHeight.value - delta; // 减去delta因为是向上拖动
    panelHeight.value = newHeight.clamp(minHeight, maxHeight);
  }

  /// Start dragging
  void startDrag() {
    isDragging.value = true;
    userInteracted.value = true; // 拖动也算用户交互
  }

  /// End dragging
  void endDrag() {
    isDragging.value = false;
  }
}
