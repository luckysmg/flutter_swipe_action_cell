import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'config.dart';
import 'events.dart';
import 'swipe_action_cell.dart';

class SwipeActionButtonWidget extends StatefulWidget {
  ///配置
  final SwipeActionButtonConfig config;

  const SwipeActionButtonWidget({
    Key key,
    this.config,
  }) : super(key: key);

  @override
  _SwipeActionButtonWidgetState createState() {
    return _SwipeActionButtonWidgetState();
  }
}

class _SwipeActionButtonWidgetState extends State<SwipeActionButtonWidget>
    with SingleTickerProviderStateMixin {
  final Duration animDuration = const Duration(milliseconds: 80);
  Duration duration;
  double width;
  Alignment alignment;
  CompletionHandler handler;

  StreamSubscription pullLastButtonSubscription;
  StreamSubscription pullLastButtonToCoverCellEventSubscription;
  StreamSubscription closeNestedActionEventSubscription;

  bool isDeleting;
  bool isNestedActionShowing;

  Alignment tempAlignment;
  Duration tempDuration;

  @override
  void initState() {
    super.initState();
    isDeleting = false;

    isNestedActionShowing = false;

    alignment = widget.config.isTheOnlyOne && widget.config.fullDraggable
        ? Alignment.centerRight
        : Alignment.centerLeft;

    if (widget.config.action.forceAlignmentLeft) {
      alignment = Alignment.centerLeft;
    }
    duration = const Duration();
    width = 0;
    pullLastButtonSubscription = SwipeActionStore.getInstance()
        .bus
        .on<PullLastButtonEvent>()
        .listen((event) async {
      this.duration = animDuration;

      ///avoid layout jumping so await
      await Future.delayed(const Duration(milliseconds: 100));
      this.duration = const Duration();
      if (widget.config.isTheOnlyOne && widget.config.fullDraggable) {
        alignment =
            event.isPullingOut ? Alignment.centerLeft : Alignment.centerRight;
      } else {
        alignment = Alignment.centerLeft;
      }
      if (widget.config.action.forceAlignmentLeft) {
        alignment = Alignment.centerLeft;
      }
    });

    pullLastButtonToCoverCellEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<PullLastButtonToCoverCellEvent>()
        .listen((event) {
      if (event.key == widget.config.parentKey) {
        _animToCoverCell();
      }
    });

    closeNestedActionEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<CloseNestedActionEvent>()
        .listen((event) {
      if (event.key == widget.config.parentKey &&
          widget.config.action.nestedAction != null &&
          isNestedActionShowing) {
        _resetNestedAction();
      }
      if (event.key != widget.config.parentKey && isNestedActionShowing) {
        _resetNestedAction();
      }
    });

    _initCompletionHandler();
  }

  void _resetNestedAction() {
    isNestedActionShowing = false;
    alignment = tempAlignment;
    duration = tempDuration;
    setState(() {});
  }

  void _initCompletionHandler() {
    if (widget.config.action.onTap != null) {
      handler = (delete) async {
        if (delete) {
          if (widget.config.isLastOne) {
            SwipeActionStore.getInstance().bus.fire(IgnorePointerEvent(
                key: this.widget.config.parentKey, ignore: true));
          }

          if (widget.config.firstActionWillCoverAllSpaceOnDeleting) {
            isDeleting = true;
            _animToCoverCell();

            ///and avoid layout jumping because of fast animation
            await Future.delayed(const Duration(milliseconds: 50));
          }
          SwipeActionStore.getInstance()
              .bus
              .fire((DeleteCellEvent(key: widget.config.parentKey)));

          ///wait the animation to complete
          await Future.delayed(const Duration(milliseconds: 501));
        } else {
          if (widget.config.action.closeOnTap) {
            SwipeActionStore.getInstance()
                .bus
                .fire((CloseCellEvent(key: widget.config.parentKey)));
          }
        }
      };
    }
  }

  void _animToCoverCell() {
    if (mounted) {
      setState(() {
        isDeleting = true;
        width = widget.config.contentWidth;
        alignment = Alignment.centerLeft;
      });
    }
  }

  void _animToCoverPullActionContent() async {
    if (mounted) {
      tempDuration = duration;
      tempAlignment = alignment;
      setState(() {
        duration = const Duration(milliseconds: 150);
        isNestedActionShowing = true;
        alignment = Alignment.center;
        width = widget.config.action.nestedAction.nestedWidth ??
            widget.config.totalActionWidth;
      });
    }
  }

  @override
  void dispose() {
    pullLastButtonSubscription?.cancel();
    pullLastButtonToCoverCellEventSubscription?.cancel();
    closeNestedActionEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool shouldShowNestedActionInfo = widget.config.isLastOne &&
        widget.config.action.nestedAction != null &&
        isNestedActionShowing;

    if (!isDeleting && !isNestedActionShowing) {
      width = widget.config.width;
    }

    var duration =
        widget.config.fullDraggable ? this.duration : const Duration();
    if (isDeleting) {
      duration = const Duration(milliseconds: 100);
    }

    return GestureDetector(
      onTap: () {
        if (widget.config.isLastOne &&
            widget.config.action.nestedAction != null &&
            !isNestedActionShowing) {
          _animToCoverPullActionContent();
          return;
        }
        widget.config.action.onTap?.call(handler);
      },
      child: AnimatedContainer(
        width: width,
        duration: duration,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(widget.config.action.backgroundRadius),
              bottomLeft:
                  Radius.circular(widget.config.action.backgroundRadius)),
          color: widget.config.action.color,
        ),
        padding: EdgeInsets.only(
          left: alignment == Alignment.center
              ? 0
              : widget.config.action.leftPadding,
          right: widget.config.isTheOnlyOne &&
                  !(widget.config.action.forceAlignmentLeft) &&
                  widget.config.fullDraggable
              ? 16
              : 0,
        ),
        child: AnimatedAlign(
          duration: isNestedActionShowing
              ? const Duration(milliseconds: 0)
              : const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuart,
          alignment: alignment,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildIcon(shouldShowNestedActionInfo),
              _buildTitle(shouldShowNestedActionInfo),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(bool shouldShowNestedActionInfo) {
    return shouldShowNestedActionInfo
        ? widget.config.action.nestedAction.icon ?? const SizedBox()
        : widget.config.action.icon ?? const SizedBox();
  }

  Widget _buildTitle(bool shouldShowNestedActionInfo) {
    if (shouldShowNestedActionInfo) {
      if (widget.config.action.nestedAction.title == null)
        return const SizedBox();

      return Text(
        widget.config.action.nestedAction.title,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: widget.config.action.style,
      );
    } else {
      if (widget.config.action.title == null) return const SizedBox();
      return Text(
        widget.config.action.title,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: widget.config.action.style,
      );
    }
  }
}

class SwipeActionStore {
  static SwipeActionStore _instance;
  EventBus bus;

  static SwipeActionStore getInstance() {
    if (_instance == null) {
      _instance = SwipeActionStore();
      _instance.bus = EventBus();
    }
    return _instance;
  }
}
