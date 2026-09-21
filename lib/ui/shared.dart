import 'package:flutter/material.dart';

import '../data/dose.dart';
import 'tokens.dart';
import 'app_theme.dart';

String sourceLabel(DoseSource s) => switch (s) {
  DoseSource.coffee => 'Coffee',
  DoseSource.tea => 'Tea',
  DoseSource.energyDrink => 'Energy drink',
  DoseSource.custom => 'Other',
};

String formatTime(BuildContext context, DateTime at) =>
    MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(at.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

/// Flat ink bar with an UNDO action. One at a time; a new one replaces the old.
/// [onUndo] must handle its own failures (DoseLog does).
void showUndoBar(
  BuildContext context,
  String message,
  Future<void> Function() onUndo,
) {
  final t = context.cs;
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: t.ink,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w600,
            color: t.ground,
          ),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: t.ground,
          onPressed: onUndo,
        ),
      ),
    );
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key, this.color});
  final String text;

  /// Defaults to the theme's muted ink.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Text(
      text,
      style: TextStyle(
        fontFamily: Tokens.spaceGrotesk,
        fontWeight: FontWeight.w700,
        fontSize: 11,
        letterSpacing: 2.2,
        color: color ?? t.mutedInk,
      ),
    );
  }
}

/// The big numeral, drawn the way the current theme says: filled with a hard
/// shadow, on a highlighter block, hollow, or plain in the signal colour.
class BigNumber extends StatelessWidget {
  const BigNumber(this.text, {super.key, this.size = 68});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final base = TextStyle(
      fontFamily: Tokens.archivoBlack,
      fontSize: size,
      height: 1,
      letterSpacing: -size / 34,
    );
    switch (t.numberStyle) {
      case NumberStyle.shadowed:
        return Text(
          text,
          style: base.copyWith(
            color: t.ink,
            shadows: t.hardTextShadow(extra: size > 50 ? 0 : -2),
          ),
        );
      case NumberStyle.plain:
        return Text(text, style: base.copyWith(color: t.signal));
      case NumberStyle.highlight:
        return Container(
          margin: EdgeInsets.only(
            right: t.shadowOffset,
            bottom: t.shadowOffset,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: size / 7,
            vertical: size / 34,
          ),
          decoration: BoxDecoration(
            color: t.signal,
            boxShadow: t.shadowOffset > 0
                ? [
                    BoxShadow(
                      color: t.shadow,
                      offset: Offset(t.shadowOffset, t.shadowOffset),
                    ),
                  ]
                : null,
          ),
          child: Text(text, style: base.copyWith(color: t.onSignal)),
        );
    }
  }
}

class DoseRow extends StatelessWidget {
  const DoseRow({super.key, required this.dose, required this.onRemove});
  final Dose dose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final time = formatTime(context, dose.at);
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.rule)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              time,
              style: TextStyle(
                fontFamily: Tokens.majorMono,
                fontSize: 13,
                color: t.mutedInk,
              ),
            ),
          ),
          Expanded(
            child: Text(
              sourceLabel(dose.source),
              style: TextStyle(
                fontFamily: Tokens.spaceGrotesk,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: t.ink,
              ),
            ),
          ),
          Text(
            '${dose.mg} MG',
            style: TextStyle(
              fontFamily: Tokens.majorMono,
              fontSize: 13,
              color: t.ink,
            ),
          ),
          Semantics(
            container: true,
            button: true,
            label: 'Remove ${dose.mg} mg dose',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRemove,
              child: const SizedBox(
                width: 52,
                height: 52,
                child: Center(child: Cross()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two square-capped strokes; no icon font.

class Cross extends StatelessWidget {
  const Cross({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    Widget bar(double angle) => Transform.rotate(
      angle: angle,
      child: Container(width: 16, height: 2.5, color: t.mutedInk),
    );
    return SizedBox(
      width: 16,
      height: 16,
      child: Stack(
        alignment: Alignment.center,
        children: [bar(0.7853981634), bar(-0.7853981634)],
      ),
    );
  }
}

class ErrorBlock extends StatelessWidget {
  const ErrorBlock({super.key, required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CAN'T READ\nTHE SAVED LOG",
          style: TextStyle(
            fontFamily: Tokens.archivoBlack,
            fontSize: 34,
            height: 0.95,
            color: t.ink,
            shadows: t.hardTextShadow(),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Nothing was changed or deleted. Logging is paused so the stored data '
          'is not overwritten.',
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontSize: 15,
            color: t.mutedInk,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '$error',
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontSize: 12,
            color: t.dim,
          ),
        ),
      ],
    );
  }
}

/// Header control on every screen except home.
class BackChip extends StatelessWidget {
  const BackChip({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Semantics(
      button: true,
      label: 'Back',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).maybePop(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: t.ink, width: t.border),
          ),
          child: Text(
            'BACK',
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.6,
              color: t.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// The big title at the top of a sub-screen; hollow in themes that want it.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final base = const TextStyle(
      fontFamily: Tokens.archivoBlack,
      fontSize: 44,
      height: 0.95,
      letterSpacing: -1.5,
    );
    return Text(
      text,
      style: t.outlineTitle
          ? base.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 2
                ..strokeJoin = StrokeJoin.round
                ..color = t.ink,
            )
          : base.copyWith(color: t.ink, shadows: t.hardTextShadow(extra: 1)),
    );
  }
}
