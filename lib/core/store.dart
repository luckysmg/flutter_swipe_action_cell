import 'bus.dart';

class SwipeActionStore {
  static SwipeActionStore? _instance;
  late SwipeActionBus bus;

  static SwipeActionStore getInstance() {
    if (_instance == null) {
      _instance = SwipeActionStore();
      _instance?.bus = SwipeActionBus();
    }
    return _instance!;
  }
}
