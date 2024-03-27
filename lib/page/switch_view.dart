import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

import '../components/switch_item.dart';

class SwitchView extends StatelessWidget {
  const SwitchView({super.key});

  @override
  Widget build(BuildContext context) {
    return SkSingleChildScrollView(
      child: Column(
        children: [
          SwitchItem(
            title: 'HandyGCCS',
            description: '用来驱动部分掌机的手柄按钮',
            onChanged: (bool value) async {
              await toggleService('handygccs.service', value);
            },
            onCheck: () async => checkServiceAutostart('handycon.service'),
          ),
          SwitchItem(
            title: 'HHD',
            description:
                'Handheld Daemon, 另一个手柄驱动程序, 通过模拟 PS5 手柄支持陀螺仪和背键能等功能. 不能和 HandyGCCS 同时使用. 请配合HHD Decky插件使用.',
            onChanged: (bool value) async {
              await toggleService(
                  'hhd@${Platform.environment['USER']}.service', value);
            },
            onCheck: () async => checkServiceAutostart(
                'hhd@${Platform.environment['USER']}.service'),
          ),
          SwitchItem(
            title: 'SK Chimeraos 启动项守护服务',
            description:
                '开启后, 每次启动 Sk-Chimeraos 都会将自身启动项作为下次启动项, 解决双系统启动项维持问题。最好配合 Windows 启动到 Sk-Chimeraos 的功能使用, 否则建议关闭',
            onChanged: (bool value) async {
              await toggleService('sk-auto-keep-boot-entry.service', value);
            },
            onCheck: () async =>
                checkServiceAutostart('sk-auto-keep-boot-entry.service'),
          ),
          const SwitchItem(
            title: '休眠',
            description: '开启后按下电源键会进入休眠状态, 否则是睡眠状态',
            onChanged: setHibernate,
            onCheck: chkHibernate,
          ),
          const SwitchItem(
            title: 'firmware固件覆盖',
            description: '用启用DSDT覆盖等, 用于修复部分掌机的问题，切换后需要重启。建议开启',
            onChanged: setFirmwareOverride,
            onCheck: chkFirmwareOverride,
          ),
          const SwitchItem(
            title: 'USB 唤醒',
            onChanged: setUsbWakeup,
            onCheck: chkUsbWakeup,
          ),
        ],
      ),
    );
  }
}
