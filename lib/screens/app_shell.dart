import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../state/app_scope.dart';
import '../state/app_state.dart';
import '../theme/tokens.dart';
import '../widgets/assign_sheet.dart';
import 'chairs_screen.dart';
import 'checkin_screen.dart';
import 'detail_screen.dart';
import 'job_screen.dart';
import 'me_screen.dart';
import 'next_screen.dart';
import 'owner_screen.dart';
import 'queue_screen.dart';
import 'staff_screen.dart';

/// Header + scrolling body + tab bar, with the allocation sheet and toast
/// layered on top. All three roles share this chrome; only the tab set and
/// the body change.
class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    return ColoredBox(
      color: BF.sand,
      child: Stack(
        children: [
          Column(
            children: [
              const _Header(),
              Expanded(
                child: SingleChildScrollView(
                  // Keyed per screen so switching tabs starts at the top
                  // rather than inheriting the previous screen's offset.
                  key: ValueKey(app.screen),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  child: _body(app.screen),
                ),
              ),
            ],
          ),
          const Positioned(left: 0, right: 0, bottom: 0, child: _TabBar()),
          if (app.assignTarget != null) const AssignSheet(),
          if (app.toast != null) _Toast(app.toast!),
        ],
      ),
    );
  }

  Widget _body(BFScreen s) {
    switch (s) {
      case BFScreen.queue:
        return const QueueScreen();
      case BFScreen.checkin:
        return const CheckinScreen();
      case BFScreen.grid:
        return const ChairsScreen();
      case BFScreen.staff:
        return const StaffScreen();
      case BFScreen.detail:
        return const DetailScreen();
      case BFScreen.job:
        return const JobScreen();
      case BFScreen.next:
        return const NextScreen();
      case BFScreen.me:
        return const MeScreen();
      case BFScreen.owner:
        return const OwnerScreen();
    }
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final (title, sub) = _titleFor(app);

    final roleLabel = switch (app.role) {
      Role.supervisor => 'Supervisor · Front desk',
      Role.braider => app.me.name,
      Role.owner => 'Owner',
      null => '',
    };

    return Container(
      decoration: BoxDecoration(
        color: BF.sand,
        border: Border(bottom: BorderSide(color: BF.inkA(.07))),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 16,
        20,
        14,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (app.canBack) ...[
            _SquareButton(label: '‹', onTap: app.back),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  roleLabel.toUpperCase(),
                  style: BF.sans(
                    10,
                    700,
                    color: BF.acc,
                    height: 1,
                    letterSpacing: 1.6,
                  ),
                ),
                const SizedBox(height: 5),
                Text(title, style: BF.serif(30, height: 1.1)),
                if (sub.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(sub, style: BF.sans(12.5, 500, color: BF.inkA(.5))),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Material(
              color: BF.white,
              borderRadius: BorderRadius.circular(9),
              child: InkWell(
                onTap: app.logout,
                borderRadius: BorderRadius.circular(9),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 11,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(color: BF.inkA(.12)),
                  ),
                  child: Text(
                    'Switch',
                    style: BF.sans(11.5, 600, color: BF.inkA(.55)),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  (String, String) _titleFor(AppState app) {
    final onCount = app.braiders.where((b) => b.on).length;
    final on = onCount < 1 ? 1 : onCount;
    switch (app.screen) {
      case BFScreen.queue:
        return (
          'Live queue',
          '${app.waiting.length} waiting · ${app.active.length} in chairs',
        );
      case BFScreen.checkin:
        return ('Walk-in check-in', 'Name, phone, style — that’s it');
      case BFScreen.grid:
        return (
          'Braider chairs',
          '${app.freeBraiders().length} free of $on on shift',
        );
      case BFScreen.staff:
        return ('Staff', 'Roster and shifts');
      case BFScreen.detail:
        return (
          'Customer',
          app.detail != null ? 'Queue ${app.detail!.no}' : '',
        );
      case BFScreen.job:
        final cur = app.meCurrent;
        return (
          'My chair',
          cur != null ? 'With ${cur.name}' : 'No client right now',
        );
      case BFScreen.next:
        return ('Up next', '${app.waiting.length} in the queue');
      case BFScreen.me:
        return (app.me.firstName, 'Your shift and stats');
      case BFScreen.owner:
        return ('Today', 'Sandra’s Braiding Studio');
    }
  }
}

class _SquareButton extends StatelessWidget {
  const _SquareButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 4),
    child: Material(
      color: BF.white,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: BF.inkA(.12)),
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: BF.plum),
          ),
        ),
      ),
    ),
  );
}

class _TabBar extends StatelessWidget {
  const _TabBar();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);

    final tabs = switch (app.role) {
      Role.supervisor => const [
        (BFScreen.queue, 'Queue'),
        (BFScreen.checkin, 'Check in'),
        (BFScreen.grid, 'Chairs'),
        (BFScreen.staff, 'Staff'),
      ],
      Role.braider => const [
        (BFScreen.job, 'My chair'),
        (BFScreen.next, 'Up next'),
        (BFScreen.me, 'Me'),
      ],
      _ => const [
        (BFScreen.owner, 'Today'),
        (BFScreen.grid, 'Chairs'),
        (BFScreen.staff, 'Staff'),
      ],
    };

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          decoration: BoxDecoration(
            color: BF.sand.withValues(alpha: .94),
            border: Border(top: BorderSide(color: BF.inkA(.08))),
          ),
          padding: EdgeInsets.fromLTRB(
            12,
            9,
            12,
            12 + MediaQuery.of(context).padding.bottom,
          ),
          child: Row(
            children: [
              for (final (screen, label) in tabs)
                Expanded(
                  child: _Tab(
                    label: label,
                    active: app.screen == screen,
                    onTap: () => app.go(screen),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = active ? BF.acc : BF.inkA(.4);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 52),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: active ? BF.acc : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: color, width: 2.5),
                ),
              ),
              const SizedBox(height: 5),
              Text(label, style: BF.sans(10.5, 700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _Toast extends StatelessWidget {
  const _Toast(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 104 + MediaQuery.of(context).padding.bottom,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: BF.ink,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: BF.ink.withValues(alpha: .35),
              blurRadius: 30,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: BF.mint,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Text(
                message,
                style: BF.sans(13, 600, color: BF.white, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
