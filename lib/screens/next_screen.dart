import 'package:flutter/material.dart';

import '../state/app_scope.dart';
import '../theme/tokens.dart';
import '../widgets/common.dart';

/// The queue as a braider sees it: read-only.
///
/// She can see who is coming but cannot pull from it — the desk allocates, or
/// the next customer arrives automatically when she finishes. That asymmetry
/// is what stops two braiders claiming the same walk-in.
class NextScreen extends StatelessWidget {
  const NextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final waiting = app.waiting;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (waiting.isEmpty)
          const EmptyNote('Queue is empty.', padding: 26)
        else
          for (final c in waiting) ...[
            BFCard(
              radius: 14,
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  QueueBadge(
                    no: c.no,
                    background: BF.waitBg,
                    foreground: BF.goldInk,
                    size: 42,
                    showCaption: false,
                    fontSize: 14,
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(c.name, style: BF.sans(14.5, 700)),
                        const SizedBox(height: 1),
                        Text(
                          c.style,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: BF.sans(12.5, 500, color: BF.inkA(.5)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'waiting ${app.fmt(app.minsSince(c.checkedInAt))}',
                      textAlign: TextAlign.right,
                      style: BF.sans(11.5, 600, color: BF.inkA(.42)),
                    ),
                  ),
                ],
              ),
            ),
            if (c != waiting.last) const SizedBox(height: 9),
          ],
        const SizedBox(height: 16),
        Text(
          "Braiders see the queue but don't assign from it — the desk "
          'allocates, or it comes to you automatically when you finish.',
          style: BF.sans(12.5, 500, color: BF.inkA(.45), height: 1.5),
        ),
      ],
    );
  }
}
