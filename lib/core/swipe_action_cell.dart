library swipe_action_cell;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'events.dart';
import 'swipe_action.dart';
import 'swipe_action_button_widget.dart';

///
/// @created by 文景睿
/// 2020 7月13日
///

///Because the cell actions buttons are always on the right side.
///So this widget only supports to pull actions from the right side
///由于大部分应用的列表cell菜单都在右边，就做了一个从右边的拉出的，就不支持左边了（我懒^_^）
class SwipeActionCell extends StatefulWidget {
  final List<SwipeAction> actions;

  ///your content
  final Widget child;

  ///Close actions When you scroll the ListView . default value is true
  ///当你滚动（比如ListView之类的时候，这个item将会关闭拉出的actions，默认为true
  final bool closeWhenScrolling;

  ///Indicates the max width of per action button,def value is 60dp
  ///代表每个action按钮最多能拉多长,默认80dp

  ///When drag cell a long distance,it will be dismissed，
  ///and it will execute the onTap  of the first [SwipeAction]
  ///就像iOS一样，往左拉满会直接删除一样,拉满后会执行第一个 [SwipeAction] 的onTap方法
  final bool performsFirstActionWithFullSwipe;

  ///When deleting the cell
  ///the first action will cover all content size with animation.(emm.. just like iOS native effect)
  ///当删除的时候，第一个按钮会在删除动画执行的时候覆盖整个cell（ 和iOS原生动画相似 ）
  final bool firstActionWillCoverAllSpaceOnDeleting;

  const SwipeActionCell({
    Key key,
    @required this.actions,
    @required this.child,
    this.closeWhenScrolling = true,
    this.performsFirstActionWithFullSwipe = false,
    this.firstActionWillCoverAllSpaceOnDeleting = true,
  }) : super(key: key);

  @override
  _SwipeActionCellState createState() => _SwipeActionCellState();
}

