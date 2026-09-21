import 'package:ceiling_stare/data/dose.dart';
import 'package:ceiling_stare/main.dart';
import 'package:ceiling_stare/state/theme_controller.dart';
import 'package:ceiling_stare/ui/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/in_memory_repository.dart';

void main() {
  final now = DateTime(2026, 9, 20, 14, 30);

  Dose dose(int mg, DateTime at, [DoseSource s = DoseSource.coffee]) =>
      Dose.create(source: s, mg: mg, at: at);

  Future<ThemeController> pumpApp(
    WidgetTester tester, {
    CsTheme theme = CsThemes.oxblood,
    InMemoryThemeStore? store,
    InMemoryDoseRepository? repo,
    Size size = const Size(402, 874),
  }) async {
    tester.view.physicalSize = Size(size.width * 3, size.height * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final controller = ThemeController(store ?? InMemoryThemeStore(), theme);
    await tester.pumpWidget(
      CeilingStareApp(
        repository: repo ?? InMemoryDoseRepository(),
        themes: controller,
        clock: () => now,
      ),
    );
    await tester.pumpAndSettle();
    addTearDown(controller.dispose);
    return controller;
  }

  Color groundOf(WidgetTester tester) =>
      tester.widget<Scaffold>(find.byType(Scaffold).first).backgroundColor!;

  Future<void> openThemeScreen(WidgetTester tester) async {
    await tester.tap(find.text('MENU'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('THEME'));
    await tester.pumpAndSettle();
  }

  group('picker', () {
    testWidgets('the menu lists Theme after History', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('MENU'));
      await tester.pumpAndSettle();
      expect(find.text('01'), findsOneWidget);
      expect(find.text('02'), findsOneWidget);
      expect(find.text('THEME'), findsOneWidget);
    });

    testWidgets('shows every theme, with the current one marked', (
      tester,
    ) async {
      await pumpApp(tester);
      await openThemeScreen(tester);
      for (final t in CsThemes.all) {
        expect(find.text(t.name.toUpperCase()), findsOneWidget, reason: t.name);
        expect(find.text(t.blurb), findsOneWidget, reason: t.name);
      }
      expect(find.text('IN USE'), findsOneWidget);
    });

    testWidgets('tapping a theme applies it everywhere and saves it', (
      tester,
    ) async {
      final store = InMemoryThemeStore();
      final controller = await pumpApp(tester, store: store);
      expect(groundOf(tester), CsThemes.oxblood.ground);
      await openThemeScreen(tester);

      await tester.tap(find.text('NEWSPRINT'));
      await tester.pumpAndSettle();
      expect(controller.theme, CsThemes.newsprint);
      expect(store.saved, 'newsprint');
      // The screen we're on restyled itself...
      expect(groundOf(tester), CsThemes.newsprint.ground);
      // ...and so did the one underneath.
      await tester.tap(find.text('BACK'));
      await tester.pumpAndSettle();
      expect(groundOf(tester), CsThemes.newsprint.ground);
      expect(find.text('CEILING STARE'), findsOneWidget);
    });

    testWidgets('the in-use marker moves with the choice', (tester) async {
      await pumpApp(tester);
      await openThemeScreen(tester);
      await tester.tap(find.text('BLUEPRINT'));
      await tester.pumpAndSettle();
      expect(find.text('IN USE'), findsOneWidget);
      final marker = tester.getCenter(find.text('IN USE')).dy;
      final card = tester.getCenter(find.text('BLUEPRINT')).dy;
      expect((marker - card).abs(), lessThan(20));
    });

    testWidgets('a saved theme is what the app opens with', (tester) async {
      final controller = await ThemeController.load(
        InMemoryThemeStore('blueprint'),
      );
      addTearDown(controller.dispose);
      tester.view.physicalSize = const Size(402 * 3, 874 * 3);
      tester.view.devicePixelRatio = 3;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        CeilingStareApp(
          repository: InMemoryDoseRepository(),
          themes: controller,
          clock: () => now,
        ),
      );
      await tester.pumpAndSettle();
      expect(groundOf(tester), CsThemes.blueprint.ground);
    });

    testWidgets('going back to the default works too', (tester) async {
      await pumpApp(tester, theme: CsThemes.blueprint);
      await openThemeScreen(tester);
      await tester.tap(find.text('OXBLOOD'));
      await tester.pumpAndSettle();
      expect(groundOf(tester), CsThemes.oxblood.ground);
    });
  });

  group('every theme lays out on every screen', () {
    // Layout overflow throws in tests, so pumping is the assertion. Includes
    // an over-limit day so the alert colours are drawn, and a small phone.
    for (final t in CsThemes.all) {
      for (final size in const [Size(402, 874), Size(360, 640)]) {
        testWidgets(
          '${t.name} at ${size.width.toInt()}x${size.height.toInt()}',
          (tester) async {
            final repo = InMemoryDoseRepository([
              for (var i = 0; i < 6; i++)
                dose(95, DateTime(2026, 9, 20, 8 + i), DoseSource.energyDrink),
              dose(150, DateTime(2026, 9, 19, 15), DoseSource.custom),
              dose(63, DateTime(2026, 9, 12, 9)),
            ]);
            await pumpApp(tester, theme: t, repo: repo, size: size);
            expect(find.text('CEILING STARE'), findsOneWidget);
            expect(groundOf(tester), t.ground);

            await tester.tap(find.text('SEE LOG'));
            await tester.pumpAndSettle();
            expect(find.text('HISTORY'), findsOneWidget);
            await tester.tap(find.text('BACK'));
            await tester.pumpAndSettle();

            await openThemeScreen(tester);
            expect(find.text('IN USE'), findsOneWidget);
            await tester.drag(
              find.byType(ListView).last,
              const Offset(0, -600),
            );
            await tester.pumpAndSettle();
          },
        );
      }
    }
  });

  group('signature elements', () {
    testWidgets('blueprint shows drawing-office labels, others do not', (
      tester,
    ) async {
      await pumpApp(tester, theme: CsThemes.blueprint);
      expect(find.text('DWG. CS-01'), findsOneWidget);
      expect(find.text('SCALE 1 : 1'), findsOneWidget);
    });

    testWidgets('no drawing labels outside blueprint', (tester) async {
      await pumpApp(tester);
      expect(find.text('DWG. CS-01'), findsNothing);
      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, theme: CsThemes.newsprint);
      expect(find.text('DWG. CS-01'), findsNothing);
    });

    testWidgets('newsprint puts today on an inverted panel', (tester) async {
      await pumpApp(tester, theme: CsThemes.newsprint);
      final panel = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) => c.color == CsThemes.newsprint.ink)
          .isNotEmpty;
      expect(panel, isTrue);
    });

    testWidgets('the big number: shadowed, highlighted, plain', (tester) async {
      Text number() => tester.widget<Text>(find.text('0').first);

      await pumpApp(tester);
      expect(number().style?.color, CsThemes.oxblood.ink);
      expect(number().style?.shadows, isNotEmpty);

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, theme: CsThemes.newsprint);
      final onBlock = tester
          .widgetList<Container>(find.byType(Container))
          .any(
            (c) =>
                (c.decoration as BoxDecoration?)?.color ==
                CsThemes.newsprint.signal,
          );
      expect(onBlock, isTrue, reason: 'highlighter block behind the number');

      await tester.pumpWidget(const SizedBox());
      await pumpApp(tester, theme: CsThemes.blueprint);
      expect(number().style?.color, CsThemes.blueprint.signal);
      expect(number().style?.shadows, anyOf(isNull, isEmpty));
    });

    testWidgets('big titles carry a shadow in oxblood and none in newsprint', (
      tester,
    ) async {
      Future<List<Shadow>?> titleShadows(CsTheme t) async {
        await tester.pumpWidget(const SizedBox());
        await pumpApp(tester, theme: t);
        await openThemeScreen(tester);
        return tester.widget<Text>(find.text('THEME').first).style?.shadows;
      }

      expect(await titleShadows(CsThemes.oxblood), isNotEmpty);
      expect(await titleShadows(CsThemes.newsprint), anyOf(isNull, isEmpty));
    });

    testWidgets('the mug liquid uses each theme liquid colour', (tester) async {
      for (final t in [CsThemes.newsprint, CsThemes.blueprint]) {
        await tester.pumpWidget(const SizedBox());
        await pumpApp(tester, theme: t);
        final liquid = tester
            .widgetList<AnimatedContainer>(find.byType(AnimatedContainer))
            .any((c) => (c.decoration as BoxDecoration?)?.color == t.liquid);
        // Empty log: the liquid box exists at zero height, in the liquid colour.
        expect(liquid, isTrue, reason: t.name);
      }
    });
  });
}
