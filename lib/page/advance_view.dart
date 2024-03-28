import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/action_button.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

class AdvanceView extends StatelessWidget {
  const AdvanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkSingleChildScrollView(
        child: Column(
      children: [
        ActionButtonItem(
          title: '清除缓存',
          onPressed: clearCache,
        ),
        ActionButtonItem(
          title: '修复启动项',
          onPressed: bootRepair,
        ),
        ActionButtonItem(
          title: '重新运行首次自动配置脚本',
          description: '从预下载路径中安装Decky、Decky插件、手柄映射等。初始化Sk-ChimeraOS的一些用户配置',
          onPressed: reFirstRun,
        ),
        ActionButtonItem(
          title: '修复 /etc',
          description: '复位 /etc 中的大部分配置为默认值。如果睡眠后立即唤醒, 可以尝试修复',
          onPressed: etcRepair,
        ),
        ActionButtonItem(
          title: '修复 /etc (完全)',
          description: '复位 /etc 中的所有配置为默认值。重启后需要重新配置网络连接等配置',
          onPressed: etcRepairFull,
        ),
        ActionButtonItem(
          title: '重新创建 Swapfile',
          onPressed: makeSwapfile,
        ),
        ActionButtonItem(
          title: '重置 Gnome 桌面',
          onPressed: resetGnome,
        ),
      ],
    ));
  }
}
