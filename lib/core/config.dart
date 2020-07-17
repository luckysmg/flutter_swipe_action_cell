import 'package:flutter/material.dart';

import 'swipe_action.dart';


class SwipeActionButtonConfig {
  final double width;
  final SwipeAction action;
  final bool fullDraggable;
  final bool isTheOnlyOne;
  final double radius;
  final GlobalKey parentKey;
  final bool firstActionWillCoverAllSpaceOnDeleting;
  final double maxPerActionButtonWidth;
  final isLastOne;

  SwipeActionButtonConfig(
      this.width,
      this.action,
      this.fullDraggable,
      this.isTheOnlyOne,
      this.radius,
      this.parentKey,
      this.firstActionWillCoverAllSpaceOnDeleting,
      this.maxPerActionButtonWidth,
      this.isLastOne);
}
