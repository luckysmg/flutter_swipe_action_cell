import 'bus.dart';

class SwipeActionStore {
  static SwipeActionStore _instance;
  SwipeActionBus bus;

  static SwipeActionStore getInstance() {
    if (_instance == null) {
      _instance = SwipeActionStore();
      _instance.bus = SwipeActionBus();
    }
    return _instance;
  }
}
