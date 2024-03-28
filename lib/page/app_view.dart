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
            title: 'EmuDeck',
            description: '模拟器整合平台',
            onCheck: () async =>
                await chkFileExists('$homePath/Applications/EmuDeck.AppImage'),
            onInstall: installEmuDeck,
          ),
          InstallerItem(
            title: 'An Anime Game Launcher',
            description: '原神 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/an-anime-game-launcher.AppImage'),
            onInstall: installAnAnimeGameLauncher,
          ),
          InstallerItem(
            title: 'The Honkers Railway Launcher',
            description: '崩坏:星穹铁道 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/the-honkers-railway-launcher.AppImage'),
            onInstall: installTheHonkersRailwayLauncher,
          ),
          InstallerItem(
            title: 'Honkers Launcher',
            description: '崩坏3 启动器',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/honkers-launcher.AppImage'),
            onInstall: installHonkersLauncher,
          ),
          InstallerItem(
            title: 'Anime Games Launcher',
            description: '动漫游戏启动器 (米哈游全家桶)',
            onCheck: () async => await chkFileExists(
                '$homePath/Applications/anime-games-launcher.AppImage'),
            onInstall: installAnimeGamesLauncher,
          ),
          InstallerItem(
            title: '本程序',
            description: 'Sk ChimeraOS Tool',
            onCheck: () => true,
            onInstall: () {},
          ),
        ],
      ),
    );
  }
}
