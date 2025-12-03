import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Single task log information
class TaskLog {
  final String taskId;
  final String taskName;
  final RxList<String> logs = <String>[].obs;
  final RxBool isRunning = true.obs;
  final RxBool hasError = false.obs;
  double scrollPosition = 0.0; // 保存滚动位置

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
  late PageController pageController;

  // 高度限制
  static const double minHeight = 100.0;
  static const double maxHeight = 600.0;
  static const double collapsedHeight = 40.0;

  @override
  void onInit() {
    super.onInit();
    _initPageController();

    // 监听展开状态，展开时同步页面
    ever(isExpanded, (expanded) {
      if (expanded && pageController.hasClients) {
        final index = tasks.indexWhere((t) => t.taskId == currentTaskId.value);
        if (index >= 0 && pageController.page?.round() != index) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (pageController.hasClients) {
              pageController.jumpToPage(index);
            }
          });
        }
      }
    });
  }

  void _initPageController() {
    final index = tasks.indexWhere((t) => t.taskId == currentTaskId.value);
    pageController = PageController(initialPage: index >= 0 ? index : 0);
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

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

    // 跳转到新任务页面
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pageController.hasClients) {
        pageController.jumpToPage(tasks.length - 1);
      }
    });

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
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index < 0) return;

    final wasCurrentTask = currentTaskId.value == taskId;
    tasks.removeAt(index);

    if (tasks.isEmpty) {
      isExpanded.value = false;
    } else if (wasCurrentTask) {
      // 如果删除的是当前任务，切换到邻近任务
      final newIndex = index >= tasks.length ? tasks.length - 1 : index;
      currentTaskId.value = tasks[newIndex].taskId;
      // 等待PageView更新后再跳转
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients && tasks.isNotEmpty) {
          pageController.jumpToPage(newIndex);
        }
      });
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
    final index = tasks.indexWhere((t) => t.taskId == taskId);
    if (index >= 0) {
      currentTaskId.value = taskId;
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }
    }
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
