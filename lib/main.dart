import 'package:flutter/material.dart';

import 'data/dose_repository.dart';
import 'ui/home_screen.dart';
import 'ui/tokens.dart';

void main() {
  runApp(const WiredApp());
}

class WiredApp extends StatelessWidget {
  const WiredApp({super.key, this.repository, this.clock = DateTime.now});

  /// Defaults to the on-device store. Tests pass an in-memory one.
  final DoseRepository? repository;
  final DateTime Function() clock;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wired',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: Tokens.spaceGrotesk,
        scaffoldBackgroundColor: Tokens.ground,
      ),
      home: HomeScreen(
        repository: repository ?? PrefsDoseRepository(),
        clock: clock,
      ),
    );
  }
}
