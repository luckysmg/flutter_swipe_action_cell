library flutter_swipe_action_cell;

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'config.dart';
import 'events.dart';
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
  ///无需多言
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
  })  : assert(key != null,
            "You should pass a key like [ValueKey] or [ObjectKey]"),

        ///关于key ！= null请看下面的注释

        super(key: key);

  ///About Key::::::
  ///You should put a key,like [ValueKey] or [ObjectKey]
  ///dont use [GlobalKey] or [UniqueKey]
  ///because that will make app slow.
  ///
  ///关于key：：：你应该在构造的时候放入key，推荐使用[ValueKey] 或者 [ObjectKey] 。
  ///最好 不要 使用[GlobalKey]和[UniqueKey]。
  ///我之前在内部也想使用[GlobalKey] 和 [UniqueKey]。
  ///但是想到有性能问题，所以需要您从外部提供轻量级的key用于我框架内部判断，同时用于
  ///flutter框架内部刷新。

  @override
  _SwipeActionCellState createState() => _SwipeActionCellState();
}

class _SwipeActionCellState extends State<SwipeActionCell>
    with TickerProviderStateMixin {
  double height;
  double width;

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
    lastItemOut = false;
    lockAnim = false;
    ignorePointer = false;
    actionsCount = widget.actions.length;
    maxPullWidth = _getMaxPullWidth();

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

  double _getMaxPullWidth() {
    double sum = 0.0;
    for (final action in widget.actions) {
      sum += action.widthSpace;
    }
    return sum;
  }

  void _listenEvent() {
    otherCellOpenEventSubscription =
        SwipeActionStore.getInstance().bus.on<CellOpenEvent>().listen((event) {
      if (event.key != widget.key) {
        _closeWithAnim();
      }
    });

    closeActionEventSubscription =
        SwipeActionStore.getInstance().bus.on<CloseCellEvent>().listen((event) {
      ///For better performance,
      ///avoid receiving this event when buttons are invisible.
      if (event.key == widget.key && currentOffset.dx != 0.0) {
        _closeWithAnim();
      }
    });

    deleteCellEventSubscription = SwipeActionStore.getInstance()
        .bus
        .on<DeleteCellEvent>()
        .listen((event) {
      if (event.key == widget.key) {
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
    _removeScrollListener();
    _addScrollListener();
  }

  @override
  void didUpdateWidget(SwipeActionCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    actionsCount = widget.actions.length;
    maxPullWidth = _getMaxPullWidth();
    if (widget.closeWhenScrolling != oldWidget.closeWhenScrolling) {
      _removeScrollListener();
      _addScrollListener();
    }
  }

  void _addScrollListener() {
    if (widget.closeWhenScrolling) {
      scrollPosition = Scrollable.of(context)?.position;
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
    SwipeActionStore.getInstance().bus?.fire(CellOpenEvent(key: widget.key));

    if (widget.actions.first.nestedAction == null) return;
    SwipeActionStore.getInstance()
        .bus
        ?.fire(CloseNestedActionEvent(key: widget.key));
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
              .fire(IgnorePointerEvent(key: widget.key, ignore: true));
          if (widget.firstActionWillCoverAllSpaceOnDeleting) {
            SwipeActionStore.getInstance()
                .bus
                .fire(PullLastButtonToCoverCellEvent(key: widget.key));
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

  void _resetAnimValue() {
    lockAnim = true;
    controller.value = 0.0;
    lockAnim = false;
  }

  void _deleteWithAnim() async {
    animation = Tween<double>(begin: 1.0, end: 0.01).animate(deleteCurvedAnim);
    deleteController.reverse().whenCompleteOrCancel(() {
      SwipeActionStore.getInstance()
          .bus
          .fire(IgnorePointerEvent(key: widget.key, ignore: false));
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
              _ContentWidget(
                onLayoutUpdate: (size) {
                  this.width = size.width;
                  this.height = size.height;
                },
                child: Transform.translate(
                    offset: currentOffset,
                    transformHitTests: false,
                    child: Container(
                        width: double.infinity,
                        color: Theme.of(context).scaffoldBackgroundColor,
                        child: widget.child)),
              ),
              currentOffset.dx == 0 ? const SizedBox() : _buildActionButtons(),
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
      double actionButtonTotalWidth;
      final currentPullWidth = currentOffset.dx.abs();
      if (willPull) {
        actionButtonTotalWidth = currentPullWidth;
      } else {
        double factor = currentPullWidth / maxPullWidth;
        double sumWidth = 0.0;
        for (int i = 0; i <= actualIndex; i++) {
          sumWidth += widget.actions[i].widthSpace;
        }
        actionButtonTotalWidth = sumWidth * factor;
      }

      SwipeActionButtonConfig config = SwipeActionButtonConfig(
          actionButtonTotalWidth,
          action,
          widget.performsFirstActionWithFullSwipe,
          widget.actions.length == 1,
          action.backgroundRadius,
          widget.key,
          widget.firstActionWillCoverAllSpaceOnDeleting,
          isLastOne,
          width,
          maxPullWidth);

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

  ///the distance between the title content and left boundary,default value is 15
  ///标题内容与action button左边界的距离，方便自定义，默认为15
  final double leftPadding;

  ///When There is one action button in menu,the alignment of content in button will be [Alignment.centerRight]
  ///If you don't want ,you can set this value to true to make it become [Alignment.centerLeft]
  ///This parameter only works when it is the first [SwipeAction]!!!!
  ///当只有一个按钮时，里面的内容会默认在右边（和iOS原生相同），但是你如果需要内容贴在左边，可以设置这个属性为true
  ///这个属性只对第一个  [SwipeAction]有用!!!!
  final bool forceAlignmentLeft;

  ///The width space this action button will take when opening.
  ///当处于打开状态下这个按钮所占的宽度
  final double widthSpace;

  ///背景颜色
  final Color color;

  ///点击事件回调
  final Function(CompletionHandler) onTap;

  ///图标
  final Widget icon;

  ///标题
  final String title;

  ///背景左上和左下的圆角
  final double backgroundRadius;

  final SwipeNestedAction nestedAction;

  const SwipeAction({
    @required this.onTap,
    this.title,
    this.style = const TextStyle(fontSize: 18, color: Colors.white),
    this.color = Colors.red,
    this.leftPadding = 15,
    this.icon,
    this.closeOnTap = true,
    this.backgroundRadius = 0.0,
    this.forceAlignmentLeft = false,
    this.widthSpace = 80,
    this.nestedAction,
  });
}

class _ContentWidget extends StatefulWidget {
  final Widget child;
  final Function(Size) onLayoutUpdate;

  const _ContentWidget({Key key, this.onLayoutUpdate, this.child})
      : super(key: key);

  @override
  __ContentWidgetState createState() => __ContentWidgetState();
}

class __ContentWidgetState extends State<_ContentWidget> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) widget.onLayoutUpdate(context.size);
    });
  }

  @override
  void didUpdateWidget(_ContentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) widget.onLayoutUpdate(context.size);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

///点击后弹出的action
class SwipeNestedAction {
  final TextStyle style;

  ///图标
  final Widget icon;

  ///标题
  final String title;

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
  final double nestedWidth;

  SwipeNestedAction({
    this.style,
    this.icon,
    this.title,
    this.nestedWidth,
  });
}
