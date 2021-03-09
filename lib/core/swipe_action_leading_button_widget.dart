import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cell.dart';
import 'events.dart';
import 'store.dart';
import 'swipe_data.dart';

class SwipeActionLeadingButtonWidget extends StatefulWidget {
  final int actionIndex;

  const SwipeActionLeadingButtonWidget({
    Key? key,
    required this.actionIndex,
  }) : super(key: key);

  @override
  _SwipeActionButtonWidgetState createState() {
    return _SwipeActionButtonWidgetState();
  }
}

class _SwipeActionButtonWidgetState
    extends State<SwipeActionLeadingButtonWidget>
    with TickerProviderStateMixin {
  late double offsetX;
  late Alignment alignment;
  late CompletionHandler handler;

  StreamSubscription? pullLastButtonSubscription;
  StreamSubscription? pullLastButtonToCoverCellEventSubscription;
  StreamSubscription? closeNestedActionEventSubscription;

  bool whenNestedActionShowing = false;
  late bool whenFirstAction;
  bool whenActiveToOffset = false;
  bool whenPullingOut = false;
  bool whenDeleting = false;

  late SwipeData data;
  late SwipeAction action;

  late AnimationController offsetController;
  late AnimationController offsetFillActionContentController;
  late Animation<double> widthPullCurve;
  late Animation<double> offsetFillActionContentCurve;

  late Animation animation;

  bool lockAnim = false;

  @override
  void initState() {
    super.initState();
    whenFirstAction = widget.actionIndex == 0;
    alignment = Alignment.centerRight;
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      _initAnim();
      _initCompletionHandler();
    });

    _listenEvent();
  }

  void _pullActionButton(bool isPullingOut) {
    _resetAnimationController(offsetController);
    whenActiveToOffset = false;
    if (isPullingOut) {
      animation = Tween<double>(begin: offsetX, end: data.currentOffset)
          .animate(widthPullCurve)
            ..addListener(() {
              if (lockAnim) return;
              offsetX = animation.value;
              setState(() {});
            });
      offsetController.forward().whenComplete(() {
        whenActiveToOffset = true;
        whenPullingOut = true;
      });
    } else {
      final factor = data.currentOffset / data.totalActionWidth;
      double sumWidth = 0.0;
      for (int i = 0; i <= widget.actionIndex; i++) {
        sumWidth += data.actions[i].widthSpace;
      }
      final currentOffset = sumWidth * factor;
      animation = Tween<double>(begin: data.currentOffset, end: currentOffset)
          .animate(widthPullCurve)
            ..addListener(() {
              if (lockAnim) return;
              offsetX = animation.value;
              setState(() {});
            });
      offsetController.forward().whenComplete(() {
        whenActiveToOffset = true;
        whenPullingOut = false;
      });
    }
  }

  void _listenEvent() {
    ///Cell layer has judged the value of performsFirstActionWithFullSwipe
    pullLastButtonSubscription = SwipeActionStore.getInstance()
        .bus
        .on<PullLastButtonEvent>()
        .listen((event) async {
      if (event.key == data.parentKey && whenFirstAction) {
        _pullActionButton(event.isPullingOut);
      }
    });

    pullLastButtonToCoverCellEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<PullLastButtonToCoverCellEvent>()
        .listen((event) {
      if (event.key == data.parentKey) {
        _animToCoverCell();
      }
    });

    closeNestedActionEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<CloseNestedActionEvent>()
        .listen((event) {
      if (event.key == data.parentKey &&
          action.nestedAction != null &&
          whenNestedActionShowing) {
        _resetNestedAction();
      }
      if (event.key != data.parentKey && whenNestedActionShowing) {
        _resetNestedAction();
      }
    });
  }

  void _resetNestedAction() {
    whenActiveToOffset = true;
    whenNestedActionShowing = false;
    alignment = Alignment.centerRight;
    setState(() {});
  }

  void _initCompletionHandler() {
    if (action.onTap != null) {
      handler = (delete) async {
        if (delete) {
          SwipeActionStore.getInstance()
              .bus
              .fire(IgnorePointerEvent(ignore: true));

          if (data.firstActionWillCoverAllSpaceOnDeleting) {
            _animToCoverCell();

            ///and avoid layout jumping because of fast animation
            await Future.delayed(const Duration(milliseconds: 50));
          }
          data.parentState.deleteWithAnim();

          ///wait the animation to complete
          await Future.delayed(const Duration(milliseconds: 401));
        } else {
          if (action.closeOnTap) {
            data.parentState.closeWithAnim();
          }
        }
      };
    }
  }

  void _animToCoverCell() {
    whenDeleting = true;
    _resetAnimationController(offsetController);
    whenActiveToOffset = false;
    animation = Tween<double>(begin: offsetX, end: data.contentWidth)
        .animate(widthPullCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            setState(() {});
          });
    offsetController.forward();
  }

  void _animToCoverPullActionContent() async {
    if (action.nestedAction?.nestedWidth != null) {
      try {
        assert(
            action.nestedAction!.nestedWidth! >= data.totalActionWidth,
            "Your nested width must be larger than the width of all action buttons"
            "\n 你的nestedWidth必须要大于或者等于所有按钮的总长度，否则下面的按钮会显现出来");
      } catch (e) {
        print(e.toString());
      }
    }

    _resetAnimationController(offsetFillActionContentController);
    whenNestedActionShowing = true;
    alignment = Alignment.center;

    if (action.nestedAction?.nestedWidth != null &&
        action.nestedAction!.nestedWidth! > data.totalActionWidth) {
      data.parentState.adjustOffset(
          offsetX: action.nestedAction!.nestedWidth!,
          curve: action.nestedAction!.curve,
          trailing: false);
    }

    double endOffset;
    if (action.nestedAction?.nestedWidth != null) {
      endOffset = action.nestedAction!.nestedWidth!;
    } else {
      endOffset = data.totalActionWidth;
    }

    animation = Tween<double>(begin: offsetX, end: endOffset)
        .animate(offsetFillActionContentCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            setState(() {});
          });
    offsetFillActionContentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    data = SwipeData.of(context);
    action = data.actions[widget.actionIndex];
    final bool willPull = data.willPull && whenFirstAction;

    final bool shouldShowNestedActionInfo = widget.actionIndex == 0 &&
        action.nestedAction != null &&
        whenNestedActionShowing;

    if (whenActiveToOffset && !whenNestedActionShowing) {
      ///compute offset
      final currentPullOffset = data.currentOffset;
      if (willPull) {
        offsetX = data.currentOffset;
      } else {
        final factor = currentPullOffset / data.totalActionWidth;
        double sumWidth = 0.0;
        for (int i = 0; i <= widget.actionIndex; i++) {
          sumWidth += data.actions[i].widthSpace;
        }
        offsetX = sumWidth * factor;
      }
    }

    return GestureDetector(
      onTap: () {
        if (whenFirstAction &&
            action.nestedAction != null &&
            !whenNestedActionShowing) {
          if (action.nestedAction!.impactWhenShowing) {
            HapticFeedback.mediumImpact();
          }
          _animToCoverPullActionContent();
          return;
        }
        action.onTap.call(handler);
      },
      child: Transform.translate(
        offset: Offset(-data.contentWidth + offsetX, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topRight: Radius.circular(action.backgroundRadius),
                bottomRight: Radius.circular(action.backgroundRadius)),
            color: action.color,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: alignment == Alignment.center
                  ? const EdgeInsets.only()
                  : EdgeInsets.only(right: action.paddingToBoundary),
              alignment: alignment,
              width: alignment == Alignment.center ? offsetX : null,
              child: _buildButtonContent(shouldShowNestedActionInfo),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(bool shouldShowNestedActionInfo) {
    if (whenDeleting) return const SizedBox();
    if (shouldShowNestedActionInfo && action.nestedAction?.content != null) {
      return action.nestedAction!.content!;
    }

    return action.title != null || action.icon != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildIcon(action, shouldShowNestedActionInfo),
              _buildTitle(action, shouldShowNestedActionInfo),
            ],
          )
        : action.content!;
  }

  Widget _buildIcon(SwipeAction action, bool shouldShowNestedActionInfo) {
    return shouldShowNestedActionInfo
        ? action.nestedAction?.icon ?? const SizedBox()
        : action.icon ?? const SizedBox();
  }

  Widget _buildTitle(SwipeAction action, bool shouldShowNestedActionInfo) {
    if (shouldShowNestedActionInfo) {
      if (action.nestedAction?.title == null) return const SizedBox();
      return Text(
        action.nestedAction!.title!,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: action.style,
      );
    } else {
      if (action.title == null) return const SizedBox();
      return Text(
        action.title!,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: action.style,
      );
    }
  }

  @override
  void dispose() {
    offsetController.dispose();
    offsetFillActionContentController.dispose();
    pullLastButtonSubscription?.cancel();
    pullLastButtonToCoverCellEventSubscription?.cancel();
    closeNestedActionEventSubscription?.cancel();
    super.dispose();
  }

  void _initAnim() {
    offsetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));

    widthPullCurve =
        CurvedAnimation(parent: offsetController, curve: Curves.easeInToLinear);

    if (widget.actionIndex == 0 && action.nestedAction != null) {
      offsetFillActionContentController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 350));
      offsetFillActionContentCurve = CurvedAnimation(
          parent: offsetFillActionContentController,
          curve: action.nestedAction!.curve);
    }
  }

  void _resetAnimationController(AnimationController controller) {
    lockAnim = true;
    controller.value = 0;
    lockAnim = false;
  }
}
