import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

import '../components/switch_item.dart';

class SwitchView extends StatelessWidget {
  const SwitchView({super.key});

  @override
  Widget build(BuildContext context) {
    SwitchItemController hhdController = SwitchItemController();
    SwitchItemController handyconController = SwitchItemController();
    SwitchItemController inputplumberController = SwitchItemController();

    final isHandyconInatalled = handyconInatalled();
    final isHHDInatalled = hhdInatalled();
    final isInputplumberInatalled = inputplumberInatalled();

    return SkSingleChildScrollView(
      child: Column(
        children: [
          if (isHandyconInatalled)
            SwitchItem(
              title: 'HandyGCCS',
              controller: handyconController,
              description: '用来驱动部分掌机的手柄按钮',
              onChanged: (bool value) async {
                await toggleService('handycon.service', value);
                if (value) {
                  if (isHHDInatalled) {
                    await toggleService(
                        'hhd@${Platform.environment['USER']}.service', false);
                    hhdController.reCheck?.call();
                  }
                  if (isInputplumberInatalled) {
                    await toggleService('inputplumber.service', false);
                    inputplumberController.reCheck?.call();
                  }
                }
              },
              onCheck: () async => checkServiceAutostart('handycon.service'),
            ),
          if (isInputplumberInatalled)
            SwitchItem(
              title: 'InputPlumber',
              controller: inputplumberController,
              description: 'HandyGCCS 的替代品, 奇美拉官方出品. 控制器驱动',
              onChanged: (bool value) async {
                await toggleService('inputplumber.service', value);
                if (value) {
                  if (isHHDInatalled) {
                    await toggleService(
                        'hhd@${Platform.environment['USER']}.service', false);
                    hhdController.reCheck?.call();
                  }
                  if (isHandyconInatalled) {
                    await toggleService('handycon.service', false);
                    handyconController.reCheck?.call();
                  }
                }
              },
              onCheck: () async =>
                  checkServiceAutostart('inputplumber.service'),
            ),
          if (isHHDInatalled)
            SwitchItem(
              title: 'HHD',
              controller: hhdController,
              description:
                  'Handheld Daemon, 另一个手柄驱动程序, 通过模拟 PS5 手柄支持陀螺仪和背键能等功能. 不能和 HandyGCCS 同时使用. 请配合HHD Decky插件使用.',
              onChanged: (bool value) async {
                await toggleService(
                    'hhd@${Platform.environment['USER']}.service', value);
                if (value) {
                  if (isHandyconInatalled) {
                    await toggleService('handycon.service', false);
                    handyconController.reCheck?.call();
                  }

                  if (isInputplumberInatalled) {
                    await toggleService('inputplumber.service', false);
                    inputplumberController.reCheck?.call();
                  }
                }
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
          const SwitchItem(
            title: 'Github 下载加速',
            description:
                '开启后会随机使用内置的加速源下载 Github 文件，但某些时候可能会导致下载缓慢或者下载失败。在网络条件较好时建议关闭',
            onChanged: setEnableGithubCdn,
            onCheck: chkEnableGithubCdn,
          ),
        ],
      ),
    );
  }
}
