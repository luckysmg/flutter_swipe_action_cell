import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'events.dart';
import 'store.dart';
import 'swipe_data.dart';
import 'swipe_pull_align_button.dart';
import 'swipe_pull_button.dart';

///
/// @created by 文景睿
/// 2020 年 7月13日
///

class SwipeActionCell extends StatefulWidget {
  final List<SwipeAction>? trailingActions;

  final List<SwipeAction>? leadingActions;

  ///Your content view
  ///无需多言
  final Widget child;

  ///Close actions When you scroll the ListView . default value = true
  ///当你滚动（比如ListView之类的时候，这个item将会关闭拉出的actions，默认为true
  final bool closeWhenScrolling;

  ///When drag cell a long distance,it will be dismissed，
  ///and it will execute the onTap  of the first [SwipeAction]
  ///def value = false
  ///就像iOS一样，往左拉满会直接删除一样,拉满后会执行第一个 [SwipeAction] 的onTap方法
  ///默认为false
  final bool performsFirstActionWithFullSwipe;

  ///When deleting the cell
  ///the first action will cover all content size with animation.(emm.. just like iOS native effect)
  ///def value = true
  ///当删除的时候，第一个按钮会在删除动画执行的时候覆盖整个cell（ 和iOS原生动画相似 ）
  ///默认为true
  final bool firstActionWillCoverAllSpaceOnDeleting;

  ///The controller to control edit mode
  ///控制器
  final SwipeActionController? controller;

  ///The identifier of edit mode
  ///如果你想用编辑模式，这个参数必传!!! 它的值就是你列表的itemBuilder中的index，直接传进来即可
  final int? index;

  ///When use edit mode,if you select this row,you will see this indicator on the left of the cell.
  ///（可以不传，有默认组件）当你进入编辑模式的时候，如果你选择了这一行，那么你将会在cell左边看到这个组件
  final Widget selectedIndicator;

  ///It is contrary to [selectedIndicator]
  ///（可以不传，有默认组件）和上面的相反，不说了
  final Widget unselectedIndicator;

  ///Indicates that you can swipe the cell or not
  ///代表是否能够侧滑交互(如果你只想用编辑模式而不需要侧滑）
  final bool isDraggable;

  ///Background color for cell and def value = Theme.of(context).scaffoldBackgroundColor)
  ///整个cell控件的背景色 默认是Theme.of(context).scaffoldBackgroundColor
  final Color? backgroundColor;

  ///The offset that cell will move when entering the edit mode
  ///当你进入编辑模式的时候，cell的content向右边移动的距离
  ///def value = 60
  final double editModeOffset;

  ///The factor describing how far the cell need to be swiped, for swipe to be considered "full"
  ///only valid when [performsFirstActionWithFullSwipe] = true
  ///当拖动到cell宽度 * fullSwipeFactor 的这个距离时，将会触发第一个按钮的事件
  ///注意：[performsFirstActionWithFullSwipe] 为true的时候此参数才有效
  ///def value = 0.75
  final double fullSwipeFactor;

  const SwipeActionCell({
    required Key key,
    required this.child,
    this.trailingActions,
    this.leadingActions,
    this.isDraggable = true,
    this.closeWhenScrolling = true,
    this.performsFirstActionWithFullSwipe = false,
    this.firstActionWillCoverAllSpaceOnDeleting = true,
    this.controller,
    this.index,
    this.selectedIndicator = const Icon(
      Icons.add_circle,
      color: Colors.blue,
    ),
    this.unselectedIndicator = const Icon(
      Icons.do_not_disturb_on,
      color: Colors.red,
    ),
    this.backgroundColor,
    this.editModeOffset = 60,
    this.fullSwipeFactor = 0.75,
  }) : super(key: key);

  ///About Key::::::
  ///You should put a key,like [ValueKey] or [ObjectKey]
  ///don't use [GlobalKey] or [UniqueKey]
  ///because that will make your app slow.
  ///
  ///关于key：：：你应该在构造的时候放入key，推荐使用[ValueKey] 或者 [ObjectKey] 。
  ///最好 不要 使用[GlobalKey]和[UniqueKey]。
  ///我之前在内部也想使用[GlobalKey] 和 [UniqueKey]。
  ///但是想到有性能问题，所以需要您从外部提供轻量级的key用于我框架内部判断，同时用于
  ///flutter框架内部刷新。

