import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

typedef LayoutSizeChangedCallback = void Function(Size);

class LayoutSizeChangedNotifier extends SingleChildRenderObjectWidget {
  const LayoutSizeChangedNotifier({
    Key? key,
    Widget? child,
    required this.callback,
  }) : super(key: key, child: child);

  final LayoutSizeChangedCallback callback;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderLayoutSizeChanged(
      callback: callback,
    );
  }
}

class _RenderLayoutSizeChanged extends RenderProxyBox {
  _RenderLayoutSizeChanged({
    RenderBox? child,
    required this.callback,
  }) : super(child);

  final LayoutSizeChangedCallback callback;

  Size oldSize = Size.zero;

  @override
  void performLayout() {
    super.performLayout();
    if (oldSize != size) {
      callback(size);
    }
    oldSize = size;
  }
}
