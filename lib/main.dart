import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sk_chos_tool/controller/main_controller.dart';
import 'package:sk_chos_tool/page/main_view.dart';
import 'package:sk_chos_tool/utils/window_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut(() => MainController(), fenix: true);
  runApp(const MyApp());

  doWhenWindowReady(() async {
    // Restore window state (position, size, maximized)
    await WindowStateManager.restoreWindowState();
  });
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Save window state when app is paused or detached
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      WindowStateManager.saveWindowState();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      // navigatorKey: Get.key,
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
      // builder: (context, child) {
      //   return Overlay(
      //     initialEntries: [OverlayEntry(builder: (_) => child!)],
      //   );
      // },
    );
  }
}
