import 'package:flutter/material.dart';

import '../state/theme_controller.dart';
import 'app_theme.dart';
import 'hard_button.dart';
import 'shared.dart';
import 'themed_background.dart';
import 'tokens.dart';

/// Every look, each drawn in its own colours with the real widgets, so the
/// choice is made by looking. Tapping one applies it to the whole app now.
class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key, required this.controller});

  final ThemeController controller;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Scaffold(
      backgroundColor: t.ground,
      body: ThemedBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
            children: [
              Row(children: [BackChip()]),
              const SizedBox(height: 26),
              ScreenTitle('THEME'),
              const SizedBox(height: 14),
              Text(
                'Tap one. It changes the whole app and is remembered.',
                style: TextStyle(
                  fontFamily: Tokens.spaceGrotesk,
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                  color: t.mutedInk,
                ),
              ),
              const SizedBox(height: 22),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => Column(
                  children: [
                    for (final option in CsThemes.all)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 22),
                        child: _ThemeCard(
                          option: option,
                          selected: option == controller.theme,
                          onTap: () => controller.select(option),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final CsTheme option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // The card is drawn in the option's own theme, whatever is active.
    return CsThemeScope(
      theme: option,
      child: Builder(
        builder: (context) {
          final t = context.cs;
          return Semantics(
            button: true,
            selected: selected,
            label: '${option.name} theme${selected ? ', in use' : ''}',
            excludeSemantics: true,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: t.ink,
                    width: selected ? 4 : (t.border > 1 ? 2 : 1),
                  ),
                  boxShadow: t.shadowOffset > 0
                      ? [
                          BoxShadow(
                            color: t.shadow,
                            offset: Offset(t.shadowOffset, t.shadowOffset),
                          ),
                        ]
                      : null,
                ),
                child: ClipRect(
                  child: ThemedBackground(
                    systemUi: false,
                    expand: false,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: _Preview(option: option, selected: selected),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({required this.option, required this.selected});

  final CsTheme option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final wall = t.border > 1 ? 3.0 : 2.0;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // A small mug: same parts as the real one.
        Container(
          width: 52,
          height: 70,
          decoration: BoxDecoration(
            color: t.mugInner,
            border: Border.all(color: t.ink, width: wall),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.45,
              widthFactor: 1,
              child: ColoredBox(color: t.signal),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      option.name.toUpperCase(),
                      style: TextStyle(
                        fontFamily: Tokens.archivoBlack,
                        fontSize: 22,
                        color: t.ink,
                      ),
                    ),
                  ),
                  if (selected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: t.signal,
                      child: Text(
                        'IN USE',
                        style: TextStyle(
                          fontFamily: Tokens.spaceGrotesk,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                          letterSpacing: 1.4,
                          color: t.onSignal,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                option.blurb,
                style: TextStyle(
                  fontFamily: Tokens.spaceGrotesk,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: t.mutedInk,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const BigNumber('70', size: 38),
                  const Spacer(),
                  // The real button, inert, so the card taps as one piece.
                  IgnorePointer(
                    child: HardButton(
                      onPressed: () {},
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                      child: Text(
                        'Coffee',
                        style: TextStyle(
                          fontFamily: Tokens.archivoBlack,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
