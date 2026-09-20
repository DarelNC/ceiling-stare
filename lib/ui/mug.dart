import 'package:flutter/material.dart';

import '../domain/caffeine.dart';
import 'tokens.dart';

/// A mug built from bordered boxes. The liquid is the caffeine still active,
/// full at [referenceLimitMg]; it drains as the estimate decays. Past full it
/// turns to the alert colour. Marks on the left read in mg.
class Mug extends StatelessWidget {
  const Mug({super.key, required this.activeMg});

  final double activeMg;

  static const _bodyW = 108.0;
  static const _bodyH = 150.0;
  static const _wall = 3.0;
  static const _bodyLeft = 46.0;
  static const _marks = [100, 200, 300, 400];

  @override
  Widget build(BuildContext context) {
    final inner = _bodyH - _wall * 2;
    final fraction = (activeMg / referenceLimitMg).clamp(0.0, 1.0);
    final over = activeMg > referenceLimitMg;

    return Semantics(
      label: '${activeMg.round()} milligrams active',
      child: ExcludeSemantics(
        child: SizedBox(
          width: _bodyLeft + _bodyW + 36,
          height: _bodyH + Tokens.shadow * 2,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (final mark in _marks)
                Positioned(
                  left: 0,
                  bottom: _wall + inner * (mark / referenceLimitMg) - 6 + 4,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 30,
                        child: Text(
                          '$mark',
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontFamily: Tokens.majorMono,
                            fontSize: 10,
                            height: 1.2,
                            color: Tokens.mutedInk,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(width: 8, height: 2, color: Tokens.dim),
                    ],
                  ),
                ),
              // Handle sits behind the body so the body wall closes its left edge.
              Positioned(
                left: _bodyLeft + _bodyW - _wall,
                bottom: 40 + 4,
                width: 34,
                height: 66,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Tokens.ink, width: _wall),
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
                    color: Tokens.groundDeep,
                    border: Border.all(color: Tokens.ink, width: _wall),
                    boxShadow: const [
                      BoxShadow(
                        color: Tokens.rust,
                        offset: Offset(Tokens.shadow + 2, Tokens.shadow + 2),
                      ),
                    ],
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      widthFactor: 1,
                      heightFactor: fraction,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        color: over ? Tokens.alert : Tokens.signal,
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
