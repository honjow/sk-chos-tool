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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.tasks.isEmpty) {
        return const SizedBox.shrink(); // Height 0 when no tasks
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: controller.isExpanded.value ? 250 : 40,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
          color: colorScheme.surface,
          // 顶部圆角
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
        child: controller.isExpanded.value
            ? _buildExpanded(controller, theme, colorScheme)
            : _buildCollapsed(controller, theme, colorScheme),
      );
    });
  }

  /// Build collapsed view (40px height)
  Widget _buildCollapsed(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
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
                  SizedBox(
                    width: 14,
                    height: 14,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '$runningCount个任务运行中',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ] else ...[
                  Icon(
                    Icons.check_circle_rounded,
                    color: colorScheme.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '任务完成',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ],
            );
          }),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.expand_less_rounded, color: colorScheme.onSurface),
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
  Widget _buildExpanded(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        _buildHeader(controller, theme, colorScheme),
        _buildTabs(controller, theme, colorScheme),
        Expanded(child: _buildLogContent(controller, theme, colorScheme)),
      ],
    );
  }

  /// Build header with title and controls
  Widget _buildHeader(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        // Header 顶部圆角
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.terminal_rounded,
            color: colorScheme.primary,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            '任务日志',
            style: theme.textTheme.titleSmall?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Obx(() {
            final runningCount =
                controller.tasks.where((t) => t.isRunning.value).length;
            if (runningCount > 0) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12), // 更圆润
                ),
                child: Text(
                  '$runningCount 运行中',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const Spacer(),
          IconButton(
            icon: Icon(Icons.clear_all_rounded,
                color: colorScheme.onSurfaceVariant),
            iconSize: 18,
            tooltip: '清空所有',
            onPressed: () => controller.clearAll(),
          ),
          IconButton(
            icon: Icon(Icons.expand_more_rounded, color: colorScheme.onSurface),
            iconSize: 20,
            tooltip: '收起',
            onPressed: () => controller.isExpanded.value = false,
          ),
        ],
      ),
    );
  }

  /// Build task tabs for switching between tasks
  Widget _buildTabs(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 44, // 增加高度以容纳圆角 tab
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        border: Border(
          bottom: BorderSide(color: colorScheme.outlineVariant),
        ),
      ),
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.tasks.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return Obx(() {
                final isActive = task.taskId == controller.currentTaskId.value;
                return InkWell(
                  onTap: () => controller.currentTaskId.value = task.taskId,
                  borderRadius: BorderRadius.circular(20), // 胶囊形状
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isActive
                          ? colorScheme.primaryContainer
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20), // 胶囊形状
                      border: isActive
                          ? Border.all(
                              color: colorScheme.primary.withOpacity(0.5),
                              width: 1.5,
                            )
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (task.isRunning.value)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.primary,
                            ),
                          )
                        else
                          Icon(
                            task.hasError.value
                                ? Icons.error_rounded
                                : Icons.check_circle_rounded,
                            color: task.hasError.value
                                ? colorScheme.error
                                : (isActive
                                    ? colorScheme.onPrimaryContainer
                                    : colorScheme.primary),
                            size: 14,
                          ),
                        const SizedBox(width: 6),
                        Text(
                          task.taskName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isActive
                                ? colorScheme.onPrimaryContainer
                                : colorScheme.onSurface,
                            fontWeight:
                                isActive ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: () => controller.removeTask(task.taskId),
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(2),
                            child: Icon(
                              Icons.close_rounded,
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              size: 14,
                            ),
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
  Widget _buildLogContent(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Obx(() {
      final task = controller.tasks.firstWhereOrNull(
        (t) => t.taskId == controller.currentTaskId.value,
      );

      if (task == null) {
        return Center(
          child: Text(
            '无日志',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      return Container(
        color: colorScheme.surfaceContainerLowest,
        padding: const EdgeInsets.all(12),
        child: Obx(() {
          if (task.logs.isEmpty) {
            return Center(
              child: Text(
                '等待输出...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: task.logs.length,
            itemBuilder: (context, index) {
              final line = task.logs[index];
              final isError =
                  line.startsWith('[ERROR]'); // 只有明确的 [ERROR] 前缀才是错误

              return SelectableText(
                line,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  color: isError
                      ? colorScheme.error // 错误：红色
                      : colorScheme.onSurfaceVariant, // 其他所有输出：正常颜色
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
