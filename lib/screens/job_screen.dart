import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// The braider's whole job in one screen: who is in her chair, how long they
/// have been there, and the single button that ends it.
///
/// Trigger 3 lives here — finishing marks the customer completed and, when
/// pull-next is on, drops the longest-waiting walk-in straight into her chair.
class JobScreen extends StatelessWidget {
  const JobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final me = app.me;
    final current = app.meCurrent;
    final doneCount = app.done.where((c) => c.braiderId == me.id).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (current != null) ...[
          _LiveCard(customerId: current.id),
          const SizedBox(height: 14),
          BFButton(
            label: 'Finish client · go free',
            onTap: () => app.complete(current.id),
            background: BF.green,
            minHeight: 58,
            radius: 16,
            fontSize: 15.5,
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Finishing marks the customer completed and puts you back on '
              'the free list instantly.',
              textAlign: TextAlign.center,
              style: BF.sans(12, 500, color: BF.inkA(.45), height: 1.5),
            ),
          ),
        ] else if (me.on) ...[
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: BF.doneBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BF.green.withValues(alpha: .3)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              children: [
                Text(
                  "You're free",
                  style: BF.sans(28, 800, color: BF.green, height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Free for ${app.fmt(app.minsSince(me.idleSince))} · the desk '
                  'can see you as available. The next walk-in will land here '
                  'automatically.',
                  textAlign: TextAlign.center,
                  style: BF.sans(13.5, 500, color: BF.inkA(.55), height: 1.5),
                ),
              ],
            ),
          ),
          if (app.waiting.isNotEmpty) ...[
            const SizedBox(height: 14),
            BFButton(
              label:
                  'Take ${app.waiting.first.name} · queue ${app.waiting.first.no}',
              onTap: () => app.assign(app.waiting.first.id, me.id),
              minHeight: 56,
              radius: 15,
            ),
          ],
        ] else ...[
          // Clocked out — no chair, no allocation.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: BF.glassDim,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: BF.line10),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
            child: Column(
              children: [
                Text(
                  'Off shift',
                  style: BF.sans(28, 800, color: BF.inkA(.5), height: 1.15),
                ),
                const SizedBox(height: 8),
                Text(
                  'Clock in from the Me tab to go back on the free list.',
                  textAlign: TextAlign.center,
                  style: BF.sans(13.5, 500, color: BF.inkA(.5), height: 1.5),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 20),
        BFCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Your day', color: BF.inkA(.4)),
              const SizedBox(height: 13),
              Row(
                children: [
                  _DayStat(value: '$doneCount', label: 'Clients done'),
                  _DayStat(
                    value: me.on
                        ? app.fmt(app.minsSince(me.clockedInAt!))
                        : '—',
                    label: 'On the clock',
                  ),
                  _DayStat(value: _avg(app, me.id), label: 'Avg / client'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Mean chair time across the clients this braider has closed today.
  String _avg(AppState app, int braiderId) {
    final mine = app.done
        .where((c) => c.braiderId == braiderId && c.startedAt != null)
        .toList();
    if (mine.isEmpty) return '—';
    final total = mine.fold<double>(
      0,
      (a, c) =>
          a + c.completedAt!.difference(c.startedAt!).inMilliseconds / 60000,
    );
    return app.fmt((total / mine.length).round());
  }
}

class _LiveCard extends StatelessWidget {
  const _LiveCard({required this.customerId});

  final int customerId;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final c = app.customers.firstWhere((x) => x.id == customerId);
    final elapsed = app.minsSince(c.startedAt!);
    final duration = c.durationMinutes;

    final eta = elapsed >= duration
        ? 'over the ${app.fmt(duration)} average'
        : '${app.fmt(duration - elapsed)} left of a ${app.fmt(duration)} style';

    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: SectionLabel(
                  'In your chair',
                  color: BF.whiteA(.5),
                  ls: .16,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _PulseDot(),
                  const SizedBox(width: 6),
                  Text('LIVE', style: BF.sans(11, 700, color: BF.ember)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(c.name, style: BF.sans(30, 800, color: BF.white, height: 1.15)),
          const SizedBox(height: 4),
          Text(
            '${c.style} · queue ${c.no}',
            style: BF.sans(13.5, 500, color: BF.whiteA(.6)),
          ),
          const SizedBox(height: 22),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Scales down rather than overflowing when accessibility
                    // text sizes inflate this 44pt display figure.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        app.fmt(elapsed),
                        maxLines: 1,
                        style: BF.sans(36, 800, color: BF.white, height: 1),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'elapsed',
                      style: BF.sans(11, 600, color: BF.whiteA(.45)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ProgressBar(
                        value: elapsed / duration,
                        color: BF.ember,
                        background: BF.whiteA(.15),
                        height: 6,
                      ),
                      const SizedBox(height: 7),
                      Text(eta, style: BF.sans(11, 600, color: BF.whiteA(.45))),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `@keyframes bfpulse` — 1.8s ease-in-out, opacity 1 → .35 → 1.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat(reverse: true);

  late final Animation<double> _a = Tween(
    begin: 1.0,
    end: .35,
  ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _a,
    child: Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(color: BF.ember, shape: BoxShape.circle),
    ),
  );
}

class _DayStat extends StatelessWidget {
  const _DayStat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: BF.sans(24, 800, height: 1)),
        const SizedBox(height: 4),
        Text(label, style: BF.sans(11, 600, color: BF.inkA(.5))),
      ],
    ),
  );
}
