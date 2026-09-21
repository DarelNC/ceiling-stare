import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/main.dart';
import 'package:ceiling_stare/ui/hard_button.dart';

import '../support/in_memory_repository.dart';

void main() {
  final now = DateTime(2026, 9, 20, 14, 30);

  Future<void> pumpApp(
    WidgetTester tester,
    dynamic repo, {
    DateTime Function()? clock,
    double height = 874,
  }) async {
    tester.view.physicalSize = Size(402 * 3, height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CeilingStareApp(repository: repo, clock: clock ?? () => now),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('boots to an empty log with every preset and Other', (
    tester,
  ) async {
    await pumpApp(tester, InMemoryDoseRepository());
    expect(find.text('CEILING STARE'), findsOneWidget);
    expect(find.text('MENU'), findsOneWidget);
    expect(find.text('SEE LOG'), findsOneWidget);
    expect(
      find.text("TODAY'S LOG"),
      findsNothing,
      reason: 'the log lives on the history screen',
    );
    expect(find.text('0 drinks'), findsOneWidget);
    for (final name in [
      'Espresso',
      'Coffee',
      'Black tea',
      'Green tea',
      'Energy drink',
      'Other',
    ]) {
      expect(find.text(name), findsOneWidget, reason: name);
    }
  });

  testWidgets('one tap on a preset logs it at the current time', (
    tester,
  ) async {
    final repo = InMemoryDoseRepository();
    await pumpApp(tester, repo);

    await tester.tap(find.text('Coffee'));
    await tester.pumpAndSettle();

    final doses = await repo.all();
    expect(doses, hasLength(1));
    expect(doses.single.mg, 95);
    expect(doses.single.source, DoseSource.coffee);
    expect(doses.single.at, now.toUtc());
    expect(find.text('1 drink'), findsOneWidget);
    expect(find.text('95 MG'), findsOneWidget); // today line
    expect(find.text('95'), findsOneWidget); // active readout, fresh dose
    expect(find.text('Logged 95 mg.'), findsOneWidget);
  });

  testWidgets('every log says what it did, and undo takes it back', (
    tester,
  ) async {
    final repo = InMemoryDoseRepository();
    await pumpApp(tester, repo);

    await tester.tap(find.text('Espresso'));
    await tester.pumpAndSettle();
    expect(find.text('Logged 63 mg.'), findsOneWidget);
    expect(await repo.all(), hasLength(1));

    await tester.tap(find.text('UNDO'));
    await tester.pumpAndSettle();
    expect(await repo.all(), isEmpty);
    expect(find.text('0 drinks'), findsOneWidget);
    expect(find.text('0'), findsOneWidget); // readout back to zero
  });

  testWidgets('Other only accepts 1 to 1000 mg', (tester) async {
    final repo = InMemoryDoseRepository();
    await pumpApp(tester, repo);
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    bool logEnabled() =>
        tester.widget<HardButton>(find.byType(HardButton).last).onPressed !=
        null;

    expect(logEnabled(), isFalse);
    for (final (text, ok) in [
      ('0', false),
      ('1', true),
      ('1000', true),
      ('1001', false),
    ]) {
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
      expect(logEnabled(), ok, reason: text);
    }

    await tester.enterText(find.byType(TextField), '150');
    await tester.pump();
    await tester.tap(find.text('LOG IT'));
    await tester.pumpAndSettle();

    final dose = (await repo.all()).single;
    expect(dose.mg, 150);
    expect(dose.source, DoseSource.custom);
  });

  testWidgets(
    "yesterday's dose still decays into the readout but not today's log",
    (tester) async {
      final yesterday = Dose.create(
        source: DoseSource.coffee,
        mg: 200,
        at: DateTime(2026, 9, 19, 22, 0), // 16.5 h before `now`
      );
      await pumpApp(tester, InMemoryDoseRepository([yesterday]));

      final expected = (200 * pow(0.5, 16.5 / 5)).round();
      expect(find.text('$expected'), findsOneWidget);
      expect(find.text('0 drinks'), findsOneWidget);
      expect(find.text('0 MG'), findsOneWidget, reason: "not in today's total");
    },
  );

  testWidgets('unreadable data shows an error and offers no logging', (
    tester,
  ) async {
    await pumpApp(tester, UnreadableDoseRepository());
    expect(find.text("CAN'T READ\nTHE SAVED LOG"), findsOneWidget);
    expect(find.text('Coffee'), findsNothing);
  });

  testWidgets('coming back to the foreground refreshes the clock', (
    tester,
  ) async {
    var current = now;
    final repo = InMemoryDoseRepository([
      Dose.create(source: DoseSource.coffee, mg: 240, at: now),
    ]);
    await pumpApp(tester, repo, clock: () => current);
    expect(find.text('240'), findsOneWidget);
    expect(find.text('1 drink'), findsOneWidget);

    // Five hours pass while suspended: no timer ticks, then the app resumes.
    current = now.add(const Duration(hours: 5));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('120'), findsOneWidget);

    // And across midnight, yesterday's dose leaves "today".
    current = DateTime(2026, 9, 21, 9);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(find.text('0 drinks'), findsOneWidget);
  });

  group('backdating', () {
    testWidgets('a chip backdates the next log once, then resets to NOW', (
      tester,
    ) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('\u221230 MIN'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Espresso'));
      await tester.pumpAndSettle();

      final doses = await repo.all();
      expect(doses, hasLength(2));
      expect(doses[0].mg, 95);
      expect(doses[0].at, now.subtract(const Duration(minutes: 30)).toUtc());
      expect(doses[1].mg, 63);
      expect(doses[1].at, now.toUtc(), reason: 'second tap is back to now');
    });

    testWidgets('backdated log says where it went and can be undone', (
      tester,
    ) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('\u22121 H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('Logged 95 mg at 1:30 PM.'), findsOneWidget);

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect(await repo.all(), isEmpty);
    });

    testWidgets('a now-log names no time', (tester) async {
      await pumpApp(tester, InMemoryDoseRepository());
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('Logged 95 mg.'), findsOneWidget);
    });

    testWidgets('a dose that lands on yesterday says so', (tester) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo, clock: () => DateTime(2026, 9, 20, 1, 0));

      await tester.tap(find.text('\u22122 H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();

      expect(find.text('Logged 95 mg at 11:00 PM yesterday.'), findsOneWidget);
      expect(find.text('0 drinks'), findsOneWidget);
      expect((await repo.all()).single.at, DateTime(2026, 9, 19, 23).toUtc());
    });

    testWidgets('choosing NOW again cancels a chip', (tester) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('\u22122 H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('NOW'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();

      expect((await repo.all()).single.at, now.toUtc());
    });

    testWidgets('PICK TIME opens a picker and applies the chosen time', (
      tester,
    ) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('PICK TIME'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK')); // accepts the initial time, 2:30 PM
      await tester.pumpAndSettle();
      expect(find.text('AT 2:30 PM'), findsOneWidget);

      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect((await repo.all()).single.at, now.toUtc());
      expect(find.text('PICK TIME'), findsOneWidget, reason: 'reset after log');
    });

    testWidgets('a chosen backdate is dropped when the app returns', (
      tester,
    ) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('\u22121 H'));
      await tester.pumpAndSettle();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect((await repo.all()).single.at, now.toUtc());
      expect(
        find.text('Logged 95 mg.'),
        findsOneWidget,
        reason: 'no time named',
      );
    });

    testWidgets('Other honours the chosen time too', (tester) async {
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo);

      await tester.tap(find.text('\u22121 H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Other'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '150');
      await tester.pump();
      await tester.tap(find.text('LOG IT'));
      await tester.pumpAndSettle();

      final dose = (await repo.all()).single;
      expect(dose.mg, 150);
      expect(dose.at, now.subtract(const Duration(hours: 1)).toUtc());
    });
  });
}
