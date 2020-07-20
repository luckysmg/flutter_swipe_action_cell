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
  SwipeActionButtonConfig config;
  Duration duration;
  double width;
  Alignment alignment;
  CompletionHandler handler;

  StreamSubscription pullLastButtonSubscription;
  StreamSubscription pullLastButtonToCoverCellEventSubscription;

  bool isDeleting;

  @override
  void initState() {
    super.initState();
    isDeleting = false;
    config = widget.config;
    alignment = config.isTheOnlyOne && config.fullDraggable
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
      if (config.isTheOnlyOne && config.fullDraggable) {
        alignment =
            event.isPullingOut ? Alignment.centerLeft : Alignment.centerRight;
      } else {
        alignment = Alignment.centerLeft;
      }
      if (config.action.forceAlignmentLeft) {
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
    _initOnTapAction();
  }

  void _initOnTapAction() {
    if (config.action.onTap != null) {
      handler = (delete) async {
        if (delete) {
          if (config.isLastOne) {
            SwipeActionStore.getInstance().bus.fire(
                IgnorePointerEvent(key: this.config.parentKey, ignore: true));
          }

          if (widget.config.firstActionWillCoverAllSpaceOnDeleting) {
            isDeleting = true;
            _animToCoverCell();

            ///and avoid layout jumping because of fast animation
            await Future.delayed(const Duration(milliseconds: 50));
          }
          SwipeActionStore.getInstance()
              .bus
              .fire((DeleteCellEvent(key: config.parentKey)));

          ///wait the animation to complete
          await Future.delayed(const Duration(milliseconds: 501));
        } else {
          if (widget.config.action.closeOnTap) {
            SwipeActionStore.getInstance()
                .bus
                .fire((CloseCellEvent(key: config.parentKey)));
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

  @override
  void didUpdateWidget(SwipeActionButtonWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    pullLastButtonSubscription?.cancel();
    pullLastButtonToCoverCellEventSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDeleting) {
      width = widget.config.width;
    }
    var duration = config.fullDraggable ? this.duration : const Duration();
    if (isDeleting) {
      duration = const Duration(milliseconds: 100);
    }

    return GestureDetector(
      onTap: () {
        config.action.onTap?.call(handler);
      },
      child: AnimatedContainer(
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(config.action.backgroundRadius),
              bottomLeft: Radius.circular(config.action.backgroundRadius)),
          color: config.action.color,
        ),
        duration: duration,
        padding: EdgeInsets.only(
          left: config.action.leftPadding,
          right: config.isTheOnlyOne &&
                  !(config.action.forceAlignmentLeft) &&
                  config.fullDraggable
              ? 16
              : 0,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOutQuart,
          alignment: alignment,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              config.action.icon ?? const SizedBox(),
              config.action.title != null
                  ? Text(
                      config.action.title,
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      style: config.action.style,
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
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
