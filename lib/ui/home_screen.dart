import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dose.dart';
import '../data/dose_repository.dart';
import '../domain/caffeine.dart';
import '../domain/presets.dart';
import '../domain/today.dart';
import 'hard_button.dart';
import 'mug.dart';
import 'tokens.dart';

String _sourceLabel(DoseSource s) => switch (s) {
  DoseSource.coffee => 'Coffee',
  DoseSource.tea => 'Tea',
  DoseSource.energyDrink => 'Energy drink',
  DoseSource.custom => 'Other',
};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.repository, required this.clock});

  final DoseRepository repository;
  final DateTime Function() clock;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<Dose> _doses = const [];
  Object? _error;
  late DateTime _now;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _now = widget.clock();
    _reload();
    // The estimate drifts with the clock even when nothing is logged.
    _timer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => setState(() => _now = widget.clock()),
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Timers don't run while the app is suspended, so after hours in the
  // background "now" (and which day is "today") would be stale until the
  // next tick. Refresh the moment the app is back.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _reload();
  }

  Future<void> _reload() async {
    try {
      final doses = await widget.repository.all();
      if (!mounted) return;
      setState(() {
        _doses = doses;
        _error = null;
        _now = widget.clock();
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  Future<void> _add(Dose dose) async {
    try {
      await widget.repository.add(dose);
    } catch (e) {
      if (mounted) setState(() => _error = e);
      return;
    }
    await _reload();
  }

  void _log(DoseSource source, int mg) {
    HapticFeedback.lightImpact();
    _add(Dose.create(source: source, mg: mg, at: widget.clock()));
  }

  Future<void> _remove(Dose dose) async {
    try {
      await widget.repository.remove(dose.id);
    } catch (e) {
      if (mounted) setState(() => _error = e);
      return;
    }
    await _reload();
    if (!mounted) return;
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
            'Removed ${dose.mg} mg.',
            style: const TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontWeight: FontWeight.w600,
              color: Tokens.ground,
            ),
          ),
          action: SnackBarAction(
            label: 'UNDO',
            textColor: Tokens.ground,
            onPressed: () => _add(dose),
          ),
        ),
      );
  }

  Future<void> _other() async {
    final mg = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Tokens.ground,
      shape: const RoundedRectangleBorder(
        side: BorderSide(color: Tokens.ink, width: 2),
      ),
      builder: (_) => const _OtherSheet(),
    );
    if (mg != null) _log(DoseSource.custom, mg);
  }

  @override
  Widget build(BuildContext context) {
    final today = dosesToday(_doses, _now);
    final active = remainingMg(_doses, _now);

    return Scaffold(
      backgroundColor: Tokens.ground,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 40),
          children: [
            const Text(
              'WIRED',
              style: TextStyle(
                fontFamily: Tokens.majorMono,
                color: Tokens.ink,
                fontSize: 13,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 26),
            if (_error != null)
              _ErrorBlock(error: _error!)
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Mug(activeMg: active),
                  const SizedBox(width: 8),
                  Expanded(child: _Readout(activeMg: active)),
                ],
              ),
              const SizedBox(height: 26),
              _TodayLine(count: today.length, mg: totalMg(today)),
              const SizedBox(height: 30),
              const _Label('TAP TO LOG'),
              const SizedBox(height: 6),
              const Text(
                'Typical amounts. Other takes the real number.',
                style: TextStyle(
                  fontFamily: Tokens.spaceGrotesk,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Tokens.dim,
                ),
              ),
              const SizedBox(height: 14),
              _PresetGrid(
                onPreset: (p) => _log(p.source, p.mg),
                onOther: _other,
              ),
              const SizedBox(height: 34),
              const _Label("TODAY'S LOG"),
              const SizedBox(height: 10),
              if (today.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    'Nothing yet today.',
                    style: TextStyle(
                      fontFamily: Tokens.dmSerifItalic,
                      fontStyle: FontStyle.italic,
                      fontSize: 22,
                      color: Tokens.mutedInk,
                    ),
                  ),
                )
              else
                for (final d in today)
                  _DoseRow(dose: d, onRemove: () => _remove(d)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);
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

