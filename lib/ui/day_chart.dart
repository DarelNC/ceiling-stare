import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../domain/caffeine.dart';
import '../domain/history.dart';
import 'tokens.dart';
import 'app_theme.dart';

/// One bar per day, height = that day's total, with a rule at the reference
/// limit. Bars past the limit take the alert colour, matching the mug. Tap a
/// day to select it; the caller shows what the selection is.
class DayChart extends StatelessWidget {
  const DayChart({
    super.key,
    required this.days,
    required this.now,
    required this.selected,
    required this.onSelect,
  });

  final List<DayTotal> days;

  /// Only used to name days ("TODAY", "YESTERDAY") for screen readers.
  final DateTime now;
  final int selected;
  final ValueChanged<int> onSelect;

  static const _plot = 132.0;
  static const _axis = 24.0;
  static const _gutter = 30.0;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final tallest = days.fold(0, (m, d) => math.max(m, d.mg));
    // Scale to the reference limit, growing only if a day exceeds it, so the
    // rule stays at a fixed place on an ordinary week.
    final scale = math.max(referenceLimitMg, tallest).toDouble();
    final ruleY = _plot * referenceLimitMg / scale;

    return SizedBox(
      height: _plot + _axis,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // The scale mark lives in a left gutter, like the mug's, so no bar
          // can cover it.
          Positioned(
            left: 0,
            bottom: _axis + ruleY - 7,
            child: Text(
              '$referenceLimitMg',
              style: TextStyle(
                fontFamily: Tokens.majorMono,
                fontSize: 10,
                height: 1.2,
                color: t.mutedInk,
              ),
            ),
          ),
          Positioned.fill(
            left: _gutter,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: _axis + ruleY - 1,
                  child: Container(height: 2, color: t.dim),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < days.length; i++)
                      Expanded(
                        child: _Column(
                          total: days[i],
                          now: now,
                          height: _plot * days[i].mg / scale,
                          isSelected: i == selected,
                          isToday: i == days.length - 1,
                          onTap: () => onSelect(i),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.total,
    required this.now,
    required this.height,
    required this.isSelected,
    required this.isToday,
    required this.onTap,
  });

  final DayTotal total;
  final DateTime now;
  final double height;
  final bool isSelected;
  final bool isToday;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final empty = total.mg == 0;
    final over = total.mg > referenceLimitMg;
    return Semantics(
      button: true,
      selected: isSelected,
      label: '${dayLabel(total.day, now)} ${total.mg} milligrams',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2),
          child: Column(
            children: [
              SizedBox(
                height: DayChart._plot,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: empty ? 3 : height),
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOutCubic,
                    builder: (_, h, _) => Container(
                      height: h,
                      decoration: BoxDecoration(
                        color: empty
                            ? (isSelected ? t.ink : t.dim)
                            : (over ? t.alert : t.liquid),
                        // Themes whose bar fills sit close to the ground get an
                        // outline on every bar; the selected one is thicker.
                        border: !empty && (t.outlinedBars || isSelected)
                            ? Border.all(
                                color: t.ink,
                                width: isSelected ? 2 : 1,
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                weekdayInitial(total.day),
                style: TextStyle(
                  fontFamily: Tokens.spaceGrotesk,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: isSelected || isToday ? t.ink : t.dim,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
