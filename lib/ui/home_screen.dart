import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/dose.dart';
import '../domain/caffeine.dart';
import '../domain/presets.dart';
import '../domain/today.dart';
import '../state/dose_log.dart';
import '../state/theme_controller.dart';
import 'hard_button.dart';
import 'history_screen.dart';
import 'menu.dart';
import 'mug.dart';
import 'shared.dart';
import 'theme_screen.dart';
import 'themed_background.dart';
import 'tokens.dart';
import 'app_theme.dart';

ThemeData _pickerTheme(ThemeData base, CsTheme t) {
  Color selected(Set<WidgetState> s, Color on, Color off) =>
      s.contains(WidgetState.selected) ? on : off;
  final edge = RoundedRectangleBorder(side: BorderSide(color: t.ink, width: 2));
  return base.copyWith(
    colorScheme: ColorScheme(
      brightness: t.brightness,
      primary: t.signal,
      onPrimary: t.onSignal,
      secondary: t.signal,
      onSecondary: t.onSignal,
      error: t.alert,
      onError: t.ink,
      surface: t.ground,
      onSurface: t.ink,
    ),
    timePickerTheme: TimePickerThemeData(
      backgroundColor: t.ground,
      shape: edge,
      hourMinuteShape: edge,
      dayPeriodShape: edge,
      dayPeriodBorderSide: BorderSide(color: t.ink, width: 2),
      hourMinuteColor: WidgetStateColor.resolveWith(
        (s) => selected(s, t.signal, t.mugInner),
      ),
      hourMinuteTextColor: WidgetStateColor.resolveWith(
        (s) => selected(s, t.onSignal, t.ink),
      ),
      dayPeriodColor: WidgetStateColor.resolveWith(
        (s) => selected(s, t.signal, Colors.transparent),
      ),
      dayPeriodTextColor: WidgetStateColor.resolveWith(
        (s) => selected(s, t.onSignal, t.ink),
      ),
      dialBackgroundColor: t.mugInner,
      dialHandColor: t.signal,
      dialTextColor: WidgetStateColor.resolveWith(
        (s) => selected(s, t.onSignal, t.ink),
      ),
      entryModeIconColor: t.mutedInk,
      helpTextStyle: TextStyle(
        fontFamily: Tokens.spaceGrotesk,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.2,
        fontSize: 11,
        color: t.mutedInk,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: t.signal,
        shape: const RoundedRectangleBorder(),
        textStyle: const TextStyle(
          fontFamily: Tokens.spaceGrotesk,
          fontWeight: FontWeight.w700,
        ),
      ),
    ),
  );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.log, required this.themes});

  final DoseLog log;
  final ThemeController themes;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  Timer? _timer;

  // When the next dose happened. Both null means now. One-shot: cleared by
  // every log so a stray backdate can't leak onto the next one-tap log.
  Duration? _ago;
  TimeOfDay? _picked;

  DoseLog get _log => widget.log;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _log.load();
    // The estimate drifts with the clock even when nothing is logged.
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _log.tick());
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
  //
  // A chosen backdate is dropped too: coming back an hour later to tap a drink
  // means "now", and a stale "-1 h" would silently log it early.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    setState(() {
      _ago = null;
      _picked = null;
    });
    _log.load();
  }

  DateTime _logTime() {
    final now = _log.clock();
    if (_ago != null) return now.subtract(_ago!);
    if (_picked != null) {
      return lastOccurrence(_picked!.hour, _picked!.minute, now);
    }
    return now;
  }

  Future<void> _logDose(DoseSource source, int mg) async {
    HapticFeedback.lightImpact();
    final backdated = _ago != null || _picked != null;
    final dose = Dose.create(source: source, mg: mg, at: _logTime());
    setState(() {
      _ago = null;
      _picked = null;
    });
    if (!await _log.add(dose) || !mounted) return;
    // The log isn't on this screen, so every log says what it did and offers
    // undo. A backdated one also says when, and whether that was yesterday.
    var when = '';
    if (backdated) {
      final sameDay = dosesToday([dose], _log.clock()).isNotEmpty;
      when =
          ' at ${formatTime(context, dose.at)}${sameDay ? '' : ' yesterday'}';
    }
    showUndoBar(context, 'Logged ${dose.mg} mg$when.', () async {
      await _log.remove(dose);
    });
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_log.clock()),
      builder: (context, child) => Theme(
        data: _pickerTheme(Theme.of(context), context.cs),
        child: child!,
      ),
    );
    if (t != null && mounted) {
      setState(() {
        _picked = t;
        _ago = null;
      });
    }
  }

  Future<void> _other() async {
    final t = context.cs;
    final mg = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      backgroundColor: t.ground,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: t.ink, width: t.border),
      ),
      builder: (_) => const _OtherSheet(),
    );
    if (mg != null) _logDose(DoseSource.custom, mg);
  }

  Future<void> _openHistory() => Navigator.of(
    context,
  ).push(MaterialPageRoute<void>(builder: (_) => HistoryScreen(log: _log)));

  Future<void> _openTheme() => Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => ThemeScreen(controller: widget.themes),
    ),
  );

  Future<void> _openMenu() async {
    final choice = await showAppMenu(context);
    if (!mounted) return;
    switch (choice) {
      case MenuDestination.history:
        await _openHistory();
      case MenuDestination.theme:
        await _openTheme();
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Scaffold(
      backgroundColor: t.ground,
      body: ThemedBackground(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: _log,
            builder: (context, _) {
              final now = _log.now;
              final today = dosesToday(_log.doses, now);
              final active = remainingMg(_log.doses, now);
              return Column(
                children: [
                  _Header(onMenu: _openMenu),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(22, 26, 22, 40),
                      children: [
                        if (_log.error != null)
                          ErrorBlock(error: _log.error!)
                        else ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Mug(activeMg: active),
                              const SizedBox(width: 8),
                              Expanded(child: _Readout(activeMg: active)),
                            ],
                          ),
                          const SizedBox(height: 22),
                          _TodayLine(
                            count: today.length,
                            mg: totalMg(today),
                            onSeeLog: _openHistory,
                          ),
                          const SizedBox(height: 30),
                          const Label('TAP TO LOG'),
                          const SizedBox(height: 6),
                          Text(
                            'Typical amounts. Other takes the real number.',
                            style: TextStyle(
                              fontFamily: Tokens.spaceGrotesk,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                              color: t.dim,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _WhenRow(
                            ago: _ago,
                            picked: _picked,
                            onNow: () => setState(() {
                              _ago = null;
                              _picked = null;
                            }),
                            onAgo: (d) => setState(() {
                              _ago = d;
                              _picked = null;
                            }),
                            onPick: _pickTime,
                          ),
                          const SizedBox(height: 18),
                          _PresetGrid(
                            onPreset: (p) => _logDose(p.source, p.mg),
                            onOther: _other,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Wordmark and MENU. Blueprint adds drawing-office labels under it.
class _Header extends StatelessWidget {
  const _Header({required this.onMenu});

  final VoidCallback onMenu;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    final row = Row(
      children: [
        Text(
          'CEILING STARE',
          style: TextStyle(
            fontFamily: Tokens.archivoBlack,
            color: t.ink,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        const Spacer(),
        MenuButton(onTap: onMenu),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
      child: Column(
        children: [
          row,
          if (t.titleBlock) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: t.rule)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (final text in ['DWG. CS-01', 'SCALE 1 : 1'])
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: Tokens.spaceGrotesk,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                        letterSpacing: 1.4,
                        color: t.mutedInk,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Readout extends StatelessWidget {
  const _Readout({required this.activeMg});
  final double activeMg;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Label('STILL ACTIVE'),
        const SizedBox(height: 8),
        TweenAnimationBuilder<double>(
          tween: Tween(end: activeMg),
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          builder: (_, value, _) => FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: BigNumber('${value.round()}'),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'MG',
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 1.6,
            color: t.ink,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'estimate, ${defaultHalfLife.inHours} h half-life',
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w500,
            fontSize: 12,
            color: t.dim,
          ),
        ),
      ],
    );
  }
}

class _TodayLine extends StatelessWidget {
  const _TodayLine({
    required this.count,
    required this.mg,
    required this.onSeeLog,
  });
  final int count;
  final int mg;
  final VoidCallback onSeeLog;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    // Themes with a stat panel put this line on an inverted block.
    final panel = t.statPanel;
    final labelColor = panel ? t.signal : t.mutedInk;
    final numberColor = panel ? t.ground : t.ink;
    final countColor = panel ? t.ground.withValues(alpha: 0.65) : t.dim;
    final linkColor = panel ? t.signal : t.accentText;

    final line = Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        // The totals shrink to fit rather than overflow, so a big number or a
        // large text setting can't push SEE LOG off the screen.
        Expanded(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Label('TODAY', color: labelColor),
                const SizedBox(width: 14),
                Text(
                  '$mg MG',
                  style: TextStyle(
                    fontFamily: Tokens.archivoBlack,
                    fontSize: 26,
                    color: numberColor,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  count == 1 ? '1 drink' : '$count drinks',
                  style: TextStyle(
                    fontFamily: Tokens.spaceGrotesk,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    color: countColor,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          button: true,
          label: 'See the log',
          excludeSemantics: true,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onSeeLog,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
              child: Text(
                'SEE LOG',
                style: TextStyle(
                  fontFamily: Tokens.spaceGrotesk,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 1.6,
                  color: linkColor,
                  decoration: TextDecoration.underline,
                  decorationColor: linkColor,
                  decorationThickness: 2,
                ),
              ),
            ),
          ),
        ),
      ],
    );
    if (!panel) return line;
    return Container(
      color: t.ink,
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
      child: line,
    );
  }
}

class _WhenRow extends StatelessWidget {
  const _WhenRow({
    required this.ago,
    required this.picked,
    required this.onNow,
    required this.onAgo,
    required this.onPick,
  });

  final Duration? ago;
  final TimeOfDay? picked;
  final VoidCallback onNow;
  final void Function(Duration) onAgo;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    Widget chip(
      String label,
      bool selected,
      VoidCallback onTap, {
      String? spoken,
    }) => Semantics(
      button: true,
      selected: selected,
      label: spoken ?? label,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 10),
          decoration: BoxDecoration(
            color: selected ? t.signal : Colors.transparent,
            border: Border.all(
              color: selected ? t.signal : t.dim,
              width: t.border,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.8,
              color: selected ? t.onSignal : t.ink,
            ),
          ),
        ),
      ),
    );

    final steps = [
      (const Duration(minutes: 30), '\u221230 MIN', '30 minutes ago'),
      (const Duration(hours: 1), '\u22121 H', '1 hour ago'),
      (const Duration(hours: 2), '\u22122 H', '2 hours ago'),
    ];
    return Wrap(
      spacing: 7,
      runSpacing: 8,
      children: [
        chip('NOW', ago == null && picked == null, onNow),
        for (final (d, label, spoken) in steps)
          chip(label, ago == d, () => onAgo(d), spoken: spoken),
        chip(
          picked == null
              ? 'PICK TIME'
              : 'AT ${formatTime(context, DateTime(2000, 1, 1, picked!.hour, picked!.minute))}',
          picked != null,
          onPick,
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
    final t = context.cs;
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
          const Label('OTHER'),
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
            style: TextStyle(
              fontFamily: Tokens.archivoBlack,
              fontSize: 44,
              color: t.ink,
            ),
            cursorColor: t.signal,
            decoration: InputDecoration(
              hintText: '0',
              hintStyle: TextStyle(color: t.dim),
              suffixText: 'MG',
              suffixStyle: TextStyle(
                fontFamily: Tokens.spaceGrotesk,
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: 2,
                color: t.mutedInk,
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: t.ink, width: 2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: t.signal, width: 2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Whole milligrams, 1 to $maxDoseMg.',
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontSize: 12,
              color: t.dim,
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
