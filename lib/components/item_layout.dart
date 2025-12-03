import 'package:flutter/material.dart';
import 'package:sk_chos_tool/const.dart';

/// A reusable layout widget for item components with title, description, and trailing widget.
///
/// This widget provides a consistent layout used across SwitchItem, DropdownItem, and InstallerItem.
/// It displays a title with an optional description on the left, and a trailing widget on the right.
class ItemLayout extends StatelessWidget {
  const ItemLayout({
    super.key,
    required this.title,
    this.description,
    required this.trailing,
  });

  /// The main title text
  final String title;

  /// Optional description text shown below the title
  final String? description;

  /// Widget to display on the right side (e.g., Switch, Button, Dropdown)
  final Widget trailing;

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
                Text(title, style: AppTextStyles.itemTitle),
                if (description != null)
                  Text(description!, style: AppTextStyles.itemDescription),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}
