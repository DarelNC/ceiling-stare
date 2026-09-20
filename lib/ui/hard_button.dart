import 'package:flutter/material.dart';

import 'tokens.dart';

/// Bordered box with a hard offset shadow. Pressing it flattens onto the
/// shadow and flashes the signal colour. Null [onPressed] renders it inert.
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
    final enabled = widget.onPressed != null;
    final down = _down && enabled;
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
            down ? Tokens.shadow : 0,
            down ? Tokens.shadow : 0,
            0,
          ),
          padding: widget.padding,
          decoration: BoxDecoration(
            color: down ? Tokens.signal : Tokens.ground,
            border: Border.all(
              color: enabled ? Tokens.ink : Tokens.dim,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: enabled ? Tokens.rust : Colors.transparent,
                offset: down
                    ? Offset.zero
                    : const Offset(Tokens.shadow, Tokens.shadow),
              ),
            ],
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: down ? Tokens.ground : (enabled ? Tokens.ink : Tokens.dim),
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
