import 'package:flutter/material.dart';

/// Shared identity tokens, copied directly from caffeinated/lib/main.dart —
/// same design system ("New Cycle", Oxblood ground), not reinterpreted.
/// See docs/rules.md.
/// Full palette (ground/deep/ink/mutedInk/dim/signal/alert/rust) lives in
/// caffeinated/lib/main.dart — only what this placeholder actually uses is
/// declared here; add the rest back as real screens need them.
class _T {
  static const ground = Color(0xFF2A0F14);
  static const ink = Color(0xFFF6EFE6);
  static const mutedInk = Color(0xFFD8B6AD);
  static const dim = Color(0xFF8F6A62);
  static const rust = Color(0xFF8C2F1B);

  static const archivoBlack = 'Archivo Black';
  static const majorMono = 'Major Mono Display';
  static const dmSerifItalic = 'DM Serif Display Italic';
  static const spaceGrotesk = 'Space Grotesk';
}

void main() {
  runApp(const WiredApp());
}

class WiredApp extends StatelessWidget {
  const WiredApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'wired',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: _T.spaceGrotesk,
        scaffoldBackgroundColor: _T.ground,
      ),
      home: const _PlaceholderScreen(),
    );
  }
}

/// Nothing built yet — this just proves the shared identity (palette, four
/// bundled fonts) is wired up correctly before any real screen exists.
class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _T.ground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'WIRED',
                style: TextStyle(
                  fontFamily: _T.majorMono,
                  color: _T.ink,
                  fontSize: 13,
                  letterSpacing: 3,
                ),
              ),
              const Spacer(),
              const Text(
                'NOTHING\nHERE YET',
                style: TextStyle(
                  fontFamily: _T.archivoBlack,
                  fontSize: 44,
                  height: 0.95,
                  letterSpacing: -1.5,
                  color: _T.ink,
                  shadows: [Shadow(color: _T.rust, offset: Offset(5, 5))],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  "that's fine.",
                  style: TextStyle(
                    fontFamily: _T.dmSerifItalic,
                    fontStyle: FontStyle.italic,
                    fontSize: 22,
                    color: _T.mutedInk,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'project scaffold only — no feature built',
                style: TextStyle(
                  fontFamily: _T.spaceGrotesk,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: _T.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
