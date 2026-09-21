import 'dart:ui' show PointMode;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';

/// Ground colour plus the theme's texture, behind a screen. The texture is
/// painted once per size and never intercepts touches.
class ThemedBackground extends StatelessWidget {
  const ThemedBackground({
    super.key,
    required this.child,
    this.systemUi = true,
    this.expand = true,
    this.overlay,
  });

  final Widget child;

  /// Set false for a preview inside another screen, so it doesn't restyle the
  /// status bar.
  final bool systemUi;

  /// Fill the space it's given (a screen). Set false to size to the child
  /// (a card inside a scrolling list).
  final bool expand;

  /// Status bar style when the top of the screen isn't the ground colour
  /// (a solid header band). Defaults to whatever suits the ground.
  final SystemUiOverlayStyle? overlay;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final body = ColoredBox(
      color: t.ground,
      child: Stack(
        fit: expand ? StackFit.expand : StackFit.loose,
        children: [
          if (t.pattern != BgPattern.none || t.frame)
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(painter: PatternPainter(t)),
                ),
              ),
            ),
          child,
        ],
      ),
    );
    if (!systemUi) return body;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value:
          overlay ??
          (t.isLight ? SystemUiOverlayStyle.dark : SystemUiOverlayStyle.light),
      child: body,
    );
  }
}

class PatternPainter extends CustomPainter {
  PatternPainter(this.t);

  final CsTheme t;

  @override
  void paint(Canvas canvas, Size size) {
    switch (t.pattern) {
      case BgPattern.none:
        break;
      case BgPattern.dots:
        final paint = Paint()
          ..color = t.patternColor
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 1.5;
        final points = <Offset>[
          for (var y = 5.0; y < size.height; y += 8)
            for (var x = 5.0; x < size.width; x += 8) Offset(x, y),
        ];
        canvas.drawPoints(PointMode.points, points, paint);
      case BgPattern.hatch:
        final paint = Paint()
          ..color = t.patternColor
          ..strokeWidth = 1;
        for (var x = -size.height; x < size.width; x += 9) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            paint,
          );
        }
      case BgPattern.blueprint:
        final minor = Paint()
          ..color = t.patternColor.withValues(alpha: 0.16)
          ..strokeWidth = 1;
        final major = Paint()
          ..color = t.patternColor.withValues(alpha: 0.32)
          ..strokeWidth = 1;
        for (var x = 0.0, i = 0; x <= size.width; x += 20, i++) {
          canvas.drawLine(
            Offset(x, 0),
            Offset(x, size.height),
            i % 5 == 0 ? major : minor,
          );
        }
        for (var y = 0.0, i = 0; y <= size.height; y += 20, i++) {
          canvas.drawLine(
            Offset(0, y),
            Offset(size.width, y),
            i % 5 == 0 ? major : minor,
          );
        }
    }
    if (t.frame) {
      canvas.drawRect(
        Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = t.patternColor.withValues(alpha: 0.7),
      );
    }
  }

  @override
  bool shouldRepaint(PatternPainter old) => old.t != t;
}
