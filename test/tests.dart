import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() {
  testWidgets('Actions buttons can show and hide correctly when actions update.', (tester) async {
    final GlobalKey key = GlobalKey();
    final List<SwipeAction> trailingActions = [
      SwipeAction(onTap: (handler) {}, title: "trailingAction 1"),
      SwipeAction(onTap: (handler) {}, title: "trailingAction 2"),
    ];
    final List<SwipeAction> leadingActions = [
      SwipeAction(onTap: (handler) {}, title: "leadingActions 1"),
    ];

    final SwipeActionController controller = SwipeActionController();

    // No actions. we expect to find nothing.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            SwipeActionCell(
              controller: controller,
              key: key,
              child: Container(
                color: Colors.red,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    ));

    await tester.timedDrag(
      find.byKey(key),
      const Offset(-100, 0),
      const Duration(milliseconds: 100),
    );
    expect(find.text('trailingAction 1'), findsNothing);
    expect(find.text('trailingAction 2'), findsNothing);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    await tester.timedDrag(
      find.byKey(key),
      const Offset(100, 0),
      const Duration(milliseconds: 100),
    );
    expect(find.text('leadingActions 1'), findsNothing);


    controller.closeAllOpenCell();
    await tester.pumpAndSettle();

    // Now update the trailing and leading actions, we expect to see buttons when dragging.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            SwipeActionCell(
              trailingActions: trailingActions,
              leadingActions: leadingActions,
              key: key,
              child: Container(
                color: Colors.red,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    ));
    await tester.timedDrag(
        find.byKey(key), const Offset(-100, 0), const Duration(milliseconds: 100));
    expect(find.text('trailingAction 1'), findsOneWidget);
    expect(find.text('trailingAction 2'), findsOneWidget);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    await tester.timedDrag(
        find.byKey(key), const Offset(100, 0), const Duration(milliseconds: 100));
    expect(find.text('leadingActions 1'), findsOneWidget);

    // No update the actions to null again, and we expect to see buttons.
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: ListView(
          children: [
            SwipeActionCell(
              key: key,
              child: Container(
                color: Colors.red,
                height: 200,
              ),
            ),
          ],
        ),
      ),
    ));
    await tester.timedDrag(
        find.byKey(key), const Offset(-100, 0), const Duration(milliseconds: 100));
    expect(find.text('trailingAction 1'), findsNothing);
    expect(find.text('trailingAction 2'), findsNothing);

    controller.closeAllOpenCell();
    await tester.pumpAndSettle();
    await tester.timedDrag(
        find.byKey(key), const Offset(100, 0), const Duration(milliseconds: 100));
    expect(find.text('leadingActions 1'), findsNothing);

    controller.dispose();
  });
}
