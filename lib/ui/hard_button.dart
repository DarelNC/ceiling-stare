import 'package:flutter/material.dart';

import 'app_theme.dart';

/// Bordered box with a hard offset shadow (when the theme has one). Pressing
/// it flattens onto the shadow and flashes the signal colour. Null
/// [onPressed] renders it inert.
class HardButton extends StatefulWidget {
  const HardButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding = const EdgeInsets.fromLTRB(14, 12, 14, 12),
  });

  final VoidCallback? onPressed;
  final Widget child;
  final EdgeInsets padding;

  @override
  State<HardButton> createState() => _HardButtonState();
}

class _HardButtonState extends State<HardButton> {
  bool _down = false;

  void _set(bool down) {
    if (_down != down) setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final enabled = widget.onPressed != null;
    final down = _down && enabled;
    // Themes without a shadow still move a little so a press is felt.
    final travel = t.shadowOffset > 0 ? t.shadowOffset : 2.0;
    return Semantics(
      button: true,
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _set(true),
        onTapUp: (_) => _set(false),
        onTapCancel: () => _set(false),
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          transform: Matrix4.translationValues(
            down ? travel : 0,
            down ? travel : 0,
            0,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: down ? t.signal : t.ground,
            border: Border.all(color: enabled ? t.ink : t.dim, width: t.border),
            boxShadow: [
              BoxShadow(
                color: enabled && t.shadowOffset > 0
                    ? t.shadow
                    : Colors.transparent,
                offset: down
                    ? Offset.zero
                    : Offset(t.shadowOffset, t.shadowOffset),
              ),
            ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: down ? t.onSignal : (enabled ? t.ink : t.dim),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
