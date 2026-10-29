import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../theme/tokens.dart';

/// Brief branded splash shown right after sign-in, before the role's first
/// page. Plays once, then hands over to the app shell via
/// [AppState.finishSplash]; the root cross-fades between the two.
class WelcomeSplash extends StatefulWidget {
  const WelcomeSplash({super.key});

  static const duration = Duration(milliseconds: 2200);

  @override
  State<WelcomeSplash> createState() => _WelcomeSplashState();
}

class _WelcomeSplashState extends State<WelcomeSplash>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: WelcomeSplash.duration)
        ..forward().whenComplete(() {
          if (mounted) AppScope.of(context).finishSplash();
        });

  // Staggered segments of one timeline.
  late final _mark = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, .35, curve: Curves.easeOutBack),
  );
  late final _title = CurvedAnimation(
    parent: _c,
    curve: const Interval(.2, .55, curve: Curves.easeOutCubic),
  );
  late final _sub = CurvedAnimation(
    parent: _c,
    curve: const Interval(.4, .7, curve: Curves.easeOutCubic),
  );
  late final _glow = CurvedAnimation(
    parent: _c,
    curve: const Interval(0, .8, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _roleLine(Role? r) => switch (r) {
    Role.owner => 'Opening your studio overview',
    Role.supervisor => 'Opening the live queue',
    Role.braider => 'Opening your chair',
    null => '',
  };

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final first = (app.userName ?? '').split(' ').first;

    return DecoratedBox(
      decoration: const BoxDecoration(gradient: BF.bgGradient),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0, -.25 + .25 * (1 - _glow.value)),
                    radius: .4 + .7 * _glow.value,
                    colors: [
                      BF.teal.withValues(alpha: .28 * _glow.value),
                      BF.acc.withValues(alpha: .14 * _glow.value),
                      Colors.transparent,
                    ],
                    stops: const [0, .45, 1],
                  ),
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Opacity(
                    opacity: _mark.value.clamp(0, 1),
                    child: Transform.scale(
                      scale: .6 + .4 * _mark.value,
                      child: Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: BF.accentGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: BF.glow(BF.acc, opacity: .5),
                        ),
                        child: Text(
                          'B',
                          style: BF.sans(38, 800, color: BF.white, height: 1),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _rise(
                    _title,
                    Text(
                      first.isEmpty ? 'Welcome' : 'Welcome, $first',
                      textAlign: TextAlign.center,
                      style: BF.sans(
                        28,
                        800,
                        color: BF.white,
                        height: 1.1,
                        letterSpacing: -.3,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _rise(
                    _sub,
                    Text(
                      _roleLine(app.role),
                      style: BF.sans(14, 500, color: BF.whiteA(.6)),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 80,
              right: 80,
              bottom: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: _c.value,
                  minHeight: 3,
                  backgroundColor: BF.whiteA(.1),
                  valueColor: const AlwaysStoppedAnimation(BF.acc),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rise(Animation<double> a, Widget child) => Opacity(
    opacity: a.value.clamp(0, 1),
    child: Transform.translate(
      offset: Offset(0, 14 * (1 - a.value)),
      child: child,
    ),
  );
}
