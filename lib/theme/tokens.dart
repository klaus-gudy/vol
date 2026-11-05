import 'package:flutter/material.dart';

/// Design tokens.
///
/// Originally lifted from Braidflow.dc.html (warm sand and terracotta), now
/// re-mapped to the DSE investor portal's palette — deep navy ground, glass
/// surfaces, and an emerald→teal→blue accent. Values were read off
/// investor.dse.co.tz's computed styles rather than eyeballed:
///
///   --background-start-rgb  10,22,40      page ground
///   --background-end-rgb    15,30,50      page ground, bottom
///   body color              226,232,240   primary text
///   glass panel             rgba(255,255,255,.15) + backdrop-filter: blur(40px)
///   accent gradient         #10B981 → #2DD4BF → #09A0DB
///
/// Token *names* are unchanged from the light theme on purpose: `ink` is the
/// colour you write with, so on a dark ground it is light, and the ~70
/// `inkA()` call sites for muted text stay correct without edits.
class BF {
  BF._();

  // ── ground ─────────────────────────────────────────────────────────────
  /// App background, top of the gradient. `--background-start-rgb`.
  static const sand = Color(0xFF0A1628);

  /// App background, bottom of the gradient. `--background-end-rgb`.
  static const sandEnd = Color(0xFF0F1E32);

  /// The page behind the phone frame — a shade under the app itself.
  static const canvas = Color(0xFF060D18);

  /// Elevated opaque surface for hero panels. DSE's raised card colour.
  static const deep = Color(0xFF132035);

  static const bgGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [sand, sandEnd],
  );

  // ── foreground ─────────────────────────────────────────────────────────
  /// Primary text. DSE's body colour (slate-200).
  static const ink = Color(0xFFE2E8F0);

  static const white = Color(0xFFFFFFFF);

  /// Secondary foreground, used for button labels on glass.
  static const plum = Color(0xFF7DD3FC);

  // ── accents ────────────────────────────────────────────────────────────
  /// DSE blue — the primary accent.
  static const acc = Color(0xFF09A0DB);

  static const teal = Color(0xFF2DD4BF);

  /// Alias kept from the light theme: the live/progress highlight.
  static const ember = teal;

  static const green = Color(0xFF10B981);

  /// Waiting / caution.
  static const gold = Color(0xFFFBBF24);

  /// Amber text on a dark ground.
  static const goldInk = Color(0xFFFCD34D);
  static const goldDeep = Color(0xFFFDE68A);

  /// Toast dot.
  static const mint = Color(0xFF4ADE80);

  /// DSE's signature CTA gradient.
  static const accentGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [green, teal, acc],
  );

  // ── glass ──────────────────────────────────────────────────────────────
  /// Standard translucent card fill. Reads as frosted over [bgGradient].
  static Color get glass => white.withValues(alpha: .055);

  /// A dimmer card, for inactive or completed rows.
  static Color get glassDim => white.withValues(alpha: .028);

  /// Floating chrome — tab bar, sheets, toast — where a real blur is applied.
  static Color get glassStrong => white.withValues(alpha: .10);

  /// Input fill.
  static Color get field => white.withValues(alpha: .04);

  /// Blur radius for floating chrome. DSE uses 40px on its nav pill.
  static const double blurSigma = 24;

  // ── ink at opacity ─────────────────────────────────────────────────────
  static Color inkA(double o) => ink.withValues(alpha: o);
  static Color whiteA(double o) => white.withValues(alpha: o);

  /// Hairline borders. On a dark ground these are light, not dark.
  static Color get line => white.withValues(alpha: .09);
  static Color get line10 => white.withValues(alpha: .12);

  // ── status tints ───────────────────────────────────────────────────────
  static Color get waitBg => gold.withValues(alpha: .13);
  static Color get progBg => acc.withValues(alpha: .15);
  static Color get doneBg => green.withValues(alpha: .13);

  /// Avatar tints — translucent so light initials stay legible on navy.
  static final avatars = <Color>[
    acc.withValues(alpha: .22),
    teal.withValues(alpha: .22),
    green.withValues(alpha: .22),
    gold.withValues(alpha: .20),
    const Color(0xFFA78BFA).withValues(alpha: .22),
    const Color(0xFF38BDF8).withValues(alpha: .22),
    const Color(0xFFF472B6).withValues(alpha: .20),
  ];

  static Color avatarFor(int id) => avatars[id % avatars.length];

  // ── glow ───────────────────────────────────────────────────────────────
  /// DSE's accent glow, softened for use behind buttons and hero cards.
  static List<BoxShadow> glow(Color color, {double opacity = .35}) => [
    BoxShadow(
      color: color.withValues(alpha: opacity),
      blurRadius: 24,
      spreadRadius: -4,
      offset: const Offset(0, 6),
    ),
  ];

  // ── typography ─────────────────────────────────────────────────────────
  // Manrope ships from Google Fonts as a variable font only, so every weight
  // must carry a matching `wght` axis value — `fontWeight` alone would leave
  // canvaskit synthesising the bold. (DSE's portal also sets Manrope.)
  static TextStyle sans(
    double size,
    int weight, {
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Manrope',
      fontSize: size,
      fontWeight: FontWeight.values[(weight ~/ 100) - 1],
      fontVariations: [FontVariation('wght', weight.toDouble())],
      color: color ?? ink,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// The recurring `700 10.5px / .14em / uppercase` section label.
  static TextStyle eyebrow({
    Color? color,
    double size = 10.5,
    double ls = .14,
  }) => sans(
    size,
    700,
    color: color ?? inkA(.5),
    height: 1,
    letterSpacing: size * ls,
  );

  // ── shapes ─────────────────────────────────────────────────────────────
  // Note: the border stays uniform on purpose. Flutter refuses a
  // `borderRadius` on a BoxDecoration whose border sides differ, so the
  // design's `border-left: 3px` accent is painted as a clipped stripe by
  // [BFCard] rather than as a thicker border side.
  static BoxDecoration card({
    Color? background,
    double radius = 16,
    Color? border,
  }) {
    return BoxDecoration(
      color: background ?? glass,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? line),
    );
  }
}
