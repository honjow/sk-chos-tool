import 'package:flutter/widgets.dart';

class SkSingleChildScrollView extends StatelessWidget {
  const SkSingleChildScrollView({super.key, this.child, this.controller});

  final Widget? child;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    ScrollController controller = this.controller ?? ScrollController();

    double dragStartOffset = 0.0;
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        dragStartOffset = event.position.dy;
      },
      onPointerMove: (PointerMoveEvent event) {
        double delta = event.position.dy - dragStartOffset;
        controller.jumpTo(controller.offset - delta);
        dragStartOffset = event.position.dy;
      },
      child: SingleChildScrollView(
        controller: controller,
        child: child,
      ),
    );
  }
}
