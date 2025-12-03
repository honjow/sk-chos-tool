import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sk_chos_tool/controller/log_controller.dart';

/// Log panel component that displays task execution logs
///
/// Shows at the bottom of the main page:
/// - Height 0 when no tasks
/// - Height 40px when collapsed (shows task summary)
/// - Height 250px when expanded (shows detailed logs)
class LogPanel extends StatelessWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LogController>();

    return Obx(() {
      if (controller.tasks.isEmpty) {
        return const SizedBox.shrink(); // Height 0 when no tasks
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: controller.isExpanded.value ? 250 : 40,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey.shade700)),
          color: Colors.black87,
        ),
        child: controller.isExpanded.value
            ? _buildExpanded(controller)
            : _buildCollapsed(controller),
      );
    });
  }

  /// Build collapsed view (40px height)
  Widget _buildCollapsed(LogController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Obx(() {
            final runningCount =
                controller.tasks.where((t) => t.isRunning.value).length;
            return Row(
              children: [
                if (runningCount > 0) ...[
                  const SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$runningCount个任务运行中',
                    style: const TextStyle(color: Colors.white),
                  ),
                ] else ...[
                  const Icon(Icons.check, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  const Text(
                    '任务完成',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ],
            );
          }),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.expand_less, color: Colors.white),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => controller.isExpanded.value = true,
          ),
        ],
      ),
    );
  }

  /// Build expanded view (250px height)
  Widget _buildExpanded(LogController controller) {
    return Column(
      children: [
        _buildHeader(controller),
        _buildTabs(controller),
        Expanded(child: _buildLogContent(controller)),
      ],
    );
  }

  /// Build header with title and controls
  Widget _buildHeader(LogController controller) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.terminal, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          const Text(
            '任务日志',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final runningCount =
                controller.tasks.where((t) => t.isRunning.value).length;
            if (runningCount > 0) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$runningCount 运行中',
                  style: const TextStyle(fontSize: 11, color: Colors.white),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.clear_all, color: Colors.grey),
            iconSize: 18,
            tooltip: '清空所有',
            onPressed: () => controller.clearAll(),
          ),
          IconButton(
            icon: const Icon(Icons.expand_more, color: Colors.white),
            iconSize: 20,
            tooltip: '收起',
            onPressed: () => controller.isExpanded.value = false,
          ),
        ],
      ),
    );
  }

  /// Build task tabs for switching between tasks
  Widget _buildTabs(LogController controller) {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800),
        ),
      ),
      child: Obx(() => ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: controller.tasks.length,
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return Obx(() {
                final isActive = task.taskId == controller.currentTaskId.value;
                return InkWell(
                  onTap: () => controller.currentTaskId.value = task.taskId,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? Colors.grey[800] : Colors.transparent,
                      border: isActive
                          ? const Border(
                              bottom: BorderSide(color: Colors.blue, width: 2),
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.isRunning.value)
                          const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          Icon(
                            task.hasError.value ? Icons.error : Icons.check,
                            color:
                                task.hasError.value ? Colors.red : Colors.green,
                            size: 12,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          task.taskName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => controller.removeTask(task.taskId),
                          child: const Icon(
                            Icons.close,
                            color: Colors.grey,
                            size: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          )),
    );
  }

  /// Build log content area
  Widget _buildLogContent(LogController controller) {
    return Obx(() {
      final task = controller.tasks.firstWhereOrNull(
        (t) => t.taskId == controller.currentTaskId.value,
      );

      if (task == null) {
        return const Center(
          child: Text(
            '无日志',
            style: TextStyle(color: Colors.grey),
          ),
        );
      }

      return Container(
        color: Colors.black,
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          if (task.logs.isEmpty) {
            return const Center(
              child: Text(
                '等待输出...',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: task.logs.length,
            itemBuilder: (context, index) {
              final line = task.logs[index];
              final isError = line.contains('[ERROR]');
              return SelectableText(
                line,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 12,
                  color: isError ? Colors.red : Colors.green[300],
                  height: 1.4,
                ),
              );
            },
          );
        }),
      );
    });
  }
}