  @override
  SwipeActionCellState createState() => SwipeActionCellState();
}

class SwipeActionCellState extends State<SwipeActionCell>
    with TickerProviderStateMixin {
  late double height;
  late double width;

  late int trailingActionsCount;
  late int leadingActionsCount;

  late Offset currentOffset;
  late double maxTrailingPullWidth;
  late double maxLeadingPullWidth;

  bool lockAnim = false;
  bool lastItemOut = false;

  late AnimationController controller;
  late AnimationController deleteController;
  late AnimationController editController;

  late Animation<double> animation;
  late Animation<double> curvedAnim;
  late Animation<double> deleteCurvedAnim;
  late Animation<double> editCurvedAnim;

  ScrollPosition? scrollPosition;

  StreamSubscription? otherCellOpenEventSubscription;
  StreamSubscription? ignorePointerSubscription;
  StreamSubscription? changeEditingModeSubscription;
  StreamSubscription? selectedSubscription;

  bool ignorePointer = false;
  late bool editing;
  late bool selected;

  late bool hasTrailingAction;
  late bool hasLeadingAction;
  late bool whenTrailingActionShowing;
  late bool whenLeadingActionShowing;

  @override
  void initState() {
    super.initState();
    hasTrailingAction = widget.trailingActions != null;
    hasLeadingAction = widget.leadingActions != null;
    lastItemOut = false;
    lockAnim = false;
    ignorePointer = false;
    trailingActionsCount = widget.trailingActions?.length ?? 0;
    leadingActionsCount = widget.leadingActions?.length ?? 0;
    maxTrailingPullWidth = _getTrailingMaxPullWidth();
    maxLeadingPullWidth = _getLeadingMaxPullWidth();
    currentOffset = Offset.zero;

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      value: 0.0,
    );
    deleteController = AnimationController(
      vsync: this,
      value: 1.0,
      duration: const Duration(milliseconds: 400),
    );
    editController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    curvedAnim =
        CurvedAnimation(parent: controller, curve: Curves.easeOutQuart);
    deleteCurvedAnim =
        CurvedAnimation(parent: deleteController, curve: Curves.easeInToLinear);
    editCurvedAnim =
        CurvedAnimation(parent: editController, curve: Curves.linear);
    _listenEvent();
  }

  void _startEditingWithAnim() {
    lockAnim = true;
    editController.value = 0.0;
    lockAnim = false;
    animation =
        Tween<double>(begin: currentOffset.dx, end: widget.editModeOffset)
            .animate(editCurvedAnim)
              ..addListener(() {
                if (lockAnim) return;
                currentOffset = Offset(animation.value, 0);
                setState(() {});
              });
    editController.forward();
  }

  void _stopEditingWithAnim() {
    lockAnim = true;
    editController.value = 0.0;
    lockAnim = false;
    widget.controller?.selectedSet.remove(widget.index);
    animation = Tween<double>(begin: widget.editModeOffset, end: 0)
        .animate(editCurvedAnim)
          ..addListener(() {
            if (lockAnim) return;
            currentOffset = Offset(animation.value, 0);
            setState(() {});
          });
    editController.forward();
  }

  double _getTrailingMaxPullWidth() {
    if (widget.trailingActions == null) {
      return 0.0;
    }
    double sum = 0.0;

    for (final action in widget.trailingActions!) {
      sum += action.widthSpace;
    }
    return sum;
  }

  double _getLeadingMaxPullWidth() {
    if (widget.leadingActions == null) {
      return 0.0;
    }
    double sum = 0.0;
    for (final action in widget.leadingActions!) {
      sum += action.widthSpace;
    }
    return sum;
  }

  void _listenEvent() {
    selectedSubscription = SwipeActionStore.getInstance()
        .bus
        .on<CellSelectedEvent>()
        .listen((event) {
      assert(widget.controller != null && widget.index != null);

      if (event.selected &&
          widget.controller!.selectedSet.contains(widget.index)) {
        setState(() {});
      } else if (!event.selected) {
        if (selected) {
          setState(() {});
        }
      }
    });

    otherCellOpenEventSubscription =
        SwipeActionStore.getInstance().bus.on<CellOpenEvent>().listen((event) {
      if (event.key != widget.key && currentOffset.dx != 0.0) {
        closeWithAnim();
        _closeNestedAction();
      }
    });

    ignorePointerSubscription = SwipeActionStore.getInstance()
        .bus
        .on<IgnorePointerEvent>()
        .listen((event) {
      this.ignorePointer = event.ignore;
      if (mounted) setState(() {});
    });

    if (widget.controller == null) return;
    changeEditingModeSubscription = SwipeActionStore.getInstance()
        .bus
        .on<EditingModeEvent>()
        .listen((event) {
      event.editing ? _startEditingWithAnim() : _stopEditingWithAnim();
    });
  }

  void _updateControllerSelectedIndexChangedCallback({required bool selected}) {
    widget.controller?.selectedIndexPathsChangeCallback?.call(
        [widget.index!], selected, widget.controller!.selectedSet.length);
  }

  @override
  void dispose() {
    _removeScrollListener();
    controller.dispose();
    deleteController.dispose();
    editController.dispose();
    selectedSubscription?.cancel();
    otherCellOpenEventSubscription?.cancel();
    ignorePointerSubscription?.cancel();
    changeEditingModeSubscription?.cancel();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeScrollListener();
    _addScrollListener();
  }

  @override
  void didUpdateWidget(SwipeActionCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    hasTrailingAction = widget.trailingActions != null;
    hasLeadingAction = widget.leadingActions != null;
    trailingActionsCount = widget.trailingActions?.length ?? 0;
    leadingActionsCount = widget.leadingActions?.length ?? 0;
    maxTrailingPullWidth = _getTrailingMaxPullWidth();
    maxLeadingPullWidth = _getLeadingMaxPullWidth();
    if (widget.closeWhenScrolling != oldWidget.closeWhenScrolling) {
      _removeScrollListener();
      _addScrollListener();
    }
    _resetControllerWhenDidUpdate(oldWidget);
  }

  ///It mainly deal with hot reload
  void _resetControllerWhenDidUpdate(SwipeActionCell oldWidget) {
    if (oldWidget.controller != widget.controller) {
      editing = false;
      selected = false;
      if (widget.controller == null) {
        currentOffset = Offset.zero;

        ///cancel event
        changeEditingModeSubscription?.cancel();
        setState(() {});
      } else {
        changeEditingModeSubscription = SwipeActionStore.getInstance()
            .bus
            .on<EditingModeEvent>()
            .listen((event) {
          event.editing ? _startEditingWithAnim() : _stopEditingWithAnim();
        });
      }
    }
  }

  void _addScrollListener() {
    if (widget.closeWhenScrolling) {
      scrollPosition = Scrollable.of(context)?.position;
      scrollPosition?.isScrollingNotifier.addListener(_scrollListener);
    }
  }

  void _removeScrollListener() {
    scrollPosition?.isScrollingNotifier.removeListener(_scrollListener);
  }

  void _scrollListener() {
    if ((scrollPosition?.isScrollingNotifier.value ?? false) && !editing) {
      closeWithAnim();
      _closeNestedAction();
    }
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    if (editing) return;
    SwipeActionStore.getInstance().bus.fire(CellOpenEvent(key: widget.key!));
    _closeNestedAction();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    if (editing) return;
    if (!hasLeadingAction && details.delta.dx >= 0 && currentOffset.dx >= 0.0) {
      return;
    }
    if (!hasTrailingAction &&
        details.delta.dx <= 0 &&
        currentOffset.dx <= 0.0) {
      return;
    }
    if (widget.performsFirstActionWithFullSwipe) {
      _updateWithFullDraggableEffect(details);
    } else {
      _updateWithNormalEffect(details);
    }
  }

  void _updateWithFullDraggableEffect(DragUpdateDetails details) {
    currentOffset += Offset(details.delta.dx, 0);

    ///set performsFirstActionWithFullSwipe
    if (widget.performsFirstActionWithFullSwipe) {
      if (currentOffset.dx.abs() > widget.fullSwipeFactor * width) {
        if (!lastItemOut) {
          SwipeActionStore.getInstance()
              .bus
              .fire(PullLastButtonEvent(key: widget.key!, isPullingOut: true));
          lastItemOut = true;
          HapticFeedback.heavyImpact();
        }
      } else {
        if (lastItemOut) {
          SwipeActionStore.getInstance()
              .bus
              .fire(PullLastButtonEvent(key: widget.key!, isPullingOut: false));
          lastItemOut = false;
          HapticFeedback.heavyImpact();
        }
      }
    }

    if (currentOffset.dx.abs() > width) {
      if (currentOffset.dx < 0) {
        currentOffset = Offset(-width, 0);
      } else {
        currentOffset = Offset(width, 0);
      }
    }

    modifyOffsetIfOverScrolled();
    setState(() {});
  }

  void _updateWithNormalEffect(DragUpdateDetails details) {
    ///When currentOffset.dx == 0,need to exec this code to judge which direction
    if (currentOffset.dx == 0.0) {
      if (details.delta.dx < 0) {
        whenTrailingActionShowing = true;
      } else if (details.delta.dx > 0) {
        whenLeadingActionShowing = true;
      }
    }

    if (whenTrailingActionShowing) {
      if (-currentOffset.dx > maxTrailingPullWidth && details.delta.dx < 0) {
        currentOffset += Offset(details.delta.dx / 9, 0);
      } else {
        currentOffset += Offset(details.delta.dx, 0);
      }

      if (currentOffset.dx < -maxTrailingPullWidth - 100) {
        currentOffset = Offset(-maxTrailingPullWidth - 100, 0);
      }
    } else if (whenLeadingActionShowing) {
      if (currentOffset.dx > maxLeadingPullWidth && details.delta.dx > 0) {
        currentOffset += Offset(details.delta.dx / 9, 0);
      } else {
        currentOffset += Offset(details.delta.dx, 0);
      }

      if (currentOffset.dx > maxLeadingPullWidth + 100) {
        currentOffset = Offset(maxLeadingPullWidth + 100, 0);
      }
    }

    modifyOffsetIfOverScrolled();
    setState(() {});
  }

  ///modify the offset if over scrolled
  void modifyOffsetIfOverScrolled() {
    if ((!hasLeadingAction && currentOffset.dx > 0.0) ||
        (!hasTrailingAction && currentOffset.dx < 0.0)) {
      currentOffset = Offset.zero;
    }
  }

  void _onHorizontalDragEnd(DragEndDetails details) async {
    if (editing) return;

    if (lastItemOut && widget.performsFirstActionWithFullSwipe) {
      CompletionHandler completionHandler = (delete) async {
        if (delete) {
          SwipeActionStore.getInstance()
              .bus
              .fire(IgnorePointerEvent(ignore: true));
          if (widget.firstActionWillCoverAllSpaceOnDeleting) {
            SwipeActionStore.getInstance()
                .bus
                .fire(PullLastButtonToCoverCellEvent(key: widget.key!));
          }
          deleteWithAnim();

          ///wait animation to complete
          await Future.delayed(const Duration(milliseconds: 500));
        } else {
          lastItemOut = false;
          closeWithAnim();
        }
      };

      if (whenTrailingActionShowing && widget.trailingActions != null) {
        await widget.trailingActions?[0].onTap.call(completionHandler);
      } else if (whenLeadingActionShowing && widget.leadingActions != null) {
        await widget.leadingActions?[0].onTap.call(completionHandler);
      }
    } else {
      ///normal dragging update
      if (details.velocity.pixelsPerSecond.dx < 0) {
        if (!whenLeadingActionShowing && hasTrailingAction) {
          _openWithAnim(trailing: true);
        } else {
          closeWithAnim();
        }
        return;
      } else if (details.velocity.pixelsPerSecond.dx > 0) {
        if (!whenTrailingActionShowing && hasLeadingAction) {
          _openWithAnim(trailing: false);
        } else {
          closeWithAnim();
        }
        return;
      }

      if (whenTrailingActionShowing) {
        if (-currentOffset.dx < maxTrailingPullWidth / 4) {
          closeWithAnim();
        } else {
          _openWithAnim(trailing: true);
        }
      } else if (whenLeadingActionShowing) {
        if (currentOffset.dx < maxLeadingPullWidth / 4) {
          closeWithAnim();
        } else {
          _openWithAnim(trailing: false);
        }
      }

      if (trailingActionsCount == 1 || leadingActionsCount == 1) {
        SwipeActionStore.getInstance()
            .bus
            .fire(PullLastButtonEvent(isPullingOut: false));
      }
    }
  }

  ///When nestedAction is open ,adjust currentOffset if nestedWidth > currentOffset
  void adjustOffset(
      {required double offsetX, required Curve curve, required bool trailing}) {
    controller.stop();
    final adjustOffsetAnimController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    final curveAnim =
        CurvedAnimation(parent: adjustOffsetAnimController, curve: curve);

    final endOffset = trailing ? -offsetX : offsetX;
    animation = Tween<double>(begin: currentOffset.dx, end: endOffset)
        .animate(curveAnim)
          ..addListener(() {
            if (lockAnim) return;
            this.currentOffset = Offset(animation.value, 0);
            setState(() {});
          });
    adjustOffsetAnimController.forward().whenCompleteOrCancel(() {
      adjustOffsetAnimController.dispose();
    });
  }

  void _openWithAnim({required bool trailing}) {
    _resetAnimValue();
    animation = Tween<double>(
            begin: currentOffset.dx,
            end: trailing ? -maxTrailingPullWidth : maxLeadingPullWidth)
        .animate(curvedAnim)
          ..addListener(() {
            if (lockAnim) return;
            this.currentOffset = Offset(animation.value, 0);
            setState(() {});
          });

    controller.forward();
  }

  void closeWithAnim() async {
    _resetAnimValue();
    if (mounted) {
      animation =
          Tween<double>(begin: currentOffset.dx, end: 0.0).animate(curvedAnim)
            ..addListener(() {
              if (lockAnim) return;
              this.currentOffset = Offset(animation.value, 0);
              setState(() {});
            });

      controller.forward();
    }
  }

  void _closeNestedAction() {
    if (widget.trailingActions?.first.nestedAction != null ||
        widget.leadingActions?.first.nestedAction != null) {
      SwipeActionStore.getInstance()
          .bus
          .fire(CloseNestedActionEvent(key: widget.key!));
    }
  }

  void _resetAnimValue() {
    lockAnim = true;
    controller.value = 0.0;
    lockAnim = false;
  }

  void deleteWithAnim() async {
    animation = Tween<double>(begin: 1.0, end: 0.01).animate(deleteCurvedAnim)
      ..addListener(() {
        ///When quickly click the delete button,the animation will not be seen
        ///so the code below is to solve this problem....
        if (whenTrailingActionShowing) {
          currentOffset = Offset(-maxTrailingPullWidth, 0);
        } else if (whenLeadingActionShowing) {
          currentOffset = Offset(maxLeadingPullWidth, 0);
        }
      });

    deleteController.reverse().whenCompleteOrCancel(() {
      SwipeActionStore.getInstance()
          .bus
          .fire(IgnorePointerEvent(ignore: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    editing = widget.controller != null && widget.controller!.isEditing;

    if (widget.controller != null) {
      selected = widget.controller!.selectedSet.contains(widget.index);
    } else {
      selected = false;
    }

    whenTrailingActionShowing = currentOffset.dx < 0;
    whenLeadingActionShowing = currentOffset.dx > 0;

    return IgnorePointer(
      ignoring: ignorePointer,
      child: SizeTransition(
        sizeFactor: deleteCurvedAnim,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: editing && !editController.isAnimating ||
                  currentOffset.dx != 0.0
              ? () {
                  if (editing && !editController.isAnimating) {
                    assert(
                        widget.index != null,
                        "From SwipeActionCell:\nIf you want to enter edit mode,please pass the 'index' parameter in SwipeActionCell\n"
                        "=====================================================================================\n"
                        "如果你要进入编辑模式，请在SwipeActionCell中传入index 参数，他的值就是你列表组件的itemBuilder中返回的index即可");

                    if (selected) {
                      widget.controller?.selectedSet.remove(widget.index);
                      _updateControllerSelectedIndexChangedCallback(
                          selected: false);
                    } else {
                      widget.controller?.selectedSet.add(widget.index!);
                      _updateControllerSelectedIndexChangedCallback(
                          selected: true);
                    }
                    setState(() {});
                  } else if (currentOffset.dx != 0 && !controller.isAnimating) {
                    closeWithAnim();
                    _closeNestedAction();
                  }
                }
              : null,
          onHorizontalDragUpdate:
              widget.isDraggable ? _onHorizontalDragUpdate : null,
          onHorizontalDragStart:
              widget.isDraggable ? _onHorizontalDragStart : null,
          onHorizontalDragEnd: widget.isDraggable ? _onHorizontalDragEnd : null,
          child: DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              color: selected ? Colors.black.withAlpha(30) : Colors.transparent,
            ),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                width = constraints.maxWidth;
                return Stack(
                  alignment: Alignment.centerLeft,
                  children: <Widget>[
                    widget.controller != null &&
                            (widget.controller!.isEditing ||
                                editController.isAnimating)
                        ? _buildSelectedButton(selected)
                        : const SizedBox(),
                    _ContentWidget(
                      onLayoutUpdate: (size) {
                        this.height = size.height;
                      },
                      child: Transform.translate(
                        offset: editing && !editController.isAnimating
                            ? Offset(widget.editModeOffset, 0)
                            : currentOffset,
                        transformHitTests: false,
                        child: SizedBox(
                          width: double.infinity,
                          child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: widget.backgroundColor ??
                                    Theme.of(context).scaffoldBackgroundColor,
                              ),
                              child: IgnorePointer(
                                  ignoring: editController.isAnimating ||
                                      editing ||
                                      currentOffset.dx.abs() > 20,
                                  child: widget.child)),
                        ),
                      ),
                    ),
                    currentOffset.dx == 0.0 ||
                            editController.isAnimating ||
                            editing
                        ? const SizedBox()
                        : _buildTrailingActionButtons(),
                    currentOffset.dx == 0.0 ||
                            editController.isAnimating ||
                            editing
                        ? const SizedBox()
                        : _buildLeadingActionButtons(),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedButton(bool selected) {
    return Container(
      decoration: BoxDecoration(color: widget.backgroundColor),
      alignment: Alignment.center,
      width: widget.editModeOffset,
      child: selected ? widget.selectedIndicator : widget.unselectedIndicator,
    );
  }

  Widget _buildLeadingActionButtons() {
    if (currentOffset.dx < 0) {
      return const SizedBox();
    }
    final List<Widget> actionButtons =
        List.generate(leadingActionsCount, (index) {
      final actualIndex = leadingActionsCount - 1 - index;
      if (widget.leadingActions!.length == 1 &&
          !widget.leadingActions![0].forceAlignmentToBoundary &&
          widget.performsFirstActionWithFullSwipe) {
        return SwipePullAlignButton(actionIndex: actualIndex, trailing: false);
      } else {
        return SwipePullButton(actionIndex: actualIndex, trailing: false);
      }
    });

    return SwipeData(
      willPull: lastItemOut && widget.performsFirstActionWithFullSwipe,
      firstActionWillCoverAllSpaceOnDeleting:
          widget.firstActionWillCoverAllSpaceOnDeleting,
      parentKey: widget.key!,
      totalActionWidth: maxLeadingPullWidth,
      actions: widget.leadingActions!,
      contentWidth: width,
      contentHeight: height,
      currentOffset: currentOffset.dx,
      fullDraggable: widget.performsFirstActionWithFullSwipe,
      parentState: this,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: actionButtons,
        ),
      ),
    );
  }

  Widget _buildTrailingActionButtons() {
    if (currentOffset.dx > 0) {
      return const SizedBox();
    }
    final List<Widget> actionButtons =
        List.generate(trailingActionsCount, (index) {
      final actualIndex = trailingActionsCount - 1 - index;
      if (trailingActionsCount == 1 &&
          !widget.trailingActions![0].forceAlignmentToBoundary &&
          widget.performsFirstActionWithFullSwipe) {
        return SwipePullAlignButton(actionIndex: actualIndex, trailing: true);
      } else {
        return SwipePullButton(actionIndex: actualIndex, trailing: true);
      }
    });

    return SwipeData(
      willPull: lastItemOut && widget.performsFirstActionWithFullSwipe,
      firstActionWillCoverAllSpaceOnDeleting:
          widget.firstActionWillCoverAllSpaceOnDeleting,
      parentKey: widget.key!,
      totalActionWidth: maxTrailingPullWidth,
      actions: widget.trailingActions!,
      contentWidth: width,
      contentHeight: height,
      currentOffset: currentOffset.dx,
      fullDraggable: widget.performsFirstActionWithFullSwipe,
      parentState: this,
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          children: actionButtons,
        ),
      ),
    );
  }
}

///If you want the animation I support
///you should modify your data source first,then wait handler to execute,after that,
///you can call setState to update your UI.
///
///
///Code Example
///
///  initState(){
///    List list = [1,2,3,5];
///  }
///
/// onTap(handler)async {
///
///   list.removeAt(2);
///
///   await handler(true or false);
///   //true: will delete this row in ListView ,false: will not delete it
///   //Q:When to use "await"? A:The time when you want animation
///
///   setState((){});
/// }
///
typedef CompletionHandler = Function(bool);

class SwipeAction {
  ///title's text Style
  ///default value is :TextStyle(fontSize: 18,color: Colors.white)
  ///标题的字体样式,默认值在上面
  final TextStyle style;

  ///close the actions button after you tap it,default value is true
  ///点击这个按钮的时候，是否关闭actions 默认为true
  final bool closeOnTap;

  ///When you have just one button,if it is on leading/trailing,set this param to true will
  ///make the content inside button [Alignment.centerRight] / [Alignment.centerLeft]
  final bool forceAlignmentToBoundary;

  ///The width space this action button will take when opening.
  ///当处于打开状态下这个按钮所占的宽度
  final double widthSpace;

  ///bg color
  ///背景颜色
  final Color color;

  ///onTap callback
  ///点击事件回调
  final Function(CompletionHandler) onTap;

  ///图标
  final Widget? icon;

  ///标题
  final String? title;

  ///背景左上(右上）和左下（左上）的圆角
  final double backgroundRadius;

  ///嵌套的action
  final SwipeNestedAction? nestedAction;

  ///If you want to customize your content,you can use this attr.
  ///And don't set [title] and [icon] attrs
  ///如果你想自定义你的按钮内容，那么就设置这个content参数
  ///注意如果你设置了content，那么就不要设置title和icon，两个都必须为null
  final Widget? content;

  const SwipeAction({
    required this.onTap,
    this.title,
    this.style = const TextStyle(fontSize: 18, color: Colors.white),
    this.color = Colors.red,
    this.icon,
    this.closeOnTap = true,
    this.backgroundRadius = 0.0,
    this.forceAlignmentToBoundary = false,
    this.widthSpace = 80,
    this.nestedAction,
    this.content,
  });
}

class _ContentWidget extends StatefulWidget {
  final Widget child;
  final Function(Size) onLayoutUpdate;

  const _ContentWidget(
      {Key? key, required this.onLayoutUpdate, required this.child})
      : super(key: key);

  @override
  __ContentWidgetState createState() => __ContentWidgetState();
}

class __ContentWidgetState extends State<_ContentWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) widget.onLayoutUpdate(context.size!);
    });
  }

  @override
  void didUpdateWidget(_ContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      if (mounted) widget.onLayoutUpdate(context.size!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

///点击后弹出的action
class SwipeNestedAction {
  ///图标
  final Widget? icon;

  ///标题
  final String? title;

  ///normally,you dont need to set this value.When your [SwipeNestedAction] take more width than
  ///original [SwipeAction] ,you can set this value.
  /// !!!!! this value must be smaller than the sum of all buttons
  ///
  ///一般不建议设置此项，此项一般在只有一个action的时候，可能NestedAction的title比较长装不下，才需要设置这个值来调整宽度
  ///注意，如果你要设置这个值，那么这个值必须比所有按钮宽度值的总和要小，不然你可能会看到下面的按钮露出来
  ///
  ///（这个参数的作用也就是微信ios端消息列表里面，你侧滑"订阅号消息"那个cell所呈现的效果。
  ///因为弹出的"确认删除"四个字需要调整原本宽度
  ///
  final double? nestedWidth;

  ///The Animation Curve when pull the nestedAction
  ///弹出动画的曲线
  final Curve curve;

  ///是否在弹出的时候有震动（知乎app 消息页面点击删除的效果）
  final bool impactWhenShowing;

  ///You can customize your content using this attr
  ///If you want to use this attr,please don't set title and icon
  ///你可以通过这个参数来自定义你的nestAction的内容
  ///如果你要使用这个参数，请不要设置title和icon
  final Widget? content;

  SwipeNestedAction({
    this.icon,
    this.title,
    this.content,
    this.nestedWidth,
    this.curve = Curves.easeOutQuart,
    this.impactWhenShowing = false,
  });
}
