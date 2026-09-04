import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Availability at a glance — two-up cards, one per braider.
///
/// Nothing here is hand-maintained: the colour, the status word and the
/// footer are all read off the customer table plus today's shift.
class ChairsScreen extends StatelessWidget {
  const ChairsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    // A fixed-extent GridView clipped the two-line detail text. The design
    // sets `min-height:150px` and lets the card grow, so rows are built by
    // hand: IntrinsicHeight matches the pair, and the card sizes to content.
    final rows = <Widget>[];
    for (var i = 0; i < app.braiders.length; i += 2) {
      final left = app.braiders[i];
      final right = i + 1 < app.braiders.length ? app.braiders[i + 1] : null;
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _ChairCard(braiderId: left.id)),
              const SizedBox(width: 10),
              Expanded(
                child: right == null
                    ? const SizedBox.shrink()
                    : _ChairCard(braiderId: right.id),
              ),
            ],
          ),
        ),
      );
      if (i + 2 < app.braiders.length) rows.add(const SizedBox(height: 10));
    }

    return Column(children: rows);
  }
}

class _ChairCard extends StatelessWidget {
  const _ChairCard({required this.braiderId});

  final int braiderId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final b = app.braiderById(braiderId);
    final current = app.busyWith(b.id);
    final free = app.isFree(b);

    final dot = !b.on
        ? BF.inkA(.35)
        : free
        ? BF.green
        : BF.acc;
    final doneCount = app.done.where((c) => c.braiderId == b.id).length;

    final statusLabel = !b.on
        ? 'Off shift'
        : free
        ? 'Free'
        : 'With client';

    final detail = !b.on
        ? 'Not clocked in today'
        : free
        ? 'Available now — idle ${app.fmt(app.minsSince(b.idleSince))}'
        : '${current!.name} · ${current.style}';

    final footer = !b.on
        ? '—'
        : free
        ? '$doneCount done today'
        : '${app.fmt(app.minsSince(current!.startedAt!))} in · $doneCount done';

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 150),
      child: Container(
        decoration: BoxDecoration(
          color: !b.on
              ? BF.white.withValues(alpha: .55)
              : free
              ? BF.doneBg
              : BF.progBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: !b.on
                ? BF.line10
                : free
                ? BF.green.withValues(alpha: .28)
                : BF.acc.withValues(alpha: .28),
          ),
        ),
        child: Tappable(
          radius: 16,
          onTap: () {
            if (current != null) {
              app.push(BFScreen.detail, detail: current.id);
            } else {
              app.say(
                '${b.firstName} is ${b.on ? 'free and ready.' : 'off shift.'}',
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Avatar(
                      initials: b.initials,
                      color: BF.avatarFor(b.id),
                      size: 34,
                      radius: 10,
                      fontSize: 13,
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: dot,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  b.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BF.sans(14.5, 700, height: 1.25),
                ),
                const SizedBox(height: 6),
                Text(
                  statusLabel.toUpperCase(),
                  style: BF.sans(
                    10.5,
                    700,
                    color: dot,
                    height: 1,
                    letterSpacing: 1.26,
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Text(
                      detail,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: BF.sans(
                        12,
                        500,
                        color: BF.inkA(.55),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  padding: const EdgeInsets.only(top: 9),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: BF.inkA(.08))),
                  ),
                  child: Text(
                    footer,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: BF.sans(11, 600, color: BF.inkA(.4)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
