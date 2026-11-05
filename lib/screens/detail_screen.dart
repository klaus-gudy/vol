import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// One customer's journey through the state machine, plus the two overrides
/// the supervisor has: send them back to the queue, or close them out.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final d = app.detail;
    if (d == null) return const SizedBox.shrink();

    final steps = <_Step>[
      _Step(
        label: 'Checked in · queue ${d.no}',
        at: '${app.clock(d.checkedInAt)} · ${app.fmt(app.minsSince(d.checkedInAt))} ago',
        state: _StepState.done,
      ),
      if (d.startedAt != null)
        _Step(
          label: 'In progress with ${app.braiderName(d.braiderId)}',
          at: '${app.clock(d.startedAt!)} · ${app.fmt(app.minsSince(d.startedAt!))} so far',
          state: d.status == CustomerStatus.inProgress
              ? _StepState.now
              : _StepState.done,
        )
      else
        const _Step(
          label: 'Awaiting allocation',
          at: 'Not assigned yet',
          state: _StepState.now,
        ),
      if (d.completedAt != null)
        _Step(
          label: 'Completed',
          at: app.clock(d.completedAt!),
          state: _StepState.done,
        )
      else
        const _Step(
          label: 'Completed',
          at: 'Pending',
          state: _StepState.pending,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  QueueBadge(
                    no: d.no,
                    background: BF.sand,
                    foreground: BF.plum,
                    size: 56,
                    fontSize: 17,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(d.name, style: BF.sans(21, 800, height: 1.15)),
                        const SizedBox(height: 3),
                        Text(
                          d.phone,
                          style: BF.sans(13, 500, color: BF.inkA(.55)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _Facet(label: 'Service', value: d.style),
                  const SizedBox(width: 10),
                  _Facet(
                    label: 'Braider',
                    value: d.braiderId != null
                        ? app.braiderName(d.braiderId)
                        : 'Unassigned',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        BFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel('Status timeline', color: BF.inkA(.4)),
              const SizedBox(height: 16),
              for (final (i, s) in steps.indexed)
                _TimelineRow(step: s, last: i == steps.length - 1),
            ],
          ),
        ),

        if (d.status == CustomerStatus.inProgress) ...[
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: BFButton(
                  label: 'Reassign',
                  onTap: () => app.reassign(d),
                  background: BF.glass,
                  foreground: BF.plum,
                  border: BF.inkA(.16),
                  minHeight: 50,
                  radius: 13,
                  fontSize: 13.5,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: BFButton(
                  label: 'Mark complete',
                  onTap: () => app.complete(d.id),
                  background: BF.green,
                  minHeight: 50,
                  radius: 13,
                  fontSize: 13.5,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _Facet extends StatelessWidget {
  const _Facet({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      decoration: BoxDecoration(
        color: BF.field,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: BF.sans(10.5, 600, color: BF.inkA(.42), letterSpacing: 1.05),
          ),
          const SizedBox(height: 4),
          Text(value, style: BF.sans(13.5, 700, height: 1.3)),
        ],
      ),
    ),
  );
}

enum _StepState { done, now, pending }

class _Step {
  const _Step({required this.label, required this.at, required this.state});

  final String label;
  final String at;
  final _StepState state;
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.step, required this.last});

  final _Step step;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final ring = switch (step.state) {
      _StepState.done => BF.green,
      _StepState.now => BF.acc,
      _StepState.pending => BF.inkA(.18),
    };
    final fill = switch (step.state) {
      _StepState.done => BF.green,
      _StepState.now => BF.acc,
      _StepState.pending => BF.sand,
    };
    final line = step.state == _StepState.pending
        ? BF.inkA(.10)
        : BF.green.withValues(alpha: .35);
    final fg = step.state == _StepState.pending ? BF.inkA(.35) : BF.ink;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 26,
            child: Column(
              children: [
                Container(
                  width: 13,
                  height: 13,
                  decoration: BoxDecoration(
                    color: fill,
                    shape: BoxShape.circle,
                    border: Border.all(color: ring, width: 3),
                  ),
                ),
                if (!last)
                  Expanded(
                    child: Container(
                      width: 2,
                      constraints: const BoxConstraints(minHeight: 26),
                      color: line,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: last ? 0 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(step.label, style: BF.sans(13.5, 700, color: fg)),
                  const SizedBox(height: 2),
                  Text(step.at, style: BF.sans(12, 500, color: BF.inkA(.45))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
