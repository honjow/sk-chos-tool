import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:sk_chos_tool/components/installer_item.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    final homePath = '${Platform.environment['HOME']}';
    return SkSingleChildScrollView(
      child: Column(
        children: [
          InstallerItem(
            title: '本程序',
            description: 'SkorionOS Tool',
            onCheck: () => true,
            onInstall: installSkChosTool,
          ),
          InstallerItem(
            title: 'EmuDeck',
            description: '模拟器整合平台',
            onCheck: () async =>
                await chkFileExists('$homePath/Applications/EmuDeck.AppImage'),
            onInstall: installEmuDeck,
            onUninstall: () async => await uninstallAppImage('EmuDeck'),
          ),
          InstallerItem(
            title: 'An Anime Game Launcher',
            description: '原神 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/an-anime-game-launcher.AppImage'),
            onInstall: installAnAnimeGameLauncher,
            onUninstall: () async =>
                await uninstallAppImage('an-anime-game-launcher'),
          ),
          InstallerItem(
            title: 'The Honkers Railway Launcher',
            description: '崩坏:星穹铁道 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/the-honkers-railway-launcher.AppImage'),
            onInstall: installTheHonkersRailwayLauncher,
            onUninstall: () async =>
                await uninstallAppImage('the-honkers-railway-launcher'),
          ),
          // sleepy_launcher_install
          InstallerItem(
            title: 'Sleepy Launcher',
            description: '绝区零 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/sleepy-launcher.AppImage'),
            onInstall: installSleepyLauncher,
            onUninstall: () async => await uninstallAppImage('sleepy-launcher'),
          ),
          InstallerItem(
            title: 'Honkers Launcher',
            description: '崩坏3 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/honkers-launcher.AppImage'),
            onInstall: installHonkersLauncher,
            onUninstall: () async =>
                await uninstallAppImage('honkers-launcher'),
          ),
          InstallerItem(
            title: 'Anime Games Launcher',
            description: '动漫游戏启动器 (米哈游全家桶)',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/anime-games-launcher.AppImage'),
            onInstall: installAnimeGamesLauncher,
            onUninstall: () async =>
                await uninstallAppImage('anime-games-launcher'),
          ),
        ],
      ),
    );
  }
}
