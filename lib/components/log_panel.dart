import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xterm/xterm.dart';
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
        duration: controller.isDragging.value
            ? Duration.zero // 拖动时无动画，跟手
            : const Duration(milliseconds: 300), // 展开/收起时有动画
        curve: Curves.easeInOut,
        height: controller.isExpanded.value
            ? controller.panelHeight.value
            : LogController.collapsedHeight,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
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
              child: Stack(
                children: [
                  // 展开内容 - 始终存在，只控制可见性
                  Offstage(
                    offstage: constraints.maxHeight <= 100,
                    child: _buildExpanded(controller, theme, colorScheme),
                  ),
                  // 收起内容
                  if (constraints.maxHeight <= 100)
                    _buildCollapsed(controller, theme, colorScheme),
                ],
              ),
            );
          },
        ),
      );
    });
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
    return ClipRect(
      child: Column(
        children: [
          _buildHeader(controller, theme, colorScheme),
          _buildTabs(controller, theme, colorScheme),
          Expanded(child: _buildLogContent(controller, theme, colorScheme)),
        ],
      ),
    );
  }

  /// Build header with integrated drag handle
  Widget _buildHeader(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onVerticalDragStart: (_) => controller.startDrag(),
      onVerticalDragUpdate: (details) {
        controller.updateHeight(details.delta.dy);
      },
      onVerticalDragEnd: (_) => controller.endDrag(),
      child: MouseRegion(
        cursor: SystemMouseCursors.resizeUpDown,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
          ),
          child: Stack(
            children: [
              // 拖动指示器 - 浮在顶部中央
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 48,
                    height: 4,
                    decoration: BoxDecoration(
                      color:
                          colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
              // Header内容 - 垂直居中
              Align(
                alignment: Alignment.center,
                child: Row(
                  children: [
                    Icon(
                      Icons.terminal_rounded,
                      color: colorScheme.primary,
                      size: 18,
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
                      final runningCount = controller.tasks
                          .where((t) => t.isRunning.value)
                          .length;
                      if (runningCount > 0) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
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
                      iconSize: 20,
                      tooltip: '清空所有',
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () => controller.clearAll(),
                    ),
                    IconButton(
                      icon: Icon(Icons.expand_more_rounded,
                          color: colorScheme.onSurface),
                      iconSize: 22,
                      tooltip: '收起',
                      padding: const EdgeInsets.all(8),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      onPressed: () => controller.isExpanded.value = false,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                    onTap: () => controller.switchToTask(task.taskId),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6), // 减小垂直padding
                      decoration: BoxDecoration(
                        color: isActive
                            ? colorScheme.primaryContainer
                            : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: isActive
                            ? Border.all(
                                color:
                                    colorScheme.primary.withValues(alpha: 0.5),
                                width: 1.5,
                              )
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center, // 添加居中对齐
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
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurface,
                              fontWeight: isActive
                                  ? FontWeight.w500
                                  : FontWeight.normal,
                              height: 1.0, // 去除文字上下额外空间
                            ),
                          ),
                          const SizedBox(width: 8),
                          // 关闭按钮 - 简洁版
                          InkWell(
                            onTap: () => controller.removeTask(task.taskId),
                            borderRadius: BorderRadius.circular(9),
                            child: Icon(
                              Icons.close_rounded,
                              color: isActive
                                  ? colorScheme.onPrimaryContainer
                                  : colorScheme.onSurfaceVariant,
                              size: 18,
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

  /// Build log content area with PageView
  Widget _buildLogContent(
    LogController controller,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      color: colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.all(12),
      child: Obx(() {
        if (controller.tasks.isEmpty) {
          return Center(
            child: Text(
              '无日志',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          );
        }

        // 确保 pageController 指向正确的页面
        final currentIndex = controller.tasks.indexWhere(
          (t) => t.taskId == controller.currentTaskId.value,
        );
        if (currentIndex >= 0 &&
            controller.pageController.hasClients &&
            controller.pageController.page?.round() != currentIndex) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (controller.pageController.hasClients) {
              controller.pageController.jumpToPage(currentIndex);
            }
          });
        }

        return PageView.builder(
          controller: controller.pageController,
          physics: const NeverScrollableScrollPhysics(), // 禁用手势滑动
          itemCount: controller.tasks.length,
          onPageChanged: (index) {
            // 页面切换时同步 currentTaskId
            if (index < controller.tasks.length) {
              controller.currentTaskId.value = controller.tasks[index].taskId;
            }
          },
          itemBuilder: (context, index) {
            if (index >= controller.tasks.length) {
              return const SizedBox.shrink();
            }
            final task = controller.tasks[index];
            return _LogContentView(
              key: ValueKey(task.taskId), // 关键：绑定到特定任务
              task: task,
              theme: theme,
              colorScheme: colorScheme,
            );
          },
        );
      }),
    );
  }
}

/// Log content widget with xterm terminal emulation
class _LogContentView extends StatefulWidget {
  final TaskLog task;
  final ThemeData theme;
  final ColorScheme colorScheme;

  const _LogContentView({
    super.key,
    required this.task,
    required this.theme,
    required this.colorScheme,
  });

  @override
  State<_LogContentView> createState() => _LogContentViewState();
}

class _LogContentViewState extends State<_LogContentView>
    with AutomaticKeepAliveClientMixin {
  late final Terminal _terminal;
  final ScrollController _scrollController = ScrollController();
  int _lastLogCount = 0;
  bool _autoScroll = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _terminal = Terminal(maxLines: 1000);
    _scrollController.addListener(_onScroll);
    _autoScroll = widget.task.isRunning.value;

    // 加载所有已有日志
    if (widget.task.logs.isNotEmpty) {
      for (var log in widget.task.logs) {
        _terminal.write('$log\r\n');
      }
      _lastLogCount = widget.task.logs.length;
    }
  }

  @override
  void dispose() {
    // 保存滚动位置
    if (_scrollController.hasClients) {
      widget.task.scrollPosition = _scrollController.position.pixels;
    }
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Check if user manually scrolled up
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;

      // 实时保存滚动位置
      widget.task.scrollPosition = currentScroll;

      // If scrolling up (not at bottom), disable auto-scroll
      if ((maxScroll - currentScroll) > 100) {
        final controller = Get.find<LogController>();
        controller.userInteracted.value = true;
        setState(() {
          _autoScroll = false;
        });
      } else if (widget.task.isRunning.value) {
        // 只在任务运行中且滚动到底部时才恢复自动滚动
        setState(() {
          _autoScroll = true;
        });
      }
    }
  }

  void _scrollToBottom() {
    // 只在任务运行中且开启自动滚动时才滚动
    if (_scrollController.hasClients &&
        _autoScroll &&
        widget.task.isRunning.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Obx(() {
      final logs = widget.task.logs;

      if (logs.isEmpty) {
        return Center(
          child: Text(
            '等待输出...',
            style: widget.theme.textTheme.bodyMedium?.copyWith(
              color: widget.colorScheme.onSurfaceVariant,
            ),
          ),
        );
      }

      // 处理新增的日志
      if (logs.length > _lastLogCount) {
        for (var i = _lastLogCount; i < logs.length; i++) {
          _terminal.write('${logs[i]}\r\n');
        }
        _lastLogCount = logs.length;

        // 运行中任务且自动滚动开启时，滚动到底部
        if (widget.task.isRunning.value && _autoScroll) {
          _scrollToBottom();
        }
      }

      return Stack(
        children: [
          TerminalView(
            _terminal,
            scrollController: _scrollController,
            theme: TerminalTheme(
              cursor: widget.colorScheme.primary,
              selection: widget.colorScheme.primaryContainer,
              foreground: widget.colorScheme.onSurfaceVariant,
              background: widget.colorScheme.surfaceContainerLowest,
              black: widget.colorScheme.onSurface,
              red: Colors.red[400]!,
              green: Colors.green[400]!,
              yellow: Colors.yellow[400]!,
              blue: Colors.blue[400]!,
              magenta: Colors.purple[400]!,
              cyan: Colors.cyan[400]!,
              white: widget.colorScheme.onSurface,
              brightBlack: Colors.grey[600]!,
              brightRed: Colors.red[300]!,
              brightGreen: Colors.green[300]!,
              brightYellow: Colors.yellow[300]!,
              brightBlue: Colors.blue[300]!,
              brightMagenta: Colors.purple[300]!,
              brightCyan: Colors.cyan[300]!,
              brightWhite: widget.colorScheme.onSurface,
              searchHitBackground:
                  widget.colorScheme.secondary.withValues(alpha: 0.3),
              searchHitBackgroundCurrent:
                  widget.colorScheme.secondary.withValues(alpha: 0.5),
              searchHitForeground: widget.colorScheme.onSecondary,
            ),
            textStyle: const TerminalStyle(
              fontFamily: 'monospace',
              fontSize: 13,
            ),
            padding: EdgeInsets.zero,
            autofocus: false,
            backgroundOpacity: 1.0,
            readOnly: true,
            hardwareKeyboardOnly: true,
          ),
          // Show "scroll to bottom" button when not at bottom
          if (!_autoScroll)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.small(
                onPressed: () {
                  setState(() => _autoScroll = true);
                  _scrollToBottom();
                },
                backgroundColor: widget.colorScheme.primaryContainer,
                child: Icon(
                  Icons.arrow_downward_rounded,
                  color: widget.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
        ],
      );
    });
  }
}
