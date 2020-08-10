
import 'events.dart';
import 'swipe_action_button_widget.dart';

class SwipeActionController {
  Map<int, bool> selectedMap = {};
  bool editing = false;

  ///start editing
  void startEditingMode() {
    _fireEvent(editing: true);
  }

  ///stop editing
  void stopEditingMode() {
    _fireEvent(editing: false);
  }

  ///If it is editing,stop it.
  ///If it is not editing, start it
  void toggleEditingMode() {
    _fireEvent(editing: !this.editing);
  }

  List<int> getSelectedIndexes() {
    return List.from(selectedMap.keys);
  }

  void _fireEvent({bool editing}) {
    SwipeActionStore.getInstance().bus.fire(EditingModeEvent(editing: editing));
  }
}
