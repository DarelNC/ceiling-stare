import 'package:flutter/material.dart';

import '../domain/caffeine.dart';
import 'app_theme.dart';
import 'tokens.dart';

/// A mug built from bordered boxes. The liquid is the caffeine still active,
/// full at [referenceLimitMg]; it drains as the estimate decays. Past full it
/// turns to the alert colour. Marks on the left read in mg.
class Mug extends StatelessWidget {
  const Mug({super.key, required this.activeMg});

  final double activeMg;

  static const _bodyW = 108.0;
  static const _bodyH = 150.0;
  static const _bodyLeft = 46.0;
  static const _marks = [100, 200, 300, 400];

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final wall = t.border > 1 ? 3.0 : 2.0;
    final inner = _bodyH - wall * 2;
    final fraction = (activeMg / referenceLimitMg).clamp(0.0, 1.0);
    final over = activeMg > referenceLimitMg;
    final lift = t.shadowOffset;

    return Semantics(
      label: '${activeMg.round()} milligrams active',
      child: ExcludeSemantics(
        child: SizedBox(
          width: _bodyLeft + _bodyW + 36,
          height: _bodyH + 8,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final mark in _marks)
                Positioned(
                  left: 0,
                  bottom: wall + inner * (mark / referenceLimitMg) - 6 + 4,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$mark',
                          textAlign: TextAlign.right,
                          style: Tokens.readout(
                            size: 11,
                            height: 1.2,
                            color: t.mutedInk,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(width: 8, height: 2, color: t.dim),
                    ],
                  ),
                ),
              // Handle sits behind the body so the body wall closes its left edge.
              Positioned(
                left: _bodyLeft + _bodyW - wall,
                bottom: 40 + 4,
                width: 34,
                height: 66,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: t.ink, width: wall),
                  ),
                ),
              ),
              Positioned(
                left: _bodyLeft,
                bottom: 4,
                width: _bodyW,
                height: _bodyH,
                child: Container(
                  decoration: BoxDecoration(
                    color: t.mugInner,
                    border: Border.all(color: t.ink, width: wall),
                    boxShadow: lift > 0
                        ? [
                            BoxShadow(
                              color: t.shadow,
                              offset: Offset(lift + 2, lift + 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        t.mugGap,
                        0,
                        t.mugGap,
                        t.mugGap,
                      ),
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 700),
                        curve: Curves.easeOutCubic,
                        widthFactor: 1,
                        heightFactor: fraction,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          color: over ? t.alert : t.liquid,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
