import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/item_layout.dart';
import 'package:sk_chos_tool/const.dart';

class SwitchItemController {
  SwitchItemController();

  Future<void> Function()? reCheck;
}

class SwitchItem extends StatefulWidget {
  const SwitchItem({
    super.key,
    required this.title,
    this.description,
    this.onChanged,
    this.value,
    this.onCheck,
    this.enabled = true,
    this.controller,
  }) : assert(value != null || onCheck != null);
  final String title;
  final String? description;
  final bool? value;
  final ValueChanged<bool>? onChanged;
  final FutureOr<bool> Function()? onCheck;
  final bool enabled;
  final SwitchItemController? controller;

  @override
  State<SwitchItem> createState() => _SwitchItemState();
}

class _SwitchItemState extends State<SwitchItem> {
  bool _value = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      widget.controller!.reCheck = checkValue;
    }

    //addPostFrameCallback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkValue();
    });
  }

  Future<void> checkValue() async {
    if (widget.onCheck != null) {
      final value = await widget.onCheck!();
      if (mounted) {
        setState(() {
          _value = value;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ItemLayout(
      title: widget.title,
      description: widget.description,
      trailing: Padding(
        padding: AppPadding.smallPadding,
        child: Switch(
          value: _value,
          onChanged: widget.enabled
              ? (bool value) {
                  widget.onChanged?.call(value);
                  if (mounted) {
                    setState(() {
                      _value = value;
                    });
                  }
                }
              : null,
        ),
      ),
    );
  }
}
