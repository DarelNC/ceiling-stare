import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/main.dart';
import 'package:ceiling_stare/ui/day_chart.dart';
import 'package:ceiling_stare/domain/history.dart';
import 'package:ceiling_stare/ui/app_theme.dart';

import '../support/in_memory_repository.dart';

void main() {
  // 2026-09-20 is a Sunday.
  final now = DateTime(2026, 9, 20, 14, 30);

  Dose dose(int mg, DateTime at, [DoseSource s = DoseSource.coffee]) =>
      Dose.create(source: s, mg: mg, at: at);

  Future<void> pumpApp(
    WidgetTester tester,
    dynamic repo, {
    DateTime Function()? clock,
  }) async {
    tester.view.physicalSize = const Size(402 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      CeilingStareApp(repository: repo, clock: clock ?? () => now),
    );
    await tester.pumpAndSettle();
  }

  Future<void> openViaMenu(WidgetTester tester) async {
    await tester.tap(find.text('MENU'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HISTORY'));
    await tester.pumpAndSettle();
  }

  InMemoryDoseRepository seeded() => InMemoryDoseRepository([
    dose(95, DateTime(2026, 9, 20, 8)),
    dose(63, DateTime(2026, 9, 20, 12)),
    dose(80, DateTime(2026, 9, 19, 15), DoseSource.energyDrink),
    dose(47, DateTime(2026, 9, 15, 9), DoseSource.tea),
  ]);

  group('menu', () {
    testWidgets('opens from the header and lists History', (tester) async {
      await pumpApp(tester, InMemoryDoseRepository());
      expect(find.text('HISTORY'), findsNothing);

      await tester.tap(find.text('MENU'));
      await tester.pumpAndSettle();
      expect(find.text('HISTORY'), findsOneWidget);
      expect(find.text('01'), findsOneWidget);
    });

    testWidgets('closes on a tap outside without going anywhere', (
      tester,
    ) async {
      await pumpApp(tester, InMemoryDoseRepository());
      await tester.tap(find.text('MENU'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 700));
      await tester.pumpAndSettle();
      expect(find.text('HISTORY'), findsNothing);
      expect(find.text('TAP TO LOG'), findsOneWidget);
    });
  });

  group('history screen', () {
    testWidgets('groups doses by day with day totals, newest first', (
      tester,
    ) async {
      await pumpApp(tester, seeded());
      await openViaMenu(tester);

      final headers = ['TODAY', 'YESTERDAY', 'TUE 15 SEP'];
      for (final h in headers) {
        expect(find.text(h), findsWidgets, reason: h);
      }
      final ys = [
        for (final h in headers) tester.getTopLeft(find.text(h).last).dy,
      ];
      expect(ys, orderedEquals([...ys]..sort()), reason: 'newest day on top');

      expect(find.text('158 MG'), findsWidgets); // today's header total
      expect(find.text('80 MG'), findsWidgets);
      expect(find.text('Energy drink'), findsOneWidget);
      expect(find.text('Tea'), findsOneWidget);
    });

    testWidgets('SEE LOG on the home screen opens it too', (tester) async {
      await pumpApp(tester, seeded());
      await tester.tap(find.text('SEE LOG'));
      await tester.pumpAndSettle();
      expect(find.text('LAST 14 DAYS'), findsOneWidget);
    });

    testWidgets('BACK returns to the home screen', (tester) async {
      await pumpApp(tester, seeded());
      await openViaMenu(tester);
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('TAP TO LOG'), findsOneWidget);
    });

    testWidgets('empty log says so', (tester) async {
      await pumpApp(tester, InMemoryDoseRepository());
      await openViaMenu(tester);
      expect(find.text('Nothing logged yet.'), findsOneWidget);
    });

    testWidgets('a dose backdated onto yesterday is findable and removable', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      final repo = InMemoryDoseRepository();
      await pumpApp(tester, repo, clock: () => DateTime(2026, 9, 20, 1, 0));

      await tester.tap(find.text('−2 H'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      expect(find.text('Logged 95 mg at 11:00 PM yesterday.'), findsOneWidget);

      await tester.pump(const Duration(seconds: 5)); // bar (and its undo) gone
      await tester.pumpAndSettle();
      await openViaMenu(tester);
      expect(find.text('YESTERDAY'), findsWidgets);

      await tester.tap(find.bySemanticsLabel('Remove 95 mg dose'));
      await tester.pumpAndSettle();
      expect(await repo.all(), isEmpty);
      expect(find.text('Removed 95 mg.'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('remove can be undone', (tester) async {
      final semantics = tester.ensureSemantics();
      final repo = InMemoryDoseRepository([dose(95, DateTime(2026, 9, 20, 8))]);
      await pumpApp(tester, repo);
      await openViaMenu(tester);

      await tester.tap(find.bySemanticsLabel('Remove 95 mg dose'));
      await tester.pumpAndSettle();
      expect(await repo.all(), isEmpty);

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();
      expect((await repo.all()).single.mg, 95);
      semantics.dispose();
    });

    testWidgets('a removal shows on the home screen after going back', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(
        tester,
        InMemoryDoseRepository([dose(95, DateTime(2026, 9, 20, 8))]),
      );
      expect(find.text('1 drink'), findsOneWidget);
      await openViaMenu(tester);
      await tester.tap(find.bySemanticsLabel('Remove 95 mg dose'));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(find.text('0 drinks'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('a dose logged on home appears in history', (tester) async {
      await pumpApp(tester, InMemoryDoseRepository());
      await tester.tap(find.text('Coffee'));
      await tester.pumpAndSettle();
      await openViaMenu(tester);
      expect(find.text('Nothing logged yet.'), findsNothing);
      expect(find.text('Coffee'), findsOneWidget);
    });

    testWidgets('tapping a day in the chart selects it', (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester, seeded());
      await openViaMenu(tester);

      await tester.tap(find.bySemanticsLabel('YESTERDAY 80 milligrams'));
      await tester.pumpAndSettle();
      // The chart caption follows the selection.
      final caption = find.byWidgetPredicate(
        (w) => w is Text && w.data == '1 drink',
      );
      expect(caption, findsWidgets);
      expect(find.bySemanticsLabel('YESTERDAY 80 milligrams'), findsOneWidget);
      semantics.dispose();
    });

    testWidgets('unreadable data shows the error, not the log', (tester) async {
      await pumpApp(tester, UnreadableDoseRepository());
      // Home shows the error and offers neither logging nor SEE LOG, so
      // nothing on screen can write over the unreadable store.
      expect(find.text("CAN'T READ\nTHE SAVED LOG"), findsOneWidget);
      expect(find.text('SEE LOG'), findsNothing);
      expect(find.text('Coffee'), findsNothing);
    });
  });

  group('day chart', () {
    List<DayTotal> days(List<int> mgs) => [
      for (var i = 0; i < mgs.length; i++)
        DayTotal(DateTime(2026, 9, 7 + i), mgs[i], mgs[i] == 0 ? 0 : 1),
    ];

    Future<void> pumpChart(WidgetTester tester, List<int> mgs) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(22),
              child: DayChart(
                days: days(mgs),
                now: DateTime(2026, 9, 7 + mgs.length - 1, 12),
                selected: mgs.length - 1,
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    // Container keeps a plain `color` separately from a `decoration`.
    Color? colourOf(Container w) =>
        w.color ?? (w.decoration as BoxDecoration?)?.color;

    int barsColoured(WidgetTester tester, Color c) => tester
        .widgetList<Container>(find.byType(Container))
        .where((w) => colourOf(w) == c)
        .length;

    testWidgets('bars are signal, and alert only past the limit', (
      tester,
    ) async {
      await pumpChart(tester, [0, 100, 400, 401, 650]);
      expect(barsColoured(tester, CsThemes.oxblood.alert), 2); // 401 and 650
      expect(
        barsColoured(tester, CsThemes.oxblood.signal),
        2,
      ); // 100 and exactly 400
    });

    testWidgets('a day past the limit rescales the others', (tester) async {
      await pumpChart(tester, [200, 800]);
      final heights = tester
          .widgetList<Container>(find.byType(Container))
          .where(
            (w) =>
                colourOf(w) == CsThemes.oxblood.signal ||
                colourOf(w) == CsThemes.oxblood.alert,
          )
          .map((w) => w.constraints!.maxHeight)
          .toList();
      expect(heights[1] / heights[0], closeTo(4, 1e-6));
    });

    testWidgets('an empty day is a short stub, not nothing', (tester) async {
      await pumpChart(tester, [0, 0, 100]);
      // Two empty days, plus the reference rule drawn in the same colour.
      expect(barsColoured(tester, CsThemes.oxblood.dim), 3);
    });
  });
}
