import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';

void main() => runApp(const BraidflowApp());

class BraidflowApp extends StatefulWidget {
  const BraidflowApp({super.key, this.state});

  /// Injected by tests so they can drive and inspect the store. In the app
  /// this is null and the widget owns its own [AppState].
  final AppState? state;

  @override
  State<BraidflowApp> createState() => _BraidflowAppState();
}

class _BraidflowAppState extends State<BraidflowApp> {
  late final AppState _state = widget.state ?? AppState();

  @override
  void dispose() {
    // Only dispose what we created; an injected store belongs to the caller.
    if (widget.state == null) _state.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScope(
      state: _state,
      child: MaterialApp(
        title: 'Braidflow',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          fontFamily: 'Manrope',
          scaffoldBackgroundColor: BF.sand,
          colorScheme: ColorScheme.fromSeed(
            seedColor: BF.acc,
            brightness: Brightness.dark,
            primary: BF.acc,
            surface: BF.sand,
          ),
          splashFactory: InkSparkle.splashFactory,
        ),
        builder: (context, child) => PhoneFrame(child: child!),
        home: const _Root(),
      ),
    );
  }
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final signedIn = app.role != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // The whole app is dark now, so status bar icons are light throughout.
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: BF.canvas,
        // The keyboard is handled inside the scrolling body, so the tab bar
        // stays pinned rather than being pushed off-screen.
        resizeToAvoidBottomInset: false,
        body: signedIn ? const AppShell() : const LoginScreen(),
      ),
    );
  }
}

/// On a phone the app fills the screen. On anything wider — the Chrome test
/// target, a tablet, desktop — it is pinned to the design's 402×874 artboard
/// and centred on the canvas colour, so proportions match the source design
/// instead of stretching a mobile layout across a monitor.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({super.key, required this.child});

  static const double designWidth = 402;
  static const double designHeight = 874;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final wide = size.width > designWidth + 40;

    if (!wide) return child;

    final height = size.height > designHeight + 40 ? designHeight : size.height;

    return ColoredBox(
      color: BF.canvas,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(44),
          child: SizedBox(
            width: designWidth,
            height: height,
            child: MediaQuery(
              // The artboard has no notch or home indicator, so substitute
              // fixed padding rather than inheriting the desktop window's.
              // viewInsets is deliberately left alone — it carries the
              // keyboard height that AppShell needs to scroll around.
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 12),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
