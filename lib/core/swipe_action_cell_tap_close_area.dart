import 'package:flutter/cupertino.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

class SwipeActionCellTapCloseArea extends StatelessWidget {
  final Widget child;

  final SwipeActionController _controller = SwipeActionController();

  SwipeActionCellTapCloseArea({Key? key, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        _controller.closeAllOpenCell();
      },
      child: child,
    );
  }
}
