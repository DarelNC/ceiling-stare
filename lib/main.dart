import 'package:flutter/material.dart';

import 'data/dose_repository.dart';
import 'state/dose_log.dart';
import 'state/theme_controller.dart';
import 'ui/app_theme.dart';
import 'ui/home_screen.dart';
import 'ui/tokens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Read the saved theme first so the app never flashes the default.
  final themes = await ThemeController.load(PrefsThemeStore());
  runApp(CeilingStareApp(themes: themes));
}

class CeilingStareApp extends StatefulWidget {
  const CeilingStareApp({
    super.key,
    this.repository,
    this.themes,
    this.clock = DateTime.now,
  });

  /// Defaults to the on-device store. Tests pass an in-memory one.
  final DoseRepository? repository;

  /// The caller owns it when given. Defaults to the default theme, saved to
  /// the device.
  final ThemeController? themes;
  final DateTime Function() clock;

  @override
  State<CeilingStareApp> createState() => _CeilingStareAppState();
}

class _CeilingStareAppState extends State<CeilingStareApp> {
  late final DoseLog _log = DoseLog(
    widget.repository ?? PrefsDoseRepository(),
    widget.clock,
  );
  late final ThemeController _themes =
      widget.themes ?? ThemeController(PrefsThemeStore());

  @override
  void dispose() {
    _log.dispose();
    if (widget.themes == null) _themes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themes,
      builder: (context, _) {
        final t = _themes.theme;
        return CsThemeScope(
          theme: t,
          child: MaterialApp(
            title: 'Ceiling Stare',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              brightness: t.brightness,
              fontFamily: Tokens.spaceGrotesk,
              scaffoldBackgroundColor: t.ground,
            ),
            home: HomeScreen(log: _log, themes: _themes),
          ),
        );
      },
    );
  }
}
