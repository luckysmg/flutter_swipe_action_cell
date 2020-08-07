import 'package:flutter/widgets.dart';

class CellOpenEvent {
  CellOpenEvent({this.key});

  final Key key;
}

class PullLastButtonEvent {
  PullLastButtonEvent({this.key, this.isPullingOut});

  final Key key;
  final bool isPullingOut;
}

class CloseCellEvent {
  CloseCellEvent({this.key});

  final Key key;
}

class DeleteCellEvent {
  DeleteCellEvent({this.key});

  final Key key;
}

class PullLastButtonToCoverCellEvent {
  PullLastButtonToCoverCellEvent({this.key});

  final Key key;
}

class IgnorePointerEvent {
  IgnorePointerEvent({this.ignore});

  final bool ignore;
}

class CloseNestedActionEvent {
  CloseNestedActionEvent({this.key});

  final Key key;
}
