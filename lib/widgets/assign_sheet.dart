import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import 'common.dart';

/// Bottom sheet for allocating a waiting customer to a chair.
///
/// The longest-idle free braider is flagged RECOMMENDED — the same braider
/// auto-allocation would have picked — so an override is a deliberate act
/// rather than a guess.
class AssignSheet extends StatelessWidget {
  const AssignSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final target = app.assignTarget;
    if (target == null) return const SizedBox.shrink();

    final free = app.freeBraiders();
    final recommendedId = free.isNotEmpty ? free.first.id : null;

    // Free chairs float to the top of the list.
    final options = [...app.braiders]
      ..sort((x, y) {
        final fx = app.isFree(x) ? 1 : 0;
        final fy = app.isFree(y) ? 1 : 0;
        return fy - fx;
      });

    return Positioned.fill(
      child: ColoredBox(
        color: BF.ink.withValues(alpha: .5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * .78,
              ),
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: BF.sand,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 34),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: BF.inkA(.18),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Allocate ${target.name}',
                        style: BF.serif(26, height: 1.1),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${target.style} · queue ${target.no}',
                        style: BF.sans(12.5, 500, color: BF.inkA(.5)),
                      ),
                      const SizedBox(height: 16),
                      for (final b in options) ...[
                        _Option(
                          braiderId: b.id,
                          recommended: b.id == recommendedId,
                          onPick: () {
                            if (!b.on) {
                              app.say('${b.firstName} is off shift.');
                              return;
                            }
                            app.assign(target.id, b.id);
                          },
                        ),
                        const SizedBox(height: 9),
                      ],
                      const SizedBox(height: 5),
                      BFButton(
                        label: 'Keep waiting',
                        onTap: app.closeAssign,
                        background: BF.white,
                        foreground: BF.inkA(.6),
                        border: BF.inkA(.16),
                        minHeight: 50,
                        radius: 13,
                        fontSize: 13.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.braiderId,
    required this.recommended,
    required this.onPick,
  });

  final int braiderId;
  final bool recommended;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final b = app.braiderById(braiderId);
    final current = app.busyWith(b.id);
    final free = app.isFree(b);

    final sub = !b.on
        ? 'Off shift'
        : free
        ? 'Free · idle ${app.fmt(app.minsSince(b.idleSince))}'
        : 'Busy with ${current!.name}';

    final tag = !b.on
        ? 'OFF'
        : recommended
        ? 'RECOMMENDED'
        : free
        ? 'FREE'
        : 'QUEUE BEHIND';

    final tagColor = !b.on
        ? BF.inkA(.35)
        : free
        ? BF.green
        : BF.gold;

    return Opacity(
      opacity: b.on ? 1 : .5,
      child: Container(
        decoration: BoxDecoration(
          color: recommended ? BF.doneBg : BF.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: recommended ? BF.green.withValues(alpha: .45) : BF.line10,
          ),
        ),
        child: Tappable(
          onTap: onPick,
          child: Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.all(13),
            child: Row(
              children: [
                Avatar(
                  initials: b.initials,
                  color: BF.avatarFor(b.id),
                  size: 40,
                  radius: 11,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(b.name, style: BF.sans(14.5, 700)),
                      const SizedBox(height: 2),
                      Text(sub, style: BF.sans(12, 500, color: BF.inkA(.52))),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    tag,
                    textAlign: TextAlign.right,
                    style: BF.sans(11, 700, color: tagColor),
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
