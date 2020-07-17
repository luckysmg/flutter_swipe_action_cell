import 'package:flutter/widgets.dart';

class CellOpenEvent {
  CellOpenEvent(this.key);

  GlobalKey key;
}

class PullLastButtonEvent {
  PullLastButtonEvent({this.isPullingOut});

  bool isPullingOut;
}

class CloseCellEvent {
  CloseCellEvent({this.key});

  GlobalKey key;
}

class DeleteCellEvent {
  DeleteCellEvent({this.key});

  GlobalKey key;
}

class PullLastButtonToCoverCellEvent {
  PullLastButtonToCoverCellEvent({this.key});

  GlobalKey key;
}

class IgnorePointerEvent {
  IgnorePointerEvent({this.key, this.ignore});

  GlobalKey key;
  bool ignore;
}
