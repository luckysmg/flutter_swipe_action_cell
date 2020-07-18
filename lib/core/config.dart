import 'package:flutter/material.dart';

import 'swipe_action_cell.dart';

class SwipeActionButtonConfig {
  final double width;
  final SwipeAction action;
  final bool fullDraggable;
  final bool isTheOnlyOne;
  final double radius;
  final Key parentKey;
  final bool firstActionWillCoverAllSpaceOnDeleting;
  final bool isLastOne;
  final double contentWidth;

  SwipeActionButtonConfig(
      this.width,
      this.action,
      this.fullDraggable,
      this.isTheOnlyOne,
      this.radius,
      this.parentKey,
      this.firstActionWillCoverAllSpaceOnDeleting,
      this.isLastOne,
      this.contentWidth);
}
