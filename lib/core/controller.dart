import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'events.dart';
import 'store.dart';

///When you tap cell under edit mode, or call the method below,this callback func will be called once:
///[SwipeActionController.selectCellAt]
///[SwipeActionController.deselectCellAt]
///[SwipeActionController.selectAll]
///[SwipeActionController.deselectAll]
///[SwipeActionController.stopEditingMode]
///
typedef SelectedIndexPathsChangeCallback = Function(
    List<int> changedIndexPaths, bool selected, int currentSelectedCount);

///An controller to control the cell's behavior
///一个可以控制cell行为的控制器
class SwipeActionController {
  SwipeActionController({this.selectedIndexPathsChangeCallback});

  Set<int> selectedSet = Set<int>();

  SelectedIndexPathsChangeCallback? selectedIndexPathsChangeCallback;

  /// edit mode or not
  ///获取是否正处于编辑模式
  final ValueNotifier<bool> isEditing = ValueNotifier<bool>(false);

  ///start editing
  void startEditingMode() {
    if (isEditing.value) {
      return;
    }
    isEditing.value = true;
    _fireEditEvent(controller: this, editing: true);
  }

  ///stop editing
  void stopEditingMode() {
    if (!isEditing.value) {
      return;
    }
    selectedIndexPathsChangeCallback?.call(List<int>.of(selectedSet), false, 0);
    selectedSet.clear();
    isEditing.value = false;
    _fireEditEvent(controller: this, editing: false);
  }

  ///If it is editing,stop it.
  ///If it is not editing, start it
  void toggleEditingMode() {
    if (isEditing.value) {
      stopEditingMode();
    } else {
      startEditingMode();
    }
  }

  ///Get the list of selected cell 's index
  ///拿到选择的cell的索引集合
  List<int> getSelectedIndexPaths({bool sorted = false}) {
    final List<int> res = List.from(selectedSet);
    if (sorted) {
      res.sort((d1, d2) {
        return d1.compareTo(d2);
      });
    }
    return res;
  }

  ///This method is called of sync internal data model.
  ///You still need to call [setState] after calling this method
  ///这个方法只是为了更新内部数据源，你仍然需要在调用这个方法之后
  ///去调用 [setState] 来更新你自己的数据源
  void deleteCellAt({required List<int> indexPaths}) {
    indexPaths.forEach((element) {
      selectedSet.remove(element);
    });
  }

  ///Open a cell programmatically
  /// 1.If cell has already opening,nothing will happen !
  /// 2.You can only open one cell,when you open cell use this method,other opening cell will close.
  /// 3.If cell is not on screen,nothing will happen !
  ///利用编程的方式打开一个cell
  /// 1. 如果cell已经打开，那么什么都不会发生！！
  /// 2.你只能在同一时刻打开一个cell，当你调用此方法进行打开cell的时候，如果那个cell已经打开，则不会做任何事情
  /// 3.如果cell不在屏幕上，什么也不会发生！！
  void openCellAt({
    required int index,
    required bool trailing,
    bool animated = true,
  }) {
    SwipeActionStore.getInstance().bus.fire(CellProgramOpenEvent(
          index: index,
          trailing: trailing,
          animated: animated,
          controller: this,
        ));
  }

  ///You can call this method to close all opening cell without passing controller into cell
  ///你可以不把controller传入cell就可以直接调用这个方法
  ///用于关闭所有打开的cell
  void closeAllOpenCell() {
    //Send a CellFingerOpenEvent with UniqueKey,so all opening cell don't have this key
    //so all of opening cell will close
    SwipeActionStore.getInstance()
        .bus
        .fire(CellFingerOpenEvent(key: UniqueKey()));
  }

  ///Select a cell (You must pass [SwipeActionCell.index] attr to your [SwipeActionCell]
  ///选中cell （注意！！！你必须把 index 参数传入cell
  void selectCellAt({required List<int> indexPaths}) {
    assert(
        isEditing.value,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");
    indexPaths.forEach((element) {
      selectedSet.add(element);
    });
    selectedIndexPathsChangeCallback?.call(
        indexPaths, true, selectedSet.length);
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: true));
  }

  ///Deselect  cells  (You must pass [SwipeActionCell.index] attr to your [SwipeActionCell]
  ///选中一个cell （注意！！！你必须把 index 参数传入cell
  void deselectCellAt({required List<int> indexPaths}) {
    assert(
        isEditing.value,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");

    indexPaths.forEach((element) {
      selectedSet.remove(element);
    });
    selectedIndexPathsChangeCallback?.call(
        indexPaths, false, selectedSet.length);
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: false));
  }

  ///select all cell
  ///选择所有的cell
  void selectAll({required int dataLength}) {
    assert(
        isEditing.value,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");

    List<int> selectedList = List.generate(dataLength, (index) => index);
    selectedSet.addAll(selectedList);
    selectedIndexPathsChangeCallback?.call(selectedList, true, dataLength);
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: true));
  }

  ///deselect all cell
  ///取消选择所有的cell
  void deselectAll() {
    assert(
        isEditing.value,
        "Please call method :selectCellAt(index)  when you are in edit mode\n"
        "请在编辑模式打开的情况下调用 selectCellAt(index)");

    final List<int> deselectedList = selectedSet.toList();
    selectedSet.clear();
    selectedIndexPathsChangeCallback?.call(
        deselectedList, false, selectedSet.length);
    SwipeActionStore.getInstance().bus.fire(CellSelectedEvent(selected: false));
  }

  void _fireEditEvent(
      {required SwipeActionController controller, required bool editing}) {
    SwipeActionStore.getInstance()
        .bus
        .fire(EditingModeEvent(controller: controller, editing: editing));
  }
}
