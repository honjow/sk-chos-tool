import 'dart:collection';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/dropdown_item.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/enum.dart';
import 'package:sk_chos_tool/utils/log.dart';
import 'package:sk_chos_tool/utils/util.dart';

import '../components/switch_item.dart';

const kDropdownMenuItemAlignment = Alignment.center;

final LinkedHashMap<SleepMode, String> dropdownMenuMap =
    LinkedHashMap<SleepMode, String>()
      ..[SleepMode.suspend] = '睡眠'
      ..[SleepMode.hibernate] = '休眠'
      ..[SleepMode.suspendThenHibernate] = '睡眠后休眠';

const kDefaultHibernateDelay = '30min';

final LinkedHashMap<String, String> delayMap = LinkedHashMap<String, String>()
  ..['10sec'] = '10 秒'
  ..['30sec'] = '30 秒'
  ..['1min'] = '1 分钟'
  ..['5min'] = '5 分钟'
  ..['10min'] = '10 分钟'
  ..['30min'] = '30 分钟'
  ..['1hour'] = '1 小时'
  ..['2hour'] = '2 小时'
  ..['3hour'] = '3 小时'
  ..['6hour'] = '6 小时'
  ..['12hour'] = '12 小时';

class GeneralView extends StatelessWidget {
  const GeneralView({super.key});

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
                await toggleHandheldService('handycon.service', value);
                if (value) {
                  if (isHHDInatalled) {
                    hhdController.reCheck?.call();
                  }
                  if (isInputplumberInatalled) {
                    inputplumberController.reCheck?.call();
                  }
                }
              },
              onCheck: () async => checkServiceEnabled('handycon.service'),
            ),
          if (isInputplumberInatalled)
            SwitchItem(
              title: 'InputPlumber',
              controller: inputplumberController,
              description: 'HandyGCCS 的替代品, 奇美拉官方出品. 控制器驱动',
              onChanged: (bool value) async {
                await toggleHandheldService('inputplumber.service', value);
                if (value) {
                  if (isHHDInatalled) {
                    hhdController.reCheck?.call();
                  }
                  if (isHandyconInatalled) {
                    handyconController.reCheck?.call();
                  }
                }
              },
              onCheck: () async => checkServiceEnabled('inputplumber.service'),
            ),
          if (isHHDInatalled)
            SwitchItem(
              title: 'HHD',
              controller: hhdController,
              description:
                  'Handheld Daemon, 另一个手柄驱动程序, 通过模拟 PS5 手柄支持陀螺仪和背键能等功能. 不能和 HandyGCCS 同时使用. 请配合HHD Decky插件使用.',
              onChanged: (bool value) async {
                await toggleHandheldService(
                    'hhd@${Platform.environment['USER']}.service', !value);
                await toggleHandheldService('hhd.service', value);
                if (value) {
                  if (isHandyconInatalled) {
                    // await toggleHandheldService('handycon.service', false);
                    handyconController.reCheck?.call();
                  }

                  if (isInputplumberInatalled) {
                    // await toggleHandheldService('inputplumber.service', false);
                    inputplumberController.reCheck?.call();
                  }
                }
              },
              onCheck: () async {
                return await checkServiceEnabled(
                  'hhd@${Platform.environment['USER']}.service') || await checkServiceEnabled('hhd.service');
              },
            ),
          SwitchItem(
            title: 'SkorionOS 启动项守护服务',
            description:
                '开启后, 每次启动 SkorionOS 都会将自身启动项作为下次启动项, 解决双系统启动项维持问题。最好配合 Windows 启动到 SkorionOS 的功能使用, 否则建议关闭',
            onChanged: (bool value) async {
              await toggleService('sk-setup-next-boot.service', value);
            },
            onCheck: () async =>
                checkServiceEnabled('sk-setup-next-boot.service'),
          ),
          // const SwitchItem(
          //   title: '休眠',
          //   description: '开启后按下电源键会进入休眠状态, 否则是睡眠状态',
          //   onChanged: setHibernate,
          //   onCheck: chkHibernate,
          // ),
          const SleepModeComponent(),
          // const SwitchItem(
          //   title: 'Github 下载加速',
          //   description:
          //       '开启后会随机使用内置的加速源下载 Github 文件，但某些时候可能会导致下载缓慢或者下载失败。在网络条件较好时建议关闭',
          //   onChanged: setEnableGithubCdn,
          //   onCheck: chkEnableGithubCdn,
          // ),
        ],
      ),
    );
  }
}

class SleepModeComponent extends StatefulWidget {
  const SleepModeComponent({super.key});

  @override
  State<SleepModeComponent> createState() => _SleepModeComponentState();
}

class _SleepModeComponentState extends State<SleepModeComponent> {
  bool _showDelayMenu = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownItem<SleepMode>(
          title: '睡眠模式',
          description:
              '选择睡眠模式, 睡眠是默认选择。休眠是将系统状态保存到硬盘，再关机，速度较慢。睡眠后休眠 是先睡眠，在达到设置的时间后自动休眠，但是部分设备上可能存在问题',
          value: SleepMode.suspend,
          onCheck: () async {
            final mode = await getSleepMode();
            logger.i('Sleep mode: $mode');
            setState(() {
              _showDelayMenu = mode == SleepMode.suspendThenHibernate;
            });
            return mode;
          },
          onChanged: (val) async {
            setState(() {
              _showDelayMenu = val == SleepMode.suspendThenHibernate;
            });
            await setSleepMode(val);
          },
          items: dropdownMenuMap.entries
              .map((e) => DropdownMenuItem(
                    alignment: kDropdownMenuItemAlignment,
                    value: e.key,
                    child: Text(e.value),
                  ))
              .toList(),
        ),
        if (_showDelayMenu)
          DropdownItem<String>(
            title: '睡眠后休眠延迟',
            description: '选择睡眠后休眠的延迟时间',
            value: kDefaultHibernateDelay,
            onCheck: () async {
              final delay = await getHibernateDelayAutoSet();
              logger.i('Sleep delay: $delay');
              return delay;
            },
            onChanged: (val) async {
              setState(() {});
              await setHibernateDelay(val);
            },
            items: delayMap.entries
                .map((e) => DropdownMenuItem(
                      alignment: kDropdownMenuItemAlignment,
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
          ),
      ],
    );
  }
}
