import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// Trigger 1 — the ten-second walk-in check-in. Name is the only thing that
/// really matters; the amber banner says up front where auto-allocation will
/// seat this person, so the supervisor can override before committing.
class CheckinScreen extends StatelessWidget {
  const CheckinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BFCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: SectionLabel(
                      'Next queue number',
                      color: BF.inkA(.4),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    app.nextNo,
                    style: BF.serif(30, color: BF.acc, height: 1),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              BFField(
                label: 'Customer name',
                hint: 'e.g. Aisha Bangura',
                value: app.formName,
                onChanged: app.setFormName,
              ),
              const SizedBox(height: 13),
              BFField(
                label: 'Phone number',
                hint: '076 000 000',
                value: app.formPhone,
                onChanged: app.setFormPhone,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 13),
              Text('Braid style', style: BF.sans(12, 600, color: BF.inkA(.55))),
              const SizedBox(height: 8),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final s in kStyles)
                    _StyleChip(
                      name: s,
                      selected: app.formStyle == s,
                      onTap: () => app.setFormStyle(s),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Where auto-allocation will put them, stated before check-in.
        Container(
          decoration: BoxDecoration(
            color: BF.waitBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: BF.gold.withValues(alpha: .35)),
          ),
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: BF.gold,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Text(
                  app.allocPreview,
                  style: BF.sans(12.5, 500, color: BF.goldDeep, height: 1.5),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        BFButton(
          label: 'Check in · issue ${app.nextNo}',
          onTap: app.submitCheckin,
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Name is enough. Phone is optional.',
            style: BF.sans(12, 500, color: BF.inkA(.4)),
          ),
        ),
      ],
    );
  }
}

class _StyleChip extends StatelessWidget {
  const _StyleChip({
    required this.name,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? BF.ink : BF.field,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        // No `alignment` here: it would make the Container expand to the
        // Wrap's full width instead of hugging the label. Vertical padding
        // carries the design's 40px min-height instead.
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: selected ? BF.ink : BF.inkA(.14)),
          ),
          child: Text(
            name,
            style: BF.sans(12.5, 600, color: selected ? BF.white : BF.inkA(.7)),
          ),
        ),
      ),
    );
  }
}
