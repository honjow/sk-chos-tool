import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sk_chos_tool/controller/log_controller.dart';

/// Log panel component that displays task execution logs
///
/// Shows at the bottom of the main page:
/// - Height 0 when no tasks
/// - Height 40px when collapsed (shows task summary)
/// - Adjustable height when expanded (default 250px, can drag to resize)
class LogPanel extends StatelessWidget {
  const LogPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LogController>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Obx(() {
      if (controller.tasks.isEmpty) {
        return const SizedBox.shrink();
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: controller.isExpanded.value
            ? controller.panelHeight.value
            : LogController.collapsedHeight,
        child: Column(
          children: [
            // 可拖动的分隔条 - 触屏优化
            if (controller.isExpanded.value)
              _buildDragHandle(controller, colorScheme),
            // 面板内容
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: controller.isExpanded.value
                        ? BorderSide.none
                        : BorderSide(color: colorScheme.outlineVariant),
                  ),
                  color: colorScheme.surface,
                  borderRadius: controller.isExpanded.value
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        )
                      : null,
                ),
                child: controller.isExpanded.value
                    ? _buildExpanded(controller, theme, colorScheme)
                    : _buildCollapsed(controller, theme, colorScheme),
              ),
            ),
          ],
        ),
      );
    });
  }

  /// Build draggable handle for resizing - 触屏优化版本
  Widget _buildDragHandle(LogController controller, ColorScheme colorScheme) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        controller.updateHeight(details.delta.dy);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          height: 16, // 增加到 16px，更容易触摸
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Center(
            child: Container(
              width: 48, // 增加宽度，更明显
              height: 5, // 增加高度
              margin: const EdgeInsets.only(top: 5),
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity(0.5), // 提高透明度
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build collapsed view - 触屏优化
  Widget _buildCollapsed(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12), // 减少左右 padding
      child: Row(
        children: [
          Obx(() {
            final runningCount =
                controller.tasks.where((t) => t.isRunning.value).length;
            return Row(
              children: [
                if (runningCount > 0) ...[
                  SizedBox(
                    width: 16, // 略微增大
                    height: 16,
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
                    size: 18, // 增大到 18
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
          // 增加最小点击区域
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.isExpanded.value = true,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.all(8), // 增加点击区域
                child: Icon(
                  Icons.expand_less_rounded,
                  color: colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build expanded view
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

  /// Build header with title and controls - 触屏优化
  Widget _buildHeader(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 48, // 增加到 48，符合触屏标准
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          Icon(
            Icons.terminal_rounded,
            color: colorScheme.primary,
            size: 18, // 略微增大
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
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6), // 增大 padding
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14), // 更圆润
                ),
                child: Text(
                  '$runningCount 运行中',
                  style: theme.textTheme.labelMedium?.copyWith(
                    // 使用 labelMedium
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
          const Spacer(),
          // 增加按钮点击区域
          IconButton(
            icon: Icon(Icons.clear_all_rounded,
                color: colorScheme.onSurfaceVariant),
            iconSize: 22, // 增大图标
            tooltip: '清空所有',
            padding: const EdgeInsets.all(12), // 增加点击区域
            constraints:
                const BoxConstraints(minWidth: 48, minHeight: 48), // 最小触摸区域
            onPressed: () => controller.clearAll(),
          ),
          IconButton(
            icon: Icon(Icons.expand_more_rounded, color: colorScheme.onSurface),
            iconSize: 24, // 增大图标
            tooltip: '收起',
            padding: const EdgeInsets.all(12), // 增加点击区域
            constraints:
                const BoxConstraints(minWidth: 48, minHeight: 48), // 最小触摸区域
            onPressed: () => controller.isExpanded.value = false,
          ),
        ],
      ),
    );
  }

  /// Build task tabs - 触屏优化
  Widget _buildTabs(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      height: 52, // 增加高度，更容易点击
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
      ),
      child: Obx(() => ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.tasks.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: 10), // 增加间距
            itemBuilder: (context, index) {
              final task = controller.tasks[index];
              return Obx(() {
                final isActive = task.taskId == controller.currentTaskId.value;
                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => controller.currentTaskId.value = task.taskId,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8), // 增大 padding
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
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
                              width: 14,
                              height: 14,
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
                              size: 16, // 增大图标
                            ),
                          const SizedBox(width: 8),
                          Text(
                            task.taskName,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              // 使用 bodyMedium
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                              fontWeight: isActive
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 关闭按钮 - 触屏优化
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => controller.removeTask(task.taskId),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(4), // 增加点击区域
                                child: Icon(
                                  Icons.close_rounded,
                                  color: isActive
                                      ? colorScheme.onPrimaryContainer
                                      : colorScheme.onSurfaceVariant,
                                  size: 18, // 增大关闭按钮
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
              final isError = line.startsWith('[ERROR]');

              return SelectableText(
                line,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13, // 略微增大字体，触屏更易读
                  color: isError
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  height: 1.5, // 增加行高，更易读
                ),
              );
            },
          );
        }),
      );
    });
  }
}
