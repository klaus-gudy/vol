import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'screens/app_shell.dart';
import 'screens/login_screen.dart';
import 'state/app_scope.dart';
import 'state/app_state.dart';
import 'theme/tokens.dart';

void main() => runApp(const BraidflowApp());

class BraidflowApp extends StatefulWidget {
  const BraidflowApp({super.key});

  @override
  State<BraidflowApp> createState() => _BraidflowAppState();
}

class _BraidflowAppState extends State<BraidflowApp> {
  final AppState _state = AppState();

  @override
  void dispose() {
    _state.dispose();
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
          fontFamily: 'Manrope',
          scaffoldBackgroundColor: BF.sand,
          colorScheme: ColorScheme.fromSeed(
            seedColor: BF.acc,
            primary: BF.acc,
            surface: BF.sand,
          ),
          splashFactory: InkSparkle.splashFactory,
        ),
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
      value: signedIn
          ? SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
            )
          : SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
            ),
      child: Scaffold(
        backgroundColor: BF.canvas,
        // The keyboard is handled inside the scrolling body, so the tab bar
        // stays pinned rather than being pushed off-screen.
        resizeToAvoidBottomInset: false,
        body: PhoneFrame(
          child: signedIn ? const AppShell() : const LoginScreen(),
        ),
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
              // The artboard has no notch or home indicator, so drop the
              // host window's insets rather than inheriting desktop padding.
              data: MediaQuery.of(context).copyWith(
                padding: const EdgeInsets.only(top: 24, bottom: 12),
                viewPadding: const EdgeInsets.only(top: 24, bottom: 12),
                viewInsets: EdgeInsets.zero,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
