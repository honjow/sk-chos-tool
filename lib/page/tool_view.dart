import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/installer_item.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

class ToolView extends StatelessWidget {
  const ToolView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkSingleChildScrollView(
      child: Column(
        children: [
          InstallerItem(
            title: 'Nix Package Manager',
            description: 'Nix 包管理器, 可以在不可变系统上安装软件, 系统更新不会影响软件',
            onCheck: chkNix,
            onInstall: installNix,
            onUninstall: uninstallNix,
          ),
        ],
      ),
    );
  }
}
