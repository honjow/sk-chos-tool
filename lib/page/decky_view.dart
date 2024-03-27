import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/installer_item.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/decky_installer.dart';

class DeckyView extends StatelessWidget {
  const DeckyView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkSingleChildScrollView(
      child: Column(
        children: [
          InstallerItem(
            title: 'PowerControl',
            description: '掌机功耗性能管理Decky插件',
            onCheck: () async => checkDeckyPluginExists('PowerControl'),
            onInstall: installPowerControl,
            onUninstall: () async => uninstallDeckyPlugin('PowerControl'),
          ),
          InstallerItem(
            title: 'HHD Decky',
            description: '配合 HHD 使用',
            onCheck: () async => checkDeckyPluginExists('hhd-decky'),
            onInstall: installHHDDecky,
            onUninstall: () async => uninstallDeckyPlugin('hhd-decky'),
          ),
          InstallerItem(
            title: 'SBP-Legion-Go-Theme',
            description:
                '配合 HHD 使用的 CSS Loader 皮肤, 把模拟的 PS5 按钮显示为 Legion Go 的样式',
            onCheck: () async {
              final filePath =
                  '${Platform.environment['HOME']}/homebrew/themes/SBP-Legion-Go-Theme/theme.json';
              final file = File(filePath);
              return file.existsSync();
            },
            onInstall: installSPBLegionGo,
            onUninstall: () async {
              final filePath =
                  '${Platform.environment['HOME']}/homebrew/themes/SBP-Legion-Go-Theme';
              final file = Directory(filePath);
              if (file.existsSync()) {
                await file.delete(recursive: true);
              }
            },
          ),
          InstallerItem(
            title: 'SBP-PS5-to-Handheld',
            description:
                '配合 HHD 使用的 CSS Loader 皮肤, 整合了 ROG Ally 和其它掌机以及 XBox 的样式',
            onCheck: () async {
              final filePath =
                  '${Platform.environment['HOME']}/homebrew/themes/SBP-PS5-to-Handheld/theme.json';
              final file = File(filePath);
              return file.existsSync();
            },
            onInstall: installSPB,
            onUninstall: () async {
              final filePath =
                  '${Platform.environment['HOME']}/homebrew/themes/SBP-PS5-to-Handheld';
              final file = Directory(filePath);
              if (file.existsSync()) {
                await file.delete(recursive: true);
              }
            },
          ),
          InstallerItem(
            title: 'HueSync (原Ayaled)',
            description: '掌机 LED 灯控制Decky插件',
            onCheck: () async => checkDeckyPluginExists('HueSync'),
            onInstall: installHueSync,
            onUninstall: () async => uninstallDeckyPlugin('HueSync'),
          ),
          InstallerItem(
            title: 'ToMoon',
            description: '网络加速Decky插件',
            onCheck: () async => checkDeckyPluginExists('tomoon'),
            onInstall: installToMoon,
            onUninstall: () async => uninstallDeckyPlugin('tomoon'),
          ),
        ],
      ),
    );
  }
}
