import 'package:flutter/cupertino.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

/// This class is used to close opening cell when navigator change its routes.
/// 这个类是用来在路由改变的时候对打开的cell进行关闭
class SwipeActionNavigatorObserver extends NavigatorObserver {
  final SwipeActionController _controller = SwipeActionController();

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller.closeAllOpenCell();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller.closeAllOpenCell();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller.closeAllOpenCell();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _controller.closeAllOpenCell();
  }

  @override
  void didStartUserGesture(
      Route<dynamic> route, Route<dynamic>? previousRoute) {
    _controller.closeAllOpenCell();
  }

  @override
  void didStopUserGesture() {
    _controller.closeAllOpenCell();
  }
}
