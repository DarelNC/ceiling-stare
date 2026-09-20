import 'package:flutter/material.dart';

import '../data/dose.dart';
import '../domain/history.dart';
import '../state/dose_log.dart';
import 'day_chart.dart';
import 'shared.dart';
import 'tokens.dart';

/// Trend strip for the last two weeks, then every logged dose grouped by day.
/// This is where a dose is found and removed after the fact, including ones
/// backdated onto yesterday.
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.log});

  final DoseLog log;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int? _selected; // null follows today

  DoseLog get _log => widget.log;

  Future<void> _remove(Dose dose) async {
    if (!await _log.remove(dose) || !mounted) return;
    showUndoBar(context, 'Removed ${dose.mg} mg.', () async {
      await _log.add(dose);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Tokens.ground,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _log,
          builder: (context, _) {
            final now = _log.now;
            final totals = dailyTotals(_log.doses, now);
            final groups = groupByDay(_log.doses);
            final selected = (_selected ?? totals.length - 1).clamp(
              0,
              totals.length - 1,
            );
            final picked = totals[selected];

            return CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      Row(children: [_BackButton()]),
                      const SizedBox(height: 26),
                      const Text(
                        'HISTORY',
                        style: TextStyle(
                          fontFamily: Tokens.archivoBlack,
                          fontSize: 44,
                          height: 0.95,
                          letterSpacing: -1.5,
                          color: Tokens.ink,
                          shadows: [
                            Shadow(color: Tokens.rust, offset: Offset(5, 5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      if (_log.error != null)
                        ErrorBlock(error: _log.error!)
                      else ...[
                        Label('LAST ${totals.length} DAYS'),
                        const SizedBox(height: 26),
                        DayChart(
                          days: totals,
                          now: now,
                          selected: selected,
                          onSelect: (i) => setState(() => _selected = i),
                        ),
                        const SizedBox(height: 14),
                        _Picked(total: picked, now: now),
                      ],
                    ]),
                  ),
                ),
                if (_log.error == null)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 10, 22, 40),
                    sliver: groups.isEmpty
                        ? const SliverToBoxAdapter(child: _Empty())
                        : SliverList(
                            delegate: SliverChildBuilderDelegate((context, i) {
                              final item = _flatten(groups)[i];
                              return item is DayGroup
                                  ? _DayHeader(group: item, now: now)
                                  : DoseRow(
                                      dose: item as Dose,
                                      onRemove: () => _remove(item),
                                    );
                            }, childCount: _flatten(groups).length),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Day headers and their doses as one flat list, so the long log is built
  // lazily instead of all at once.
  List<Object> _flatten(List<DayGroup> groups) => [
    for (final g in groups) ...[g, ...g.doses],
  ];
}

class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: 'Back',
    excludeSemantics: true,
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Navigator.of(context).maybePop(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          border: Border.all(color: Tokens.ink, width: 2),
        ),
        child: const Text(
          'BACK',
          style: TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w700,
            fontSize: 12,
            letterSpacing: 1.6,
            color: Tokens.ink,
          ),
        ),
      ),
    ),
  );
}

class _Picked extends StatelessWidget {
  const _Picked({required this.total, required this.now});

  final DayTotal total;
  final DateTime now;

  // Shrinks to fit: "WED 30 DEC 2026 1250 MG 12 drinks" is wider than a phone.
  @override
  Widget build(BuildContext context) => FittedBox(
    fit: BoxFit.scaleDown,
    alignment: Alignment.centerLeft,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Label(dayLabel(total.day, now)),
        const SizedBox(width: 14),
        Text(
          '${total.mg} MG',
          style: const TextStyle(
            fontFamily: Tokens.archivoBlack,
            fontSize: 26,
            color: Tokens.ink,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          total.count == 1 ? '1 drink' : '${total.count} drinks',
          style: const TextStyle(
            fontFamily: Tokens.spaceGrotesk,
            fontWeight: FontWeight.w500,
            fontSize: 13,
            color: Tokens.dim,
          ),
        ),
      ],
    ),
  );
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group, required this.now});

  final DayGroup group;
  final DateTime now;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 26),
    padding: const EdgeInsets.only(bottom: 8),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: Tokens.ink, width: 2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(
            dayLabel(group.day, now),
            style: const TextStyle(
              fontFamily: Tokens.archivoBlack,
              fontSize: 20,
              color: Tokens.ink,
            ),
          ),
        ),
        Text(
          '${group.totalMg} MG',
          style: const TextStyle(
            fontFamily: Tokens.majorMono,
            fontSize: 13,
            color: Tokens.ink,
          ),
        ),
      ],
    ),
  );
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(top: 22),
    child: Text(
      'Nothing logged yet.',
      style: TextStyle(
        fontFamily: Tokens.dmSerifItalic,
        fontStyle: FontStyle.italic,
        fontSize: 22,
        color: Tokens.mutedInk,
      ),
    ),
  );
}
