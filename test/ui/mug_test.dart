import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceiling_stare/ui/mug.dart';
import 'package:ceiling_stare/ui/tokens.dart';

void main() {
  Future<void> pumpMug(WidgetTester tester, double mg) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(child: Mug(activeMg: mg)),
      ),
    );
    await tester.pumpAndSettle();
  }

  double fill(WidgetTester tester) => tester
      .widget<AnimatedFractionallySizedBox>(
        find.byType(AnimatedFractionallySizedBox),
      )
      .heightFactor!;

  Color liquid(WidgetTester tester) {
    final box = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byType(AnimatedFractionallySizedBox),
        matching: find.byType(AnimatedContainer),
      ),
    );
    return (box.decoration as BoxDecoration).color!;
  }

  testWidgets('empty at 0 mg', (tester) async {
    await pumpMug(tester, 0);
    expect(fill(tester), 0);
  });

  testWidgets('half full at half the reference limit, in signal colour', (
    tester,
  ) async {
    await pumpMug(tester, 200);
    expect(fill(tester), 0.5);
    expect(liquid(tester), Tokens.signal);
  });

  testWidgets('full at the limit, still signal', (tester) async {
    await pumpMug(tester, 400);
    expect(fill(tester), 1);
    expect(liquid(tester), Tokens.signal);
  });

  testWidgets('past the limit it stays full and turns to alert', (
    tester,
  ) async {
    await pumpMug(tester, 650);
    expect(fill(tester), 1);
    expect(liquid(tester), Tokens.alert);
  });
}
