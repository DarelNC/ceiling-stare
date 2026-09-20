import 'package:flutter/material.dart';

import '../data/dose.dart';
import 'tokens.dart';

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
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Tokens.ink,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: const RoundedRectangleBorder(),
        duration: const Duration(seconds: 4),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w600,
            color: Tokens.ground,
          ),
        ),
        action: SnackBarAction(
          label: 'UNDO',
          textColor: Tokens.ground,
          onPressed: onUndo,
        ),
      ),
    );
}

class Label extends StatelessWidget {
  const Label(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontFamily: Tokens.spaceGrotesk,
      fontWeight: FontWeight.w700,
      fontSize: 11,
      letterSpacing: 2.2,
      color: Tokens.mutedInk,
    ),
  );
}

class DoseRow extends StatelessWidget {
  const DoseRow({super.key, required this.dose, required this.onRemove});
  final Dose dose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final time = formatTime(context, dose.at);
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Tokens.rust)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 92,
            child: Text(
              time,
              style: const TextStyle(
                fontFamily: Tokens.majorMono,
                fontSize: 13,
                color: Tokens.mutedInk,
              ),
            ),
          ),
          Expanded(
            child: Text(
              sourceLabel(dose.source),
              style: const TextStyle(
                fontFamily: Tokens.spaceGrotesk,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Tokens.ink,
              ),
            ),
          ),
          Text(
            '${dose.mg} MG',
            style: const TextStyle(
              fontFamily: Tokens.majorMono,
              fontSize: 13,
              color: Tokens.ink,
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
    Widget bar(double angle) => Transform.rotate(
      angle: angle,
      child: Container(width: 16, height: 2.5, color: Tokens.mutedInk),
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
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        "CAN'T READ\nTHE SAVED LOG",
        style: TextStyle(
          fontFamily: Tokens.archivoBlack,
          fontSize: 34,
          height: 0.95,
          color: Tokens.ink,
          shadows: [Shadow(color: Tokens.rust, offset: Offset(4, 4))],
        ),
      ),
      const SizedBox(height: 14),
      const Text(
        'Nothing was changed or deleted. Logging is paused so the stored data '
        'is not overwritten.',
        style: TextStyle(
          fontFamily: Tokens.spaceGrotesk,
          fontSize: 15,
          color: Tokens.mutedInk,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        '$error',
        style: const TextStyle(
          fontFamily: Tokens.spaceGrotesk,
          fontSize: 12,
          color: Tokens.dim,
        ),
      ),
    ],
  );
}
