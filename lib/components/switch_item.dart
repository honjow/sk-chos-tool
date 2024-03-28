import 'dart:async';

import 'package:flutter/material.dart';

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
      setState(() {
        _value = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Switch(
              value: _value,
              onChanged: widget.enabled
                  ? (bool value) {
                      widget.onChanged?.call(value);
                      setState(() {
                        _value = value;
                      });
                    }
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
