import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// The owner's read of the day. No controls — everything here is a rollup of
/// the same customer rows the other two roles are editing.
class OwnerScreen extends StatelessWidget {
  const OwnerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final done = app.done;

    final onCount = app.braiders.where((b) => b.on).length;
    final on = onCount < 1 ? 1 : onCount;
    final busy = app.braiders
        .where((b) => b.on && app.busyWith(b.id) != null)
        .length;

    // Average wait = check-in → chair, over customers who actually got seated.
    final waits = done
        .where((c) => c.startedAt != null)
        .map(
          (c) => (c.startedAt!.difference(c.checkedInAt).inMilliseconds / 60000)
              .round(),
        )
        .toList();
    final avgWait = waits.isEmpty
        ? '—'
        : app.fmt((waits.reduce((a, b) => a + b) / waits.length).round());

    // Clients per braider.
    final counts = {
      for (final b in app.braiders)
        b.id: done.where((c) => c.braiderId == b.id).length,
    };
    final maxDone = counts.values.isEmpty
        ? 1
        : counts.values.reduce((a, b) => a > b ? a : b).clamp(1, 1 << 30);

    // Popular styles across every customer today, top 4.
    final styleCounts = <String, int>{};
    for (final c in app.customers) {
      styleCounts[c.style] = (styleCounts[c.style] ?? 0) + 1;
    }
    final styles = styleCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topStyles = styles.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: BF.deep,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: BF.line10),
            boxShadow: BF.glow(BF.acc, opacity: .18),
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(_today(), color: BF.whiteA(.45), ls: .16),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${done.length}',
                    style: BF.sans(44, 800, color: BF.white, height: 1),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: Text(
                        'clients completed',
                        style: BF.sans(13, 500, color: BF.whiteA(.6)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: BF.whiteA(.14))),
                ),
                child: Row(
                  children: [
                    _DarkStat(
                      value: '${app.active.length}',
                      label: 'In chairs',
                    ),
                    _DarkStat(value: '${app.waiting.length}', label: 'Waiting'),
                    _DarkStat(value: avgWait, label: 'Avg wait'),
                    _DarkStat(value: '$busy/$on', label: 'Chairs busy'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        BFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Clients per braider', color: BF.inkA(.4)),
              const SizedBox(height: 14),
              for (final b in app.braiders) ...[
                Row(
                  children: [
                    SizedBox(
                      width: 74,
                      child: Text(
                        b.firstName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BF.sans(12.5, 600),
                      ),
                    ),
                    const SizedBox(width: 11),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          height: 22,
                          color: BF.inkA(.06),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: ((counts[b.id]! / maxDone).clamp(
                              .04,
                              1.0,
                            )),
                            child: Container(
                              decoration: BoxDecoration(
                                color: counts[b.id]! >= maxDone
                                    ? BF.acc
                                    : BF.acc.withValues(alpha: .42),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 11),
                    SizedBox(
                      width: 26,
                      child: Text(
                        '${counts[b.id]}',
                        textAlign: TextAlign.right,
                        style: BF.sans(13, 700),
                      ),
                    ),
                  ],
                ),
                if (b != app.braiders.last) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),

        BFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Popular today', color: BF.inkA(.4)),
              const SizedBox(height: 12),
              for (final s in topStyles) ...[
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: BF.acc,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        s.key,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: BF.sans(13.5, 500, color: BF.inkA(.7)),
                      ),
                    ),
                    Text('${s.value}', style: BF.sans(13, 700)),
                  ],
                ),
                if (s != topStyles.last) const SizedBox(height: 9),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _today() {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final n = DateTime.now();
    return '${days[n.weekday - 1]}, ${n.day} ${months[n.month - 1]}';
  }
}

class _DarkStat extends StatelessWidget {
  const _DarkStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: BF.sans(19, 700, color: BF.white, height: 1)),
        const SizedBox(height: 5),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: BF.sans(11, 500, color: BF.whiteA(.5)),
        ),
      ],
    ),
  );
}
