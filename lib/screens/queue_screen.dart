import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// The supervisor's home. Three counters, then the queue split by status:
/// waiting (actionable), in progress (inspectable), completed (a receipt).
class QueueScreen extends StatelessWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final waiting = app.waiting;
    final active = app.active;
    final done = app.done;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _Stat(
              value: '${waiting.length}',
              label: 'Waiting',
              color: BF.goldInk,
            ),
            const SizedBox(width: 9),
            _Stat(value: '${active.length}', label: 'In chair', color: BF.acc),
            const SizedBox(width: 9),
            _Stat(
              value: '${app.freeBraiders().length}',
              label: 'Free now',
              color: BF.green,
            ),
          ],
        ),
        const SizedBox(height: 18),

        SectionLabel('Waiting · tap to allocate', color: BF.inkA(.4)),
        const SizedBox(height: 10),
        if (waiting.isEmpty)
          const EmptyNote("Nobody waiting. Everyone's in a chair.")
        else
          for (final (i, c) in waiting.indexed) ...[
            _WaitingRow(customerId: c.id, position: i),
            if (c != waiting.last) const SizedBox(height: 9),
          ],
        const SizedBox(height: 22),

        SectionLabel('In progress', color: BF.inkA(.4)),
        const SizedBox(height: 10),
        for (final c in active) ...[
          _ActiveRow(customerId: c.id),
          if (c != active.last) const SizedBox(height: 9),
        ],
        const SizedBox(height: 22),

        SectionLabel('Completed today · ${done.length}', color: BF.inkA(.4)),
        const SizedBox(height: 10),
        for (final c in done) ...[
          _DoneRow(customerId: c.id),
          if (c != done.last) const SizedBox(height: 7),
        ],
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Expanded(
    child: BFCard(
      radius: 14,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: BF.sans(26, 800, color: color, height: 1)),
          const SizedBox(height: 4),
          Text(label, style: BF.sans(11, 600, color: BF.inkA(.5))),
        ],
      ),
    ),
  );
}

class _WaitingRow extends StatelessWidget {
  const _WaitingRow({required this.customerId, required this.position});

  final int customerId;
  final int position;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.customers.firstWhere((x) => x.id == customerId);

    final waited = app.fmt(app.minsSince(c.checkedInAt));
    final label = app.showWaitEstimate
        ? 'waiting $waited · chair ${app.chairEstimate(position)}'
        : 'waiting $waited';

    return BFCard(
      radius: 14,
      padding: const EdgeInsets.all(14),
      leftAccent: BF.gold,
      child: Row(
        children: [
          QueueBadge(no: c.no, background: BF.waitBg, foreground: BF.goldInk),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.name, style: BF.sans(15, 700)),
                const SizedBox(height: 1),
                Text(
                  c.style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BF.sans(12.5, 500, color: BF.inkA(.5)),
                ),
                const SizedBox(height: 3),
                Text(label, style: BF.sans(11.5, 600, color: BF.goldInk)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          BFButton(
            label: 'Allocate',
            onTap: () => app.openAssign(c.id),
            minHeight: 44,
            radius: 11,
            fontSize: 12.5,
            expand: false,
          ),
        ],
      ),
    );
  }
}

class _ActiveRow extends StatelessWidget {
  const _ActiveRow({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.customers.firstWhere((x) => x.id == customerId);
    final elapsed = app.minsSince(c.startedAt!);

    return BFCard(
      radius: 14,
      padding: EdgeInsets.zero,
      leftAccent: BF.acc,
      child: Tappable(
        onTap: () => app.push(BFScreen.detail, detail: c.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              QueueBadge(no: c.no, background: BF.progBg, foreground: BF.acc),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(c.name, style: BF.sans(15, 700)),
                    const SizedBox(height: 1),
                    Text(
                      'with ${app.braiderName(c.braiderId)}',
                      style: BF.sans(12.5, 500, color: BF.inkA(.5)),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Expanded(
                          child: ProgressBar(
                            value: elapsed / c.durationMinutes,
                            color: BF.acc,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          app.fmt(elapsed),
                          style: BF.sans(11, 600, color: BF.inkA(.5)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text('›', style: TextStyle(fontSize: 17, color: BF.inkA(.28))),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoneRow extends StatelessWidget {
  const _DoneRow({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.customers.firstWhere((x) => x.id == customerId);

    return Container(
      decoration: BoxDecoration(
        color: BF.white.withValues(alpha: .6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: BF.inkA(.07)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: BF.green,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 11),
          Text(c.no, style: BF.sans(13.5, 700, color: BF.inkA(.75))),
          const SizedBox(width: 11),
          Expanded(
            child: Text(
              c.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: BF.sans(13.5, 500, color: BF.inkA(.6)),
            ),
          ),
          Text(
            app.clock(c.completedAt!),
            style: BF.sans(11.5, 600, color: BF.inkA(.42)),
          ),
        ],
      ),
    );
  }
}
