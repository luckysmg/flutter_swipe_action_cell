import 'package:flutter/widgets.dart';

class CellOpenEvent {
  CellOpenEvent(this.key);

  final Key key;
}

class PullLastButtonEvent {
  PullLastButtonEvent({this.isPullingOut});

  bool isPullingOut;
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
  IgnorePointerEvent({this.key, this.ignore});

  final Key key;
  final bool ignore;
}
