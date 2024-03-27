import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../const.dart';

const kItemColor = Color(0x11000000);

class MenuItem extends StatefulWidget {
  const MenuItem({
    super.key,
    this.selected = false,
    this.icon,
    this.title,
  });
  final bool selected;
  final Widget? icon;
  final String? title;

  @override
  State<MenuItem> createState() => _MenuItemState();
}

class _MenuItemState extends State<MenuItem> {
  Color _color = Colors.transparent;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.selected) {
      _color = context.theme.colorScheme.onSecondary;
    }
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onHover: (PointerHoverEvent e) {
        if (!widget.selected) {
          setState(() {
            _color = context.theme.colorScheme.onSecondary;
          });
        }
      },
      onExit: (_) {
        setState(() {
          if (!widget.selected) {
            setState(() {
              _color = Colors.transparent;
            });
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          color: _color,
          borderRadius: BorderRadius.circular(6.0),
        ),
        constraints: const BoxConstraints(
          minHeight: 60.0,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(2.0),
              child: Container(
                width: 4,
                height: 24,
                color: widget.selected
                    ? context.theme.colorScheme.primary
                    : Colors.transparent,
              ),
            ),
            SizedBox(
              width: 60,
              child: widget.icon ?? const SizedBox.shrink(),
            ),
            Text(widget.title ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontFamilyFallback: kFontFamilyFallback,
                  fontSize: 16,
                )),
          ],
        ),
      ),
    );
  }
}

class MenuView extends StatefulWidget {
  const MenuView({
    super.key,
    required this.titles,
    this.icons,
    this.pageController,
  });
  final List<String> titles;
  final List<Widget>? icons;
  final PageController? pageController;

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final selected = (widget.pageController?.page ?? 0) ~/ 1 == index;

        return GestureDetector(
          onTap: () {
            widget.pageController?.jumpToPage(index);
            setState(() {});
          },
          child: MenuItem(
            key: ValueKey('$index$selected'),
            title: widget.titles[index],
            icon: widget.icons?[index],
            selected: (widget.pageController?.page ?? 0) ~/ 1 == index,
          ),
        );
      },
      itemCount: widget.titles.length,
    );
  }
}
