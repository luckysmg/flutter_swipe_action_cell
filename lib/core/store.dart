import 'bus.dart';

class SwipeActionStore {
  static SwipeActionStore? _instance;
  late SwipeActionBus bus;

  /// Cells that are currently open (action buttons showing), tracked by their
  /// State object. Maintained via [setCellOpen] from
  /// [SwipeActionCellState.currentOffset]'s setter and cleared on dispose, so it
  /// always reflects the real open/closed state (no close event needed).
  ///
  /// Kept private so external callers can't corrupt it (e.g. clear it); use
  /// [anyCellOpen] to read and [setCellOpen] to update.
  final Set<Object> _openCells = <Object>{};

  /// Whether any cell is currently open. Lets callers (e.g. a page-level
  /// swipe-to-pop gesture) close the open cell first instead of popping.
  bool get anyCellOpen => _openCells.isNotEmpty;

  /// Marks [cell] as open or closed in the global open-cell set.
  void setCellOpen(Object cell, bool open) {
    if (open) {
      _openCells.add(cell);
    } else {
      _openCells.remove(cell);
    }
  }

  static SwipeActionStore getInstance() {
    if (_instance == null) {
      _instance = SwipeActionStore();
      _instance?.bus = SwipeActionBus();
    }
    return _instance!;
  }
}
