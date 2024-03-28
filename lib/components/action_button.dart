import 'dart:async';

import 'package:flutter/material.dart';

const buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 18);
final buttonStyle = ElevatedButton.styleFrom(
  padding: buttonPadding,
  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(16.0),
  ),
);

class ActionButton extends StatefulWidget {
  const ActionButton({super.key, required this.title, this.onPressed});
  final String title;
  final FutureOr<void> Function()? onPressed;

  @override
  State<ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<ActionButton> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: buttonStyle,
      onPressed: _isLoading
          ? null
          : () async {
              setState(() {
                _isLoading = true;
              });
              try {
                await widget.onPressed?.call();
              } catch (e) {
                rethrow;
              } finally {
                setState(() {
                  _isLoading = false;
                });
              }
            },
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(widget.title),
          if (_isLoading) const SizedBox(width: 20),
          if (_isLoading)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
              ),
            ),
        ],
      ),
    );
  }
}

class ActionButtonItem extends StatelessWidget {
  const ActionButtonItem(
      {super.key, required this.title, this.description, this.onPressed});
  final String title;
  final String? description;
  final FutureOr<void> Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ActionButton(
            title: title,
            onPressed: onPressed,
          ),
          if (description != null) const SizedBox(height: 4),
          if (description != null)
            Text(
              description!,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
        ],
      ),
    );
  }
}
