import 'package:flutter/material.dart';

import 'data/dose_repository.dart';
import 'state/dose_log.dart';
import 'ui/home_screen.dart';
import 'ui/tokens.dart';

void main() {
  runApp(const CeilingStareApp());
}

class CeilingStareApp extends StatefulWidget {
  const CeilingStareApp({
    super.key,
    this.repository,
    this.clock = DateTime.now,
  });

  /// Defaults to the on-device store. Tests pass an in-memory one.
  final DoseRepository? repository;
  final DateTime Function() clock;

  @override
  State<CeilingStareApp> createState() => _CeilingStareAppState();
}

class _CeilingStareAppState extends State<CeilingStareApp> {
  late final DoseLog _log = DoseLog(
    widget.repository ?? PrefsDoseRepository(),
    widget.clock,
  );

  @override
  void dispose() {
    _log.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ceiling Stare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: Tokens.spaceGrotesk,
        scaffoldBackgroundColor: Tokens.ground,
      ),
      home: HomeScreen(log: _log),
    );
  }
}
