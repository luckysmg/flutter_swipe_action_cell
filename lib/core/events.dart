import 'package:flutter/widgets.dart';

class CellOpenEvent {
  CellOpenEvent({required this.key});

  final Key key;
}

class PullLastButtonEvent {
  PullLastButtonEvent({this.key, required this.isPullingOut});

  final Key? key;
  final bool isPullingOut;
}

class PullLastButtonToCoverCellEvent {
  PullLastButtonToCoverCellEvent({required this.key});

  final Key key;
}

class IgnorePointerEvent {
  IgnorePointerEvent({required this.ignore});

  final bool ignore;
}

class CloseNestedActionEvent {
  CloseNestedActionEvent({required this.key});

  final Key key;
}

class EditingModeEvent {
  final bool editing;

  EditingModeEvent({required this.editing});
}

class CellSelectedEvent {
  CellSelectedEvent({required this.selected});

  final bool selected;
}
