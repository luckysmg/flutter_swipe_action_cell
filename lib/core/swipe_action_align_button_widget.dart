import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'events.dart';
import 'store.dart';
import 'cell.dart';
import 'swipe_data.dart';

class SwipeActionAlignButtonWidget extends StatefulWidget {
  final int actionIndex;

  const SwipeActionAlignButtonWidget({Key key, this.actionIndex})
      : super(key: key);

  @override
  _SwipeActionAlignButtonWidgetState createState() =>
      _SwipeActionAlignButtonWidgetState();
}

class _SwipeActionAlignButtonWidgetState
    extends State<SwipeActionAlignButtonWidget> with TickerProviderStateMixin {
  double offsetX;
  Alignment alignment;
  CompletionHandler handler;

  StreamSubscription pullLastButtonSubscription;
  StreamSubscription pullLastButtonToCoverCellEventSubscription;
  StreamSubscription closeNestedActionEventSubscription;

  bool whenNestedActionShowing;
  bool whenFirstAction;
  bool whenDeleting;

  SwipeData data;
  SwipeAction action;

  AnimationController offsetController;
  AnimationController widthFillActionContentController;
  AnimationController alignController;
  Animation<double> alignCurve;
  Animation<double> offsetCurve;
  Animation<double> widthFillActionContentCurve;

  Animation animation;

  bool lockAnim;

  @override
  void initState() {
    super.initState();
    whenDeleting = false;
    lockAnim = false;
    whenNestedActionShowing = false;
    whenFirstAction = widget.actionIndex == 0;
    alignment = Alignment.centerRight;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (action.forceAlignmentLeft) {
        alignment = Alignment.centerLeft;
      }
      _initAnim();
      _initCompletionHandler();
    });

    _listenEvent();
  }

  void _pullActionButton(bool isPullingOut) {
    _resetAnimationController(alignController);
    if (isPullingOut) {
      var tween = AlignmentTween(begin: alignment, end: Alignment.centerLeft)
          .animate(alignCurve);
      tween.addListener(() {
        if (lockAnim) return;
        alignment = tween.value;
        setState(() {});
      });

      alignController.forward();
    } else {
      var tween = AlignmentTween(begin: alignment, end: Alignment.centerRight)
          .animate(alignCurve);
      tween.addListener(() {
        if (lockAnim) return;
        alignment = tween.value;
        setState(() {});
      });
      alignController.forward();
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
    animation = Tween<double>(begin: offsetX, end: -data.contentWidth)
        .animate(offsetCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            setState(() {});
          });
    offsetController.forward();
  }

  void _animToCoverPullActionContent() async {
    if (action.nestedAction.nestedWidth != null) {
      try {
        assert(
            action.nestedAction.nestedWidth >= data.totalActionWidth,
            "Your nested width must be larger than the width of all action buttons"
            "\n 你的nestedWidth必须要大于或者等于所有按钮的总长度，否则下面的按钮会显现出来");
      } catch (e) {
        print(e.toString());
      }
    }

    _resetAnimationController(widthFillActionContentController);
    whenNestedActionShowing = true;
    alignment = Alignment.center;

    if (action.nestedAction?.nestedWidth != null &&
        action.nestedAction.nestedWidth > data.totalActionWidth) {
      data.parentState.adjustOffset(
          offsetX: action.nestedAction.nestedWidth,
          curve: action.nestedAction.curve);
    }

    double endOffset;
    if (action.nestedAction?.nestedWidth != null) {
      endOffset = -action.nestedAction.nestedWidth;
    } else {
      endOffset = -data.totalActionWidth;
    }

    animation = Tween<double>(begin: offsetX, end: endOffset)
        .animate(widthFillActionContentCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            alignment = Alignment.lerp(alignment, Alignment.center,
                widthFillActionContentController.value);
            setState(() {});
          });
    widthFillActionContentController.forward();
  }

  @override
  Widget build(BuildContext context) {
    data = SwipeData.of(context);
    action = data.actions[widget.actionIndex];

    final bool shouldShowNestedActionInfo = widget.actionIndex == 0 &&
        action.nestedAction != null &&
        whenNestedActionShowing;

    if (!whenNestedActionShowing && !whenDeleting) {
      offsetX = data.currentOffset;
    }

    return GestureDetector(
      onTap: () {
        if (whenFirstAction &&
            action.nestedAction != null &&
            !whenNestedActionShowing) {
          if (action.nestedAction.impactWhenShowing) {
            HapticFeedback.mediumImpact();
          }
          _animToCoverPullActionContent();
          return;
        }
        action.onTap?.call(handler);
      },
      child: Transform.translate(
        offset: Offset(data.contentWidth + offsetX, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(action.backgroundRadius),
                bottomLeft: Radius.circular(action.backgroundRadius)),
            color: action.color,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.only(left: 16, right: 16),
              alignment: alignment,
              width: -offsetX,
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
      return action.nestedAction.content;
    }

    return action.title != null || action.icon != null
        ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _buildIcon(action, shouldShowNestedActionInfo),
              _buildTitle(action, shouldShowNestedActionInfo),
            ],
          )
        : action.content;
  }

  Widget _buildIcon(SwipeAction action, bool shouldShowNestedActionInfo) {
    return shouldShowNestedActionInfo
        ? action.nestedAction.icon ?? const SizedBox()
        : action.icon ?? const SizedBox();
  }

  Widget _buildTitle(SwipeAction action, bool shouldShowNestedActionInfo) {
    if (shouldShowNestedActionInfo) {
      if (action.nestedAction.title == null) return const SizedBox();
      return Text(
        action.nestedAction.title,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: action.style,
      );
    } else {
      if (action.title == null) return const SizedBox();
      return Text(
        action.title,
        overflow: TextOverflow.clip,
        maxLines: 1,
        style: action.style,
      );
    }
  }

  @override
  void dispose() {
    offsetController?.dispose();
    alignController?.dispose();
    widthFillActionContentController?.dispose();
    pullLastButtonSubscription?.cancel();
    pullLastButtonToCoverCellEventSubscription?.cancel();
    closeNestedActionEventSubscription?.cancel();
    super.dispose();
  }

  void _initAnim() {
    offsetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));
    alignController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));

    alignCurve =
        CurvedAnimation(parent: alignController, curve: Curves.easeOutCirc);

    offsetCurve =
        CurvedAnimation(parent: offsetController, curve: Curves.easeInToLinear);

    if (widget.actionIndex == 0 && action.nestedAction != null) {
      widthFillActionContentController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 350));
      widthFillActionContentCurve = CurvedAnimation(
          parent: widthFillActionContentController,
          curve: action.nestedAction.curve);
    }
  }

  void _resetAnimationController(AnimationController controller) {
    lockAnim = true;
    controller?.value = 0;
    lockAnim = false;
  }
}
