import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';
import 'package:sk_chos_tool/controller/main_controller.dart';
import 'package:sk_chos_tool/page/main_view.dart';
import 'package:sk_chos_tool/utils/window_state.dart';
import 'package:sk_chos_tool/utils/theme_sync.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // Configure window options - use normal to show GTK header bar
  WindowOptions windowOptions = const WindowOptions(
    size: Size(800, 550),
    minimumSize: Size(800, 400),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal, // Keep system decorations
  );

  // Wait until ready to show window
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await WindowStateManager.restoreWindowState();
    await windowManager.show();
    await windowManager.focus();
    // Notify native side that Flutter is ready to hide loading
    await ThemeSync.notifyFlutterReady();
  });

  Get.lazyPut(() => MainController(), fenix: true);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WindowListener {
  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  void dispose() {
    windowManager.removeListener(this);
    super.dispose();
  }

  // 窗口关闭前保存（最重要！）
  @override
  void onWindowClose() async {
    await WindowStateManager.saveWindowState();
  }

  // 窗口调整大小时保存（防抖）
  @override
  void onWindowResize() {
    WindowStateManager.scheduleSave();
  }

  // 窗口移动时保存（防抖）
  @override
  void onWindowMove() {
    WindowStateManager.scheduleSave();
  }

  // 最大化时立即保存
  @override
  void onWindowMaximize() {
    WindowStateManager.saveWindowState();
  }

  // 取消最大化时立即保存
  @override
  void onWindowUnmaximize() {
    WindowStateManager.saveWindowState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SkorionOS Tool',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainPage(title: 'SkorionOS Tool'),
      builder: (context, child) {
        // Sync header bar color with Flutter theme
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ThemeSync.updateHeaderBarColor(context);
        });
        return child ?? const SizedBox.shrink();
      },
    );
  }
}
