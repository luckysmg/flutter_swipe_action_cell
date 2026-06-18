import 'bus.dart';

class SwipeActionStore {
  static SwipeActionStore? _instance;
  late SwipeActionBus bus;

  /// Cells that are currently open (offset != 0), tracked by their State object.
  /// Maintained by [SwipeActionCellState.currentOffset]'s setter and cleared on
  /// dispose, so it always reflects the real open/closed state (no event needed).
  final Set<Object> openCells = <Object>{};

  /// Whether any cell is currently open. Lets callers (e.g. a page-level
  /// swipe-to-pop gesture) close the open cell first instead of popping.
  bool get anyCellOpen => openCells.isNotEmpty;

  static SwipeActionStore getInstance() {
    if (_instance == null) {
      _instance = SwipeActionStore();
      _instance?.bus = SwipeActionBus();
    }
    return _instance!;
  }
}
