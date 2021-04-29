import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cell.dart';
import 'events.dart';
import 'store.dart';
import 'swipe_data.dart';

///The normal swipe action button
class SwipePullButton extends StatefulWidget {
  final int actionIndex;
  final bool trailing;

  const SwipePullButton({
    Key? key,
    required this.actionIndex,
    required this.trailing,
  }) : super(key: key);

  @override
  _SwipePullButtonState createState() {
    return _SwipePullButtonState();
  }
}

class _SwipePullButtonState extends State<SwipePullButton>
    with TickerProviderStateMixin {
  ///The cell's total offset,not button's
  late double offsetX;

  late Alignment alignment;
  late CompletionHandler handler;

  StreamSubscription? pullLastButtonSubscription;
  StreamSubscription? pullLastButtonToCoverCellEventSubscription;
  StreamSubscription? closeNestedActionEventSubscription;

  bool whenActiveToOffset = true;
  bool whenNestedActionShowing = false;
  bool whenFirstAction = false;
  bool whenPullingOut = false;
  bool whenDeleting = false;

  late SwipeData data;
  late SwipeAction action;

  AnimationController? offsetController;
  AnimationController? offsetFillActionContentController;
  late Animation<double> widthPullCurve;
  late Animation<double> offsetFillActionContentCurve;

  late Animation animation;

  bool lockAnim = false;

  bool get trailing => widget.trailing;

  @override
  void initState() {
    super.initState();
    lockAnim = false;
    whenNestedActionShowing = false;
    whenFirstAction = widget.actionIndex == 0;
    alignment = trailing ? Alignment.centerLeft : Alignment.centerRight;
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
      offsetController?.forward().whenComplete(() {
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
      offsetController?.forward().whenComplete(() {
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
    alignment = trailing ? Alignment.centerLeft : Alignment.centerRight;
    setState(() {});
  }

  void _initCompletionHandler() {
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

        ///wait the animation to complete
        await data.parentState.deleteWithAnim();
      } else {
        if (action.closeOnTap) {
          _resetNestedAction();
          await data.parentState.closeWithAnim();
        }
      }
    };
  }

  void _animToCoverCell() {
    whenDeleting = true;
    _resetAnimationController(offsetController);
    whenActiveToOffset = false;
    animation = Tween<double>(
            begin: offsetX,
            end: widget.trailing ? -data.contentWidth : data.contentWidth)
        .animate(widthPullCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            setState(() {});
          });
    offsetController?.forward();
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
          trailing: widget.trailing);
    }

    double endOffset;
    if (action.nestedAction?.nestedWidth != null) {
      endOffset = trailing
          ? -action.nestedAction!.nestedWidth!
          : action.nestedAction!.nestedWidth!;
    } else {
      endOffset = trailing ? -data.totalActionWidth : data.totalActionWidth;
    }

    animation = Tween<double>(begin: offsetX, end: endOffset)
        .animate(offsetFillActionContentCurve)
          ..addListener(() {
            if (lockAnim) return;
            offsetX = animation.value;
            setState(() {});
          });
    offsetFillActionContentController?.forward();
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
        offset: Offset((trailing ? 1 : -1) * data.contentWidth + offsetX, 0),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(action.backgroundRadius),
            color: action.color,
          ),
          child: Align(
            alignment: trailing ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
                alignment: Alignment.center,
                width: shouldShowNestedActionInfo
                    ? offsetX.abs()
                    : action.widthSpace,
                child: _buildButtonContent(shouldShowNestedActionInfo)),
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
        : action.content ?? const SizedBox();
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
    offsetController?.dispose();
    offsetFillActionContentController?.dispose();
    pullLastButtonSubscription?.cancel();
    pullLastButtonToCoverCellEventSubscription?.cancel();
    closeNestedActionEventSubscription?.cancel();
    super.dispose();
  }

  void _initAnim() {
    offsetController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 60));

    widthPullCurve = CurvedAnimation(
        parent: offsetController!, curve: Curves.easeInToLinear);

    if (widget.actionIndex == 0) {
      offsetFillActionContentController = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 350));
      offsetFillActionContentCurve = CurvedAnimation(
          parent: offsetFillActionContentController!,
          curve: action.nestedAction?.curve ?? Curves.easeOutQuart);
    }
  }

  void _resetAnimationController(AnimationController? controller) {
    lockAnim = true;
    controller?.value = 0;
    lockAnim = false;
  }
}
