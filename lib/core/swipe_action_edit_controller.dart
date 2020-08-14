import 'package:flutter/cupertino.dart';

import 'events.dart';
import 'swipe_action_button_widget.dart';

///An controller to control the cell's behavior
///一个可以控制cell行为的控制器
class SwipeActionEditController {
  Map<int, bool> selectedMap = {};

  /// edit mode or not
  ///获取是否正处于编辑模式
  bool isEditing = false;

  ///Use [isEditing],Please don' t use this value to get the edit mode 's state,
  ///请用[isEditing]！！不可以通过此参数来获取编辑状态！这个是用于框架内部判断的。
  bool editing = false;

  ///start editing
  void startEditingMode() {
    isEditing = true;
    _fireEditEvent(editing: true);
  }

  ///stop editing
  void stopEditingMode() {
    isEditing = false;
    _fireEditEvent(editing: false);
  }

  ///If it is editing,stop it.
  ///If it is not editing, start it
  void toggleEditingMode() {
    isEditing = !isEditing;
    _fireEditEvent(editing: !this.editing);
  }

  List<int> getSelectedIndexes() {
    return List.from(selectedMap.keys);
  }

  ///You can call this method to close all opening cell without passing controller into cell
  ///你可以不把controller传入cell就可以直接调用这个方法
  ///用于关闭所有打开的cell
  void closeAllOpenCell() {
    SwipeActionStore.getInstance().bus.fire(CellOpenEvent(key: UniqueKey()));
  }

  void _fireEditEvent({bool editing}) {
    SwipeActionStore.getInstance().bus.fire(EditingModeEvent(editing: editing));
  }
}
