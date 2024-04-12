import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
  final FutureOr<void> Function()? onInstall;
  final FutureOr<void> Function()? onUninstall;
  final FutureOr<bool> Function()? onCheck;
  final FutureOr<String>? Function()? onCurrentVersionCheck;
  final FutureOr<String>? Function()? onLatestVersionCheck;

  @override
  State<InstallerItem> createState() => _InstallerItemState();
}

class _InstallerItemState extends State<InstallerItem> {
  bool _installed = false;
  bool _isLoading = false;

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
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(),
              ),
            ),
          if (widget.onUninstall != null && _installed)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final backgroundColor = context
                            .theme.colorScheme.primaryContainer
                            .withOpacity(0.9);
                        try {
                          await widget.onUninstall?.call();
                          await _checkValue();
                          Get.snackbar(
                            '卸载成功',
                            '${widget.title} 卸载成功',
                            backgroundColor: backgroundColor,
                            icon: const Icon(Icons.check, color: Colors.green),
                            barBlur: 100,
                            snackPosition: SnackPosition.BOTTOM,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          );
                        } catch (e) {
                          Get.snackbar(
                            '卸载失败',
                            '${widget.title} 卸载失败 $e',
                            backgroundColor: backgroundColor,
                            icon: const Icon(Icons.error, color: Colors.red),
                            barBlur: 100,
                            snackPosition: SnackPosition.BOTTOM,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          );
                          rethrow;
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                child: const Text('卸载'),
              ),
            ),
          if (widget.onInstall != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                style: buttonStyle,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        final backgroundColor = context
                            .theme.colorScheme.primaryContainer
                            .withOpacity(0.9);
                        try {
                          await widget.onInstall?.call();
                          await _checkValue();
                          Get.snackbar(
                            '安装成功',
                            '${widget.title} 安装成功',
                            backgroundColor: backgroundColor,
                            icon: const Icon(Icons.check, color: Colors.green),
                            barBlur: 100,
                            snackPosition: SnackPosition.BOTTOM,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          );
                        } catch (e) {
                          Get.snackbar(
                            '安装失败',
                            '${widget.title} 安装失败 $e',
                            backgroundColor: backgroundColor,
                            icon: const Icon(Icons.error, color: Colors.red),
                            barBlur: 100,
                            snackPosition: SnackPosition.BOTTOM,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                            margin: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 20,
                            ),
                          );
                          rethrow;
                        } finally {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                child: _installed ? const Text('重新安装') : const Text('安装'),
              ),
            ),
        ],
      ),
    );
  }
}
