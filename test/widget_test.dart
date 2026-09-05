import 'package:braidflow/main.dart';
import 'package:braidflow/models/models.dart';
import 'package:braidflow/screens/app_shell.dart';
import 'package:braidflow/screens/login_screen.dart';
import 'package:braidflow/state/app_scope.dart';
import 'package:braidflow/state/app_state.dart';
import 'package:braidflow/theme/tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Render coverage for every screen in every role.
///
/// This exists because the first browser run showed blank cards: a
/// `borderRadius` on a non-uniform `Border` throws during paint, which is
/// invisible to `flutter analyze` and to the unit tests. Anything that throws
/// while building or painting fails here instead.
void main() {
  /// Pumps a screen inside the real shell, with control over text scale and
  /// keyboard insets.
  Future<AppState> pumpScreen(
    WidgetTester tester, {
    Role? role,
    BFScreen screen = BFScreen.queue,
    double textScale = 1,
    double keyboardInset = 0,
    Size size = const Size(402, 874),
  }) async {
    await tester.binding.setSurfaceSize(size);
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final state = AppState(ticking: false);
    addTearDown(state.dispose);
    if (role != null) {
      state.signIn(role, screen, asBraider: role == Role.braider ? 1 : null);
    }

    await tester.pumpWidget(
      AppScope(
        state: state,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(useMaterial3: true, fontFamily: 'Manrope'),
          home: MediaQuery(
            data: MediaQueryData(
              size: size,
              textScaler: TextScaler.linear(textScale),
              viewInsets: EdgeInsets.only(bottom: keyboardInset),
              padding: const EdgeInsets.only(top: 24, bottom: 12),
            ),
            child: Scaffold(
              backgroundColor: BF.canvas,
              resizeToAvoidBottomInset: false,
              body: role == null ? const LoginScreen() : const AppShell(),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    return state;
  }

  /// Every screen, keyed by the role whose tab bar reaches it.
  const coverage = <(Role, BFScreen, String)>[
    (Role.supervisor, BFScreen.queue, 'Live queue'),
    (Role.supervisor, BFScreen.checkin, 'Walk-in check-in'),
    (Role.supervisor, BFScreen.grid, 'Braider chairs'),
    (Role.supervisor, BFScreen.staff, 'Staff'),
    (Role.braider, BFScreen.job, 'My chair'),
    (Role.braider, BFScreen.next, 'Up next'),
    (Role.braider, BFScreen.me, 'Amina'),
    (Role.owner, BFScreen.owner, 'Today'),
  ];

  group('renders without throwing', () {
    testWidgets('login', (tester) async {
      await pumpScreen(tester);
      expect(find.text('Braidflow'), findsOneWidget);
      expect(find.text('Sandra Musa'), findsOneWidget);
      expect(find.text('Grace Kanu'), findsOneWidget);
      expect(find.text('Amina Sesay'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    for (final (role, screen, title) in coverage) {
      testWidgets('${role.name} · ${screen.name}', (tester) async {
        await pumpScreen(tester, role: role, screen: screen);
        expect(find.text(title), findsWidgets);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('customer detail timeline', (tester) async {
      final state = await pumpScreen(tester, role: Role.supervisor);
      state.push(BFScreen.detail, detail: 104);
      await tester.pump();

      expect(find.text('Josephine Cole'), findsWidgets);
      expect(find.text('Status timeline'.toUpperCase()), findsOneWidget);
      expect(find.text('Mark complete'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('allocation sheet', (tester) async {
      final state = await pumpScreen(tester, role: Role.supervisor);
      state.openAssign(107);
      await tester.pump();

      expect(find.text('Allocate Fatmata Turay'), findsOneWidget);
      expect(find.text('RECOMMENDED'), findsOneWidget);
      expect(find.text('Keep waiting'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('toast', (tester) async {
      final state = await pumpScreen(tester, role: Role.supervisor);
      state.say('Kadiatu Koroma completed. You are now free.');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text('Kadiatu Koroma completed. You are now free.'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);

      // Drain the auto-dismiss timer. The card stays mounted so it can
      // animate out, so assert on the fade rather than on removal.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();
      final fade = tester.widget<AnimatedOpacity>(
        find.ancestor(
          of: find.text('Kadiatu Koroma completed. You are now free.'),
          matching: find.byType(AnimatedOpacity),
        ),
      );
      expect(fade.opacity, 0);
    });
  });

  // The layout uses fixed type sizes lifted from the design. Accessibility
  // text settings scale all of it, so every screen is re-rendered at the
  // sizes a user can actually pick.
  group('survives large text', () {
    for (final scale in const [1.3, 1.6]) {
      for (final (role, screen, _) in coverage) {
        testWidgets('${scale}x · ${role.name} · ${screen.name}', (
          tester,
        ) async {
          await pumpScreen(
            tester,
            role: role,
            screen: screen,
            textScale: scale,
          );
          expect(
            tester.takeException(),
            isNull,
            reason: '${screen.name} overflows at ${scale}x text',
          );
        });
      }
    }
  });

  // A phone keyboard covers roughly the bottom 40% of the screen. The
  // check-in form must stay reachable underneath it.
  group('on-screen keyboard', () {
    testWidgets('check-in form scrolls clear of the keyboard', (tester) async {
      await pumpScreen(
        tester,
        role: Role.supervisor,
        screen: BFScreen.checkin,
        keyboardInset: 336,
      );
      expect(tester.takeException(), isNull);

      // The submit button must be reachable above the keyboard, not stranded
      // behind it. Each TextField nests its own horizontal Scrollable, so
      // match the shell's by axis.
      final submit = find.textContaining('Check in · issue');
      final formScroll = find.byWidgetPredicate(
        (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
      );
      expect(formScroll, findsOneWidget);

      await tester.scrollUntilVisible(submit, 120, scrollable: formScroll);
      await tester.pumpAndSettle();

      const keyboardTop = 874.0 - 336.0;
      expect(
        tester.getRect(submit).bottom,
        lessThanOrEqualTo(keyboardTop),
        reason: 'submit button is hidden behind the keyboard',
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('narrow and short viewports', () {
    testWidgets('small phone (320x568)', (tester) async {
      await pumpScreen(
        tester,
        role: Role.supervisor,
        size: const Size(320, 568),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('login on a short screen', (tester) async {
      await pumpScreen(tester, size: const Size(360, 600));
      expect(tester.takeException(), isNull);
    });
  });

  group('full app', () {
    testWidgets('signs in and switches roles', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 900));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final state = AppState(ticking: false);
      addTearDown(state.dispose);
      await tester.pumpWidget(BraidflowApp(state: state));
      await tester.pump();

      expect(find.text('Sign in as'), findsOneWidget);

      await tester.tap(find.text('Grace Kanu'));
      await tester.pump();
      expect(state.role, Role.supervisor);
      expect(find.text('Live queue'), findsOneWidget);

      await tester.tap(find.text('Switch'));
      await tester.pump();
      expect(state.role, isNull);
      expect(find.text('Sign in as'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
