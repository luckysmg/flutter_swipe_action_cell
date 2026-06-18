import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() {
  /// Pumps a list of [count] swipe cells (each with one trailing action) wired
  /// to [controller], and returns the keys of the cells in order.
  Future<List<GlobalKey>> pumpCells(
    WidgetTester tester,
    SwipeActionController controller, {
    int count = 1,
  }) async {
    final List<GlobalKey> keys =
        List<GlobalKey>.generate(count, (_) => GlobalKey());
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              for (int i = 0; i < count; i++)
                SwipeActionCell(
                  key: keys[i],
                  controller: controller,
                  index: i,
                  trailingActions: [
                    SwipeAction(onTap: (handler) {}, title: 'action $i'),
                  ],
                  child: Container(color: Colors.red, height: 100),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return keys;
  }

  Future<void> openCell(WidgetTester tester, Key key) async {
    await tester.timedDrag(
      find.byKey(key),
      const Offset(-100, 0),
      const Duration(milliseconds: 100),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('hasAnyOpenCell is false before any cell is opened.',
      (tester) async {
    final SwipeActionController controller = SwipeActionController();
    await pumpCells(tester, controller);

    expect(controller.hasAnyOpenCell, isFalse);

    controller.dispose();
  });

  testWidgets('hasAnyOpenCell becomes true after a cell is swiped open.',
      (tester) async {
    final SwipeActionController controller = SwipeActionController();
    final keys = await pumpCells(tester, controller);

    await openCell(tester, keys.first);
    // The trailing action is revealed, so the cell is open.
    expect(find.text('action 0'), findsOneWidget);
    expect(controller.hasAnyOpenCell, isTrue);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    controller.dispose();
  });

  testWidgets('hasAnyOpenCell becomes false again after closeAllOpenCell.',
      (tester) async {
    final SwipeActionController controller = SwipeActionController();
    final keys = await pumpCells(tester, controller);

    await openCell(tester, keys.first);
    expect(controller.hasAnyOpenCell, isTrue);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    expect(controller.hasAnyOpenCell, isFalse);

    controller.dispose();
  });

  testWidgets(
      'hasAnyOpenCell stays true while one of several open cells is closed.',
      (tester) async {
    final SwipeActionController controller = SwipeActionController();
    final keys = await pumpCells(tester, controller, count: 2);

    await openCell(tester, keys[0]);
    expect(controller.hasAnyOpenCell, isTrue);

    // Opening a second cell closes the first automatically (single-open
    // behaviour), but there is still an open cell.
    await openCell(tester, keys[1]);
    expect(controller.hasAnyOpenCell, isTrue);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    expect(controller.hasAnyOpenCell, isFalse);

    controller.dispose();
  });

  testWidgets('hasAnyOpenCell becomes false when the open cell is disposed.',
      (tester) async {
    final SwipeActionController controller = SwipeActionController();
    final keys = await pumpCells(tester, controller);

    await openCell(tester, keys.first);
    expect(controller.hasAnyOpenCell, isTrue);

    // Remove the cell from the tree without closing it first; dispose must
    // still clear it from the open-cell set.
    await tester.pumpWidget(const MaterialApp(home: Scaffold()));
    await tester.pumpAndSettle();
    expect(controller.hasAnyOpenCell, isFalse);

    controller.dispose();
  });
}
