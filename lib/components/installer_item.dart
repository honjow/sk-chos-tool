import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/const.dart';
import 'package:sk_chos_tool/utils/snackbar_helper.dart';

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
      if (mounted) {
        setState(() {
          _installed = value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.itemPadding,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.title, style: AppTextStyles.itemTitle),
                if (widget.description != null)
                  Text(widget.description!,
                      style: AppTextStyles.itemDescription),
              ],
            ),
          ),
          if (_isLoading)
            Padding(
              padding: AppPadding.smallPadding,
              child: SizedBox(
                width: AppSizes.loadingIndicatorSize,
                height: AppSizes.loadingIndicatorSize,
                child: const CircularProgressIndicator(),
              ),
            ),
          if (widget.onUninstall != null && _installed)
            Padding(
              padding: AppPadding.smallPadding,
              child: ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await widget.onUninstall?.call();
                          await _checkValue();
                          SnackbarHelper.showSuccess(
                            '卸载成功',
                            '${widget.title} 卸载成功',
                          );
                        } catch (e) {
                          SnackbarHelper.showError(
                            '卸载失败',
                            '${widget.title} 卸载失败 $e',
                          );
                          rethrow;
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }
                      },
                child: const Text('卸载'),
              ),
            ),
          if (widget.onInstall != null)
            Padding(
              padding: AppPadding.smallPadding,
              child: ElevatedButton(
                style: elevatedButtonStyle,
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await widget.onInstall?.call();
                          await _checkValue();
                          SnackbarHelper.showSuccess(
                            '安装成功',
                            '${widget.title} 安装成功',
                          );
                        } catch (e) {
                          SnackbarHelper.showError(
                            '安装失败',
                            '${widget.title} 安装失败 $e',
                          );
                          rethrow;
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
                          }
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
