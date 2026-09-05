import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// The braider's own profile and shift control.
class MeScreen extends StatelessWidget {
  const MeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final current = app.meCurrent;

    final statusLabel = !me.on
        ? 'Off shift'
        : current != null
        ? 'With client'
        : 'Free';
    final chipDot = !me.on
        ? BF.inkA(.4)
        : current != null
        ? BF.acc
        : BF.green;
    final chipBg = !me.on
        ? BF.inkA(.06)
        : current != null
        ? BF.progBg
        : BF.doneBg;

    return Column(
      // stretch, not start: the profile card has no full-width child of its
      // own, so it would otherwise shrink-wrap the avatar.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BFCard(
          radius: 18,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Avatar(
                initials: me.initials,
                color: BF.avatarFor(me.id),
                size: 64,
                radius: 18,
                fontSize: 22,
              ),
              const SizedBox(height: 12),
              Text(me.name, style: BF.serif(28, height: 1.1)),
              const SizedBox(height: 4),
              Text(me.skills, style: BF.sans(12.5, 500, color: BF.inkA(.5))),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: chipDot,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    Text(
                      statusLabel,
                      style: BF.sans(11.5, 700, color: chipDot),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        BFCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SectionLabel("Today's shift", color: BF.inkA(.4)),
                    const SizedBox(height: 6),
                    Text(
                      me.on
                          ? 'Clocked in ${app.clock(me.clockedInAt!)} · '
                                '${app.fmt(app.minsSince(me.clockedInAt!))}'
                          : 'Not clocked in',
                      style: BF.sans(15, 700),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              BFButton(
                label: me.on ? 'Clock out' : 'Clock in',
                onTap: app.toggleMyShift,
                background: me.on ? BF.glassStrong : BF.green,
                border: me.on ? BF.line10 : null,
                minHeight: 46,
                radius: 12,
                fontSize: 13,
                expand: false,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        Text(
          'Clocking out removes you from allocation immediately — the desk '
          "can't assign a walk-in to a braider who has gone home.",
          style: BF.sans(12.5, 500, color: BF.inkA(.45), height: 1.5),
        ),
      ],
    );
  }
}
