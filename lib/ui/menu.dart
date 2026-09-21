import 'package:flutter/material.dart';

import 'tokens.dart';
import 'app_theme.dart';

enum MenuDestination { history, theme }

/// The header control that opens the menu. Flat, not raised: the hard shadow
/// is reserved for the primary actions.
class MenuButton extends StatelessWidget {
  const MenuButton({super.key, required this.onTap, this.inverted = false});

  final VoidCallback onTap;

  /// For a dark band: draws in the ground colour instead of the ink colour.
  final bool inverted;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final c = inverted ? t.ground : t.ink;
    return Semantics(
      button: true,
      label: 'Menu',
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            border: Border.all(color: c, width: t.border),
          ),
          child: Text(
            'MENU',
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 1.6,
              color: c,
            ),
          ),
        ),
      ),
    );
  }
}

/// A panel dropped from the top right. Entries are numbered so it can grow
/// without being redesigned; add a [MenuDestination] and an item for each new
/// screen instead of putting another control on the home screen.
Future<MenuDestination?> showAppMenu(BuildContext context) =>
    showGeneralDialog<MenuDestination>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Close menu',
      barrierColor: context.cs.barrier,
      transitionDuration: const Duration(milliseconds: 140),
      pageBuilder: (context, _, _) => const _MenuPanel(),
      transitionBuilder: (context, animation, _, child) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween(
            begin: const Offset(0, -0.03),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
          child: child,
        ),
      ),
    );

class _MenuPanel extends StatelessWidget {
  const _MenuPanel();

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return SafeArea(
      child: Align(
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 58, 22, 0),
          child: SizedBox(
            width: 260,
            child: Material(
              type: MaterialType.transparency,
              child: Container(
                decoration: BoxDecoration(
                  color: t.ground,
                  border: Border.all(color: t.ink, width: t.border > 1 ? 2 : 1),
                  boxShadow: t.shadowOffset > 0
                      ? [
                          BoxShadow(
                            color: t.shadow,
                            offset: Offset(
                              t.shadowOffset + 2,
                              t.shadowOffset + 2,
                            ),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _MenuItem(
                      number: '01',
                      label: 'HISTORY',
                      onTap: () =>
                          Navigator.pop(context, MenuDestination.history),
                    ),
                    Container(height: 1, color: t.rule),
                    _MenuItem(
                      number: '02',
                      label: 'THEME',
                      onTap: () =>
                          Navigator.pop(context, MenuDestination.theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.number,
    required this.label,
    required this.onTap,
  });

  final String number;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                number,
                style: TextStyle(
                  fontFamily: Tokens.majorMono,
                  fontSize: 12,
                  color: t.mutedInk,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontFamily: Tokens.archivoBlack,
                  fontSize: 26,
                  letterSpacing: -0.5,
                  color: t.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
