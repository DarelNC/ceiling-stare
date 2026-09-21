import 'package:flutter/material.dart';

import '../data/dose.dart';
import '../domain/history.dart';
import '../state/dose_log.dart';
import 'app_theme.dart';
import 'day_chart.dart';
import 'shared.dart';
import 'themed_background.dart';
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
    final t = context.cs;
    return Scaffold(
      backgroundColor: t.ground,
      body: ThemedBackground(
        child: SafeArea(
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
                        Row(children: [BackChip()]),
                        const SizedBox(height: 26),
                        ScreenTitle('HISTORY'),
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
                              delegate: SliverChildBuilderDelegate((
                                context,
                                i,
                              ) {
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
      ),
    );
  }

  // Day headers and their doses as one flat list, so the long log is built
  // lazily instead of all at once.
  List<Object> _flatten(List<DayGroup> groups) => [
    for (final g in groups) ...[g, ...g.doses],
  ];
}

class _Picked extends StatelessWidget {
  const _Picked({required this.total, required this.now});

  final DayTotal total;
  final DateTime now;

  // Shrinks to fit: "WED 30 DEC 2026 1250 MG 12 drinks" is wider than a phone.
  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return FittedBox(
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
            style: TextStyle(
              fontFamily: Tokens.archivoBlack,
              fontSize: 26,
              color: t.ink,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            total.count == 1 ? '1 drink' : '${total.count} drinks',
            style: TextStyle(
              fontFamily: Tokens.spaceGrotesk,
              fontWeight: FontWeight.w500,
              fontSize: 13,
              color: t.dim,
            ),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader({required this.group, required this.now});

  final DayGroup group;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Container(
      margin: const EdgeInsets.only(top: 26),
      padding: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: t.ink, width: 2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Expanded(
            child: Text(
              dayLabel(group.day, now),
              style: TextStyle(
                fontFamily: Tokens.archivoBlack,
                fontSize: 20,
                color: t.ink,
              ),
            ),
          ),
          Text(
            '${group.totalMg} MG',
            style: TextStyle(
              fontFamily: Tokens.majorMono,
              fontSize: 13,
              color: t.ink,
            ),
          ),
        ],
      ),
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final t = context.cs;
    return Padding(
      padding: EdgeInsets.only(top: 22),
      child: Text(
        'Nothing logged yet.',
        style: TextStyle(
          fontFamily: Tokens.dmSerifItalic,
          fontStyle: FontStyle.italic,
          fontSize: 22,
          color: t.mutedInk,
        ),
      ),
    );
  }
}
