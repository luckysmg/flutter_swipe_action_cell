import 'events.dart';
import 'swipe_action_button_widget.dart';

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
    _fireEvent(editing: true);
  }

  ///stop editing
  void stopEditingMode() {
    isEditing = false;
    _fireEvent(editing: false);
  }

  ///If it is editing,stop it.
  ///If it is not editing, start it
  void toggleEditingMode() {
    isEditing = !isEditing;
    _fireEvent(editing: !this.editing);
  }

  List<int> getSelectedIndexes() {
    return List.from(selectedMap.keys);
  }

  void _fireEvent({bool editing}) {
    SwipeActionStore.getInstance().bus.fire(EditingModeEvent(editing: editing));
  }
}
