import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:braidflow/main.dart';
import 'package:braidflow/models/models.dart';
import 'package:braidflow/state/app_state.dart';

void main() {
  group('accounts', () {
    test('signs in with a seeded account and rejects bad credentials', () {
      final app = AppState(ticking: false);
      addTearDown(app.dispose);

      expect(app.signInWithEmail('grace@braidflow.app', 'nope'), isNotNull);
      expect(app.signInWithEmail('ghost@braidflow.app', 'desk1234'), isNotNull);
      expect(app.role, isNull);

      expect(app.signInWithEmail(' Grace@Braidflow.app ', 'desk1234'), isNull);
      expect(app.role, Role.supervisor);
    });

    test('sign up creates and signs in; duplicate email is refused', () {
      final app = AppState(ticking: false);
      addTearDown(app.dispose);

      expect(
        app.signUp(
          name: 'Ama',
          email: 'ama@studio.com',
          password: 'password1',
          role: Role.owner,
        ),
        isNull,
      );
      expect(app.role, Role.owner);

      app.logout();
      expect(
        app.signUp(
          name: 'Ama 2',
          email: 'AMA@studio.com',
          password: 'password1',
          role: Role.owner,
        ),
        isNotNull,
      );
      expect(app.role, isNull);
    });
  });

  group('pages', () {
    testWidgets('email sign-in validates, then lands in the app', (t) async {
      await t.binding.setSurfaceSize(const Size(1000, 900));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final state = AppState(ticking: false);
      addTearDown(state.dispose);
      await t.pumpWidget(BraidflowApp(state: state));

      await t.tap(find.text('Sign in with email'));
      await t.pumpAndSettle();
      await t.tap(find.text('Sign in'));
      await t.pump();
      expect(find.text('Enter a valid email.'), findsOneWidget);

      await t.enterText(find.byType(TextField).at(0), 'grace@braidflow.app');
      await t.enterText(find.byType(TextField).at(1), 'desk1234');
      await t.tap(find.text('Sign in'));
      await t.pumpAndSettle();

      expect(state.role, Role.supervisor);
      expect(find.text('Live queue'), findsOneWidget);
      expect(find.text('Welcome back'), findsNothing);
    });

    testWidgets('forgot password shows a confirmation', (t) async {
      await t.binding.setSurfaceSize(const Size(1000, 900));
      addTearDown(() => t.binding.setSurfaceSize(null));
      final state = AppState(ticking: false);
      addTearDown(state.dispose);
      await t.pumpWidget(BraidflowApp(state: state));

      await t.tap(find.text('Sign in with email'));
      await t.pumpAndSettle();
      await t.tap(find.text('Forgot password?'));
      await t.pumpAndSettle();
      await t.enterText(find.byType(TextField), 'someone@studio.com');
      await t.tap(find.text('Send reset link'));
      await t.pump();
      expect(find.text('Check your email'), findsOneWidget);
    });
  });
}
