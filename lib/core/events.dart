import 'package:flutter/widgets.dart';

import 'controller.dart';

class CellFingerOpenEvent {
  CellFingerOpenEvent({required this.key});

  final Key key;
}

class CellProgramOpenEvent {
  const CellProgramOpenEvent({
    required this.controller,
    required this.index,
    required this.animated,
    required this.trailing,
  });

  final SwipeActionController controller;
  final int index;
  final bool animated;
  final bool trailing;
}

class PullLastButtonEvent {
  const PullLastButtonEvent({this.key, required this.isPullingOut});

  final Key? key;
  final bool isPullingOut;
}

class PullLastButtonToCoverCellEvent {
  const PullLastButtonToCoverCellEvent({required this.key});

  final Key key;
}

class IgnorePointerEvent {
  const IgnorePointerEvent({required this.ignore});

  final bool ignore;
}

class CloseNestedActionEvent {
  const CloseNestedActionEvent({required this.key});

  final Key key;
}

class EditingModeEvent {
  const EditingModeEvent({required this.controller, required this.editing});

  final SwipeActionController controller;
  final bool editing;
}

class CellSelectedEvent {
  CellSelectedEvent({required this.selected});

  final bool selected;
}
