import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'store.dart';

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

  ///Select a cell (You must pass [SwipeActionCell.index] attr to your [SwipeActionCell]
  ///选中cell （注意！！！你必须把 index 参数传入cell
  void selectCellAt({@required List<int> indexPaths}) {
    assert(
        editing,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");
    indexPaths.forEach((element) {
      selectedMap.addAll({element: true});
    });
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: true));
  }

  ///Deselect  cells  (You must pass [SwipeActionCell.index] attr to your [SwipeActionCell]
  ///选中一个cell （注意！！！你必须把 index 参数传入cell
  void deselectCellAt({@required List<int> indexPaths}) {
    assert(
        editing,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");

    indexPaths.forEach((element) {
      selectedMap.remove(element);
    });
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: false));
  }

  ///select all cell
  ///选择所有的cell
  void selectAll({@required int dataLength}) {
    assert(
        editing,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");
    for (int i = 0; i < dataLength; i++) {
      selectedMap.addAll({i: true});
    }
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: true));
  }

  ///deselect all cell
  ///取消选择所有的cell
  void deselectAll() {
    assert(
        editing,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");
    selectedMap.clear();
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: false));
  }

  void _fireEditEvent({bool editing}) {
    SwipeActionStore.getInstance().bus.fire(EditingModeEvent(editing: editing));
  }
}
