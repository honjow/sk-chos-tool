import 'package:flutter/material.dart';

const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 18);

class InstallerItem extends StatefulWidget {
  const InstallerItem({
    super.key,
    required this.title,
    this.description,
    this.onInstall,
    this.onUninstall,
    this.onCurrentVersionCheck,
    this.onLatestVersionCheck,
    this.onCheck,
  });
  final String title;
  final String? description;
  final Future<void> Function()? onInstall;
  final Future<void> Function()? onUninstall;
  final Future<bool> Function()? onCheck;
  final Future<String>? Function()? onCurrentVersionCheck;
  final Future<String>? Function()? onLatestVersionCheck;

  @override
  State<InstallerItem> createState() => _InstallerItemState();
}

class _InstallerItemState extends State<InstallerItem> {
  bool _installed = false;

  @override
  void initState() {
    super.initState();
    //addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkValue();
    });
  }

  Future<void> _checkValue() async {
    if (widget.onCheck != null) {
      final value = await widget.onCheck!();
      setState(() {
        _installed = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonStyle = ElevatedButton.styleFrom(
      padding: buttonPadding,
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.description != null)
                  Text(
                    widget.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.onUninstall != null && _installed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: () async {
                  await widget.onUninstall?.call();
                  await _checkValue();
                },
                child: const Text('卸载'),
              ),
            ),
          if (widget.onInstall != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: () async {
                  await widget.onInstall?.call();
                  await _checkValue();
                },
                child: _installed ? const Text('重新安装') : const Text('安装'),
              ),
            ),
        ],
      ),
    );
  }
}
