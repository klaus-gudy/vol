import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';

/// Role picker. Dark panel with a terracotta glow, bottom-aligned — the app's
/// only screen outside the tabbed shell.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    final roles = <_RoleCard>[
      _RoleCard(
        name: 'Sandra Musa',
        sub: 'Owner · full access',
        initials: 'SM',
        color: const Color(0xFFD9E3D5),
        onTap: () => app.signIn(Role.owner, BFScreen.owner),
      ),
      _RoleCard(
        name: 'Grace Kanu',
        sub: 'Supervisor · desk & allocation',
        initials: 'GK',
        color: const Color(0xFFF3D9C8),
        onTap: () => app.signIn(Role.supervisor, BFScreen.queue),
      ),
      _RoleCard(
        name: 'Amina Sesay',
        sub: 'Braider · chair 1',
        initials: 'AS',
        color: const Color(0xFFEFD6D6),
        onTap: () => app.signIn(Role.braider, BFScreen.job, asBraider: 1),
      ),
    ];

    return Container(
      color: BF.ink,
      child: Stack(
        children: [
          // radial terracotta glow across the top third
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 340,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(-0.6, -1),
                  radius: 1.2,
                  colors: [BF.acc.withValues(alpha: .55), Colors.transparent],
                  stops: const [0, .7],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(26, 0, 26, 46),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "SANDRA'S BRAIDING STUDIO",
                    style: BF.sans(
                      11,
                      400,
                      color: BF.whiteA(.5),
                      height: 1,
                      letterSpacing: 2.42,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Braidflow',
                    style: BF.serif(54, color: BF.white, height: .95),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Sign in as',
                    style: BF.sans(14, 400, color: BF.whiteA(.6), height: 1.5),
                  ),
                  const SizedBox(height: 30),
                  for (final r in roles) ...[
                    r,
                    if (r != roles.last) const SizedBox(height: 11),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.name,
    required this.sub,
    required this.initials,
    required this.color,
    required this.onTap,
  });

  final String name;
  final String sub;
  final String initials;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: BF.whiteA(.07),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: BF.whiteA(.16)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(initials, style: BF.sans(16, 700, color: BF.ink)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(name, style: BF.sans(15.5, 700, color: BF.white)),
                    const SizedBox(height: 2),
                    Text(sub, style: BF.sans(12.5, 500, color: BF.whiteA(.55))),
                  ],
                ),
              ),
              Text('›', style: TextStyle(color: BF.whiteA(.4), fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
