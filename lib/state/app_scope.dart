import 'package:flutter/widgets.dart';

import 'app_state.dart';

/// Makes [AppState] available down the tree and rebuilds dependents when it
/// notifies. Keeps the app dependency-free — no external state package needed
/// for a store this size.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'No AppScope found in context');
    return scope!.notifier!;
  }
}
