import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/scroll.dart';
import 'package:sk_chos_tool/utils/util.dart';

import '../components/switch_item.dart';

const sktKey = 'sk_chos_tool';
const handyKey = 'handygccs';
const hhdKey = 'hhd';

class OtaView extends StatefulWidget {
  const OtaView({super.key});

  @override
  State<OtaView> createState() => _OtaViewState();
}

class _OtaViewState extends State<OtaView> {
  bool _enableUpdate = true;
  @override
  Widget build(BuildContext context) {
    return SkSingleChildScrollView(
      child: Column(
        children: [
          SwitchItem(
            title: '自动更新总开关',
            onChanged: (bool value) async {
              await toggleService('sk-chos-tool-autoupdate.timer', value);
              setState(() {
                _enableUpdate = value;
              });
            },
            onCheck: () async =>
                checkServiceEnabled('sk-chos-tool-autoupdate.timer'),
          ),
          SwitchItem(
            title: '自动更新本软件',
            onChanged: (bool value) async => setAutoupdate(sktKey, value),
            onCheck: () async => chkAutoupdate(sktKey),
            enabled: _enableUpdate,
          ),
          // SwitchItem(
          //   title: '自动更新 HandyGCCS',
          //   onChanged: (bool value) async => setAutoupdate(handyKey, value),
          //   onCheck: () async => chkAutoupdate(handyKey),
          //   enabled: _enableUpdate,
          // ),
          // SwitchItem(
          //   title: '自动更新 HHD',
          //   onChanged: (bool value) async => setAutoupdate(hhdKey, value),
          //   onCheck: () async => chkAutoupdate(hhdKey),
          //   enabled: _enableUpdate,
          // ),
        ],
      ),
    );
  }
}
