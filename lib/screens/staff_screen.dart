import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Roster and shifts. Clocking someone out is the one control here, and it
/// is refused while their chair is still occupied — otherwise a customer
/// would be stranded with a braider who has gone home.
class StaffScreen extends StatelessWidget {
  const StaffScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DottedBorder(
          color: BF.inkA(.28),
          radius: 13,
          child: BFButton(
            label: '+ Register a braider',
            onTap: app.toggleAdd,
            background: BF.white,
            foreground: BF.plum,
            minHeight: 48,
            radius: 13,
            fontSize: 13.5,
          ),
        ),
        const SizedBox(height: 14),
        if (app.showAdd) ...[
          BFCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                BFField(
                  hint: "Braider's full name",
                  value: app.nbName,
                  onChanged: app.setNbName,
                  minHeight: 46,
                  radius: 11,
                ),
                const SizedBox(height: 11),
                BFField(
                  hint: 'Speciality · e.g. Knotless, Twists',
                  value: app.nbSkill,
                  onChanged: app.setNbSkill,
                  minHeight: 46,
                  radius: 11,
                ),
                const SizedBox(height: 11),
                BFButton(
                  label: 'Add to roster',
                  onTap: app.addBraider,
                  background: BF.acc,
                  minHeight: 48,
                  radius: 12,
                  fontSize: 14,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
        for (final b in app.braiders) ...[
          _StaffRow(braiderId: b.id),
          if (b != app.braiders.last) const SizedBox(height: 9),
        ],
      ],
    );
  }
}

class _StaffRow extends StatelessWidget {
  const _StaffRow({required this.braiderId});

  final int braiderId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final b = app.braiderById(braiderId);
    final current = app.busyWith(b.id);
    final free = app.isFree(b);
    final doneCount = app.done.where((c) => c.braiderId == b.id).length;

    final footer = !b.on
        ? '—'
        : free
        ? '$doneCount done today'
        : '${app.fmt(app.minsSince(current!.startedAt!))} in · $doneCount done';

    return BFCard(
      radius: 14,
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Avatar(initials: b.initials, color: BF.avatarFor(b.id)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(b.name, style: BF.sans(14.5, 700)),
                const SizedBox(height: 1),
                Text(
                  b.skills,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: BF.sans(12, 500, color: BF.inkA(.5)),
                ),
                const SizedBox(height: 2),
                Text(footer, style: BF.sans(11, 600, color: BF.inkA(.4))),
              ],
            ),
          ),
          const SizedBox(width: 10),
          BFButton(
            label: b.on ? 'Clock out' : 'Clock in',
            onTap: () => app.toggleShift(b.id),
            background: !b.on
                ? BF.white.withValues(alpha: .55)
                : free
                ? BF.doneBg
                : BF.progBg,
            foreground: BF.plum,
            border: !b.on
                ? BF.line10
                : free
                ? BF.green.withValues(alpha: .28)
                : BF.acc.withValues(alpha: .28),
            minHeight: 44,
            radius: 11,
            fontSize: 11.5,
            expand: false,
          ),
        ],
      ),
    );
  }
}
