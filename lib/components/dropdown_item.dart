import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sk_chos_tool/components/item_layout.dart';

class DropdownItem<T> extends StatefulWidget {
  const DropdownItem({
    super.key,
    required this.title,
    this.description,
    this.value,
    required this.items,
    this.onCheck,
    this.onChanged,
  });

  final String title;
  final String? description;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final FutureOr<T> Function()? onCheck;
  final ValueChanged<T>? onChanged;

  @override
  State<DropdownItem> createState() => _DropdownItemState<T>();
}

class _DropdownItemState<T> extends State<DropdownItem<T>> {
  late T? _value = widget.value;

  @override
  void initState() {
    super.initState();

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
      trailing: DropdownButton<T>(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        value: _value,
        onChanged: (T? newValue) {
          if (mounted) {
            setState(() {
              _value = newValue;
              if (widget.onChanged != null) {
                final value = _value;
                if (value != null) {
                  widget.onChanged?.call(value);
                }
              }
            });
          }
        },
        items: widget.items,
      ),
    );
  }
}
