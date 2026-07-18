import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_swipe_action_cell/flutter_swipe_action_cell.dart';

void main() {
  // Regression test for issue #81: the child's overflow (e.g. an elevation
  // shadow) must not be clipped at the cell's top/bottom boundaries. The cell
  // lays out its content and action buttons inside a Stack; that Stack must not
  // clip so the child can paint beyond the cell bounds.
  testWidgets(
      'SwipeActionCell does not clip its content (allows shadow overflow).',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              SwipeActionCell(
                key: const ValueKey('cell'),
                trailingActions: [
                  SwipeAction(onTap: (handler) {}, title: 'delete'),
                ],
                child: Container(color: Colors.red, height: 100),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // The only Stack inside the closed cell is the layout Stack that wraps the
    // content and (hidden) action buttons.
    final Iterable<Stack> stacks = tester.widgetList<Stack>(
      find.descendant(
        of: find.byType(SwipeActionCell),
        matching: find.byType(Stack),
      ),
    );

    expect(stacks, isNotEmpty);
    for (final Stack stack in stacks) {
      expect(
        stack.clipBehavior,
        Clip.none,
        reason: 'The cell layout Stack must not clip the child overflow.',
      );
    }
  });
}