class _SwipeActionCellState extends State<SwipeActionCell>
    with TickerProviderStateMixin {
  double height;
  double width;
  GlobalKey globalKey;

  int actionsCount;

  Offset currentOffset;
  double maxPullWidth;

  bool lockAnim;
  bool lastItemOut;

  AnimationController controller;
  AnimationController deleteController;
  Animation<double> animation;
  Animation<double> curvedAnim;
  Animation<double> deleteCurvedAnim;

  ScrollPosition scrollPosition;

  StreamSubscription otherCellOpenEventSubscription;
  StreamSubscription closeActionEventSubscription;
  StreamSubscription deleteCellEventSubscription;
  StreamSubscription ignorePointerSubscription;

  bool ignorePointer;

  @override
  void initState() {
    super.initState();
    globalKey = GlobalKey();
    lastItemOut = false;
    lockAnim = false;
    ignorePointer = false;
    actionsCount = widget.actions.length;
    maxPullWidth = getMaxPullWidth();

    currentOffset = Offset.zero;
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.0,
    );
    deleteController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 500),
    );
    curvedAnim =
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart);
    deleteCurvedAnim =
        CurvedAnimation(parent: deleteController, curve: Curves.easeInToLinear);

    _listenEvent();
  }

  double getMaxPullWidth() {
    double sum = 0.0;
    for (final action in widget.actions) {
      sum += action.widthSpace;
    }
    return sum;
  }

  void _listenEvent() {
    otherCellOpenEventSubscription =
        SwipeActionStore.getInstance().bus.on<CellOpenEvent>().listen((event) {
      if (event.key != this.globalKey) {
        _closeWithAnim();
      }
    });

    closeActionEventSubscription =
        SwipeActionStore.getInstance().bus.on<CloseCellEvent>().listen((event) {
      if (event.key == this.globalKey) _closeWithAnim();
    });

    deleteCellEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<DeleteCellEvent>()
        .listen((event) {
      if (event.key == this.globalKey) {
        _deleteWithAnim();
      }
    });

    ignorePointerSubscription = SwipeActionStore.getInstance()
        .bus
        .on<IgnorePointerEvent>()
        .listen((event) {
      this.ignorePointer = event.ignore;
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _removeScrollListener();
    controller.dispose();
    deleteController.dispose();
    otherCellOpenEventSubscription?.cancel();
    closeActionEventSubscription?.cancel();
    deleteCellEventSubscription?.cancel();
    ignorePointerSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateItemDimension();
    _removeScrollListener();
    _addScrollListener();
  }

  @override
  void didUpdateWidget(SwipeActionCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    actionsCount = widget.actions.length;
    maxPullWidth = getMaxPullWidth();
    _updateItemDimension();
    if (widget.closeWhenScrolling != oldWidget.closeWhenScrolling) {
      _removeScrollListener();
      _addScrollListener();
    }
    otherCellOpenEventSubscription?.cancel();
    closeActionEventSubscription?.cancel();
    _listenEvent();
  }

  void _addScrollListener() {
    if (widget.closeWhenScrolling) {
      scrollPosition = Scrollable.of(context).position;
      scrollPosition?.isScrollingNotifier?.addListener(_scrollListener);
    }
  }

  void _removeScrollListener() {
    scrollPosition?.isScrollingNotifier?.removeListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollPosition?.isScrollingNotifier?.value ?? false) {
      _closeWithAnim();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    SwipeActionStore.getInstance().bus?.fire(CellOpenEvent(this.globalKey));
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (widget.performsFirstActionWithFullSwipe) {
      _updateWithFullDraggableEffect(details);
    } else {
      _updateWithNormalEffect(details);
    }
  }

  void _updateWithFullDraggableEffect(DragUpdateDetails details) {
    if (details.delta.dx >= 0 && currentOffset.dx >= 0.0) return;
    currentOffset += Offset(details.delta.dx, 0);
    if (currentOffset.dx < -0.75 * width) {
      if (!lastItemOut) {
        SwipeActionStore.getInstance()
            .bus
            .fire(PullLastButtonEvent(isPullingOut: true));
        lastItemOut = true;
        HapticFeedback.heavyImpact();
      }
    } else {
      if (lastItemOut) {
        SwipeActionStore.getInstance()
            .bus
            .fire(PullLastButtonEvent(isPullingOut: false));
        lastItemOut = false;
        HapticFeedback.heavyImpact();
      }
    }

    ///Avoid layout jumping when scroll very fast
    if (currentOffset.dx > 0) {
      currentOffset = Offset.zero;
    }
    setState(() {});
  }

  void _updateWithNormalEffect(DragUpdateDetails details) {
    if (details.delta.dx >= 0 && currentOffset.dx >= 0.0) return;

    if (-currentOffset.dx > maxPullWidth && details.delta.dx < 0) {
      currentOffset += Offset(details.delta.dx / 8, 0);
    } else {
      currentOffset += Offset(details.delta.dx, 0);
    }

    if (currentOffset.dx < -maxPullWidth - 100) {
      currentOffset = Offset(-maxPullWidth - 100, 0);
    }

    ///Avoid layout jumping when scroll very fast
    if (currentOffset.dx > 0) {
      currentOffset = Offset.zero;
    }

    setState(() {});
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (lastItemOut && widget.performsFirstActionWithFullSwipe) {
      CompletionHandler completionHandler = (delete) async {
        if (delete) {
          SwipeActionStore.getInstance()
              .bus
              .fire(IgnorePointerEvent(key: this.globalKey, ignore: true));
          if (widget.firstActionWillCoverAllSpaceOnDeleting) {
            SwipeActionStore.getInstance()
                .bus
                .fire(PullLastButtonToCoverCellEvent(key: this.globalKey));
          }
          _deleteWithAnim();

          ///wait animation to complete
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          lastItemOut = false;
          _closeWithAnim();
        }
      };
      await widget.actions[0].onTap?.call(completionHandler);
    } else {
      if (details.velocity.pixelsPerSecond.dx < 0) {
        _openWithAnim();
        return;
      } else if (details.velocity.pixelsPerSecond.dx > 0) {
        _closeWithAnim();
        return;
      }

      if (-currentOffset.dx < maxPullWidth / 4) {
        _closeWithAnim();
      } else {
        _openWithAnim();
      }

      if (widget.actions.length == 1) {
        SwipeActionStore.getInstance()
            .bus
            .fire(PullLastButtonEvent(isPullingOut: false));
      }
    }
  }

  void _openWithAnim() {
    _resetAnimValue();
    final double startOffset = currentOffset.dx;
    animation = Tween<double>(begin: startOffset, end: -maxPullWidth)
        .animate(curvedAnim)
          ..addListener(() {
            if (lockAnim) return;
            this.currentOffset = Offset(animation.value, 0);
            setState(() {});
          });

    controller.forward();
  }

  void _closeWithAnim() async {
    _resetAnimValue();
    animation =
        Tween<double>(begin: currentOffset.dx, end: 0.0).animate(curvedAnim)
          ..addListener(() {
            if (lockAnim) return;
            this.currentOffset = Offset(animation.value, 0);
            setState(() {});
          });

    controller.forward();
  }

  void _resetAnimValue() {
    lockAnim = true;
    controller.value = 0.0;
    lockAnim = false;
  }

  void _updateItemDimension() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      height = globalKey.currentContext?.size?.height;
      width = globalKey.currentContext?.size?.width;
      setState(() {});
    });
  }

  void _deleteWithAnim() async {
    animation = Tween<double>(begin: 1.0, end: 0.01).animate(deleteCurvedAnim);
    deleteController.reverse().whenCompleteOrCancel(() {
      SwipeActionStore.getInstance()
          .bus
          .fire(IgnorePointerEvent(key: this.globalKey, ignore: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: ignorePointer,
      child: SizeTransition(
        sizeFactor: deleteCurvedAnim,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          child: Stack(
            children: <Widget>[
              Transform.translate(
                  key: globalKey,
                  offset: currentOffset,
                  transformHitTests: false,
                  child: Container(
                      width: double.infinity,
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: widget.child)),
              currentOffset.dx != 0 ? _buildActionButtons() : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final List<Widget> actionButtons =
        List.generate(widget.actions.length, (index) {
      final actualIndex = actionsCount - 1 - index;
      final action = widget.actions[actualIndex];
      bool isLastOne = index == actionsCount - 1;
      bool willPull =
          isLastOne && lastItemOut && widget.performsFirstActionWithFullSwipe;

      ///compute width
      double width;
      final currentPullWidth = currentOffset.dx.abs();
      if (willPull) {
        width = currentPullWidth;
      } else {
        double factor = currentPullWidth / maxPullWidth;
        double sumWidth = 0.0;
        for (int i = 0; i <= actualIndex; i++) {
          sumWidth += widget.actions[i].widthSpace;
        }
        width = sumWidth * factor;
      }

      SwipeActionButtonConfig config = SwipeActionButtonConfig(
          width,
          action,
          widget.performsFirstActionWithFullSwipe,
          widget.actions.length == 1,
          action.backgroundRadius,
          this.globalKey,
          widget.firstActionWillCoverAllSpaceOnDeleting,
          isLastOne);

      return SwipeActionButtonWidget(
        config: config,
      );
    });

    return SizedBox(
      height: height,
      width: double.infinity,
      child: Stack(
        overflow: Overflow.visible,
        alignment: Alignment.centerRight,
        children: actionButtons,
      ),
    );
  }
}