class _Readout extends StatelessWidget {
  const _Readout({required this.activeMg});
  final double activeMg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('STILL ACTIVE'),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: activeMg),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, value, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${value.round()}',
              style: const TextStyle(
                fontFamily: Tokens.archivoBlack,
                fontSize: 68,
                height: 1,
                letterSpacing: -2,
                color: Tokens.ink,
                shadows: [Shadow(color: Tokens.rust, offset: Offset(4, 4))],
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'MG',
          style: TextStyle(
            fontFamily: Tokens.majorMono,
            fontSize: 13,
            letterSpacing: 3,
            color: Tokens.ink,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'estimate, ${defaultHalfLife.inHours} h half-life',
          style: const TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: Tokens.dim,
          ),
        ),
      ],
    );
  }
}

class _TodayLine extends StatelessWidget {
  const _TodayLine({required this.count, required this.mg});
  final int count;
  final int mg;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        const _Label('TODAY'),
        const SizedBox(width: 14),
        Text(
          '$mg MG',
          style: const TextStyle(
            fontFamily: Tokens.archivoBlack,
            fontSize: 26,
            color: Tokens.ink,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          count == 1 ? '1 drink' : '$count drinks',
          style: const TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Tokens.dim,
          ),
        ),
      ],
    );
  }
}

class _PresetGrid extends StatelessWidget {
  const _PresetGrid({required this.onPreset, required this.onOther});

  final void Function(Preset) onPreset;
  final VoidCallback onOther;

  @override
  Widget build(BuildContext context) {
    final cells = <Widget>[
      for (final p in presets)
        HardButton(
          onPressed: () => onPreset(p),
          child: _CellText(title: p.name, sub: '${p.mg} MG, ${p.serving}'),
        ),
      HardButton(
        onPressed: onOther,
        child: const _CellText(title: 'Other', sub: 'ENTER MG'),
      ),
    ];
    return Column(
      children: [
        for (var i = 0; i < cells.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 74,
              child: Row(
                children: [
                  Expanded(child: cells[i]),
                  const SizedBox(width: 16),
                  Expanded(
                    child: i + 1 < cells.length
                        ? cells[i + 1]
                        : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _CellText extends StatelessWidget {
  const _CellText({required this.title, required this.sub});
  final String title;
  final String sub;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontFamily: Tokens.archivoBlack, fontSize: 16),
      ),
      const SizedBox(height: 4),
      Opacity(
        opacity: 0.75,
        child: Text(
          sub,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w600,
            fontSize: 11,
            letterSpacing: 0.5,
          ),
        ),
      ),
    ],
  );
}

class _DoseRow extends StatelessWidget {
  const _DoseRow({required this.dose, required this.onRemove});
  final Dose dose;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay.fromDateTime(dose.at.toLocal()),
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );
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
              _sourceLabel(dose.source),
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
                child: Center(child: _Cross()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Two square-capped strokes; no icon font.
class _Cross extends StatelessWidget {
  const _Cross();

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

class _ErrorBlock extends StatelessWidget {
  const _ErrorBlock({required this.error});
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

class _OtherSheet extends StatefulWidget {
  const _OtherSheet();

  @override
  State<_OtherSheet> createState() => _OtherSheetState();
}

class _OtherSheetState extends State<_OtherSheet> {
  final _controller = TextEditingController();

  int? get _mg {
    final v = int.tryParse(_controller.text);
    return (v != null && v >= 1 && v <= maxDoseMg) ? v : null;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        22,
        20,
        22,
        22 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('OTHER'),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
            onChanged: (_) => setState(() {}),
            style: const TextStyle(
              fontFamily: Tokens.archivoBlack,
              fontSize: 44,
              color: Tokens.ink,
            ),
            cursorColor: Tokens.signal,
            decoration: const InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: Tokens.dim),
              suffixText: 'MG',
              suffixStyle: TextStyle(
                fontFamily: Tokens.majorMono,
                fontSize: 14,
                color: Tokens.mutedInk,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Tokens.ink, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Tokens.signal, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Whole milligrams, 1 to $maxDoseMg.',
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontSize: 12,
              color: Tokens.dim,
            ),
          ),
          const SizedBox(height: 22),
          HardButton(
            onPressed: _mg == null ? null : () => Navigator.pop(context, _mg),
            child: const Center(
              child: Text(
                'LOG IT',
                style: TextStyle(
                  fontFamily: Tokens.archivoBlack,
                  fontSize: 16,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
