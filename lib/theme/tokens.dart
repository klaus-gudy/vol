import 'package:flutter/material.dart';

/// Design tokens lifted straight from Braidflow.dc.html.
/// The constant names mirror the ones in the source (SAND/INK/ACC/GOLD/GREEN)
/// so the two stay easy to diff.
class BF {
  BF._();

  // ── palette ────────────────────────────────────────────────────────────
  static const sand = Color(0xFFF7F1E8); // app background
  static const ink = Color(0xFF17101B); // near-black
  static const acc = Color(0xFFB4522A); // terracotta accent
  static const gold = Color(0xFFC9962B);
  static const green = Color(0xFF1F7A5C);

  static const canvas = Color(0xFFEFE7DB); // page behind the phone
  static const plum = Color(0xFF3B1F3E); // secondary ink
  static const ember = Color(0xFFE58A5E); // live dot / bar on dark
  static const mint = Color(0xFF5FD3A6); // toast dot

  static const white = Color(0xFFFFFFFF);
  static const field = Color(0xFFFCFAF6); // input background
  static const goldInk = Color(0xFF8A6410); // waiting text
  static const goldDeep = Color(0xFF7A5A0E); // alloc-preview text

  // status tints
  static const waitBg = Color(0xFFFBF3E2);
  static const progBg = Color(0xFFFBEBE3);
  static const doneBg = Color(0xFFE8F3EE);

  /// Avatar tints — `AV` in the source, indexed by `id % length`.
  static const avatars = <Color>[
    Color(0xFFF3D9C8),
    Color(0xFFE7DCC4),
    Color(0xFFD9E3D5),
    Color(0xFFEFD6D6),
    Color(0xFFDDD8EA),
    Color(0xFFE3E0CE),
    Color(0xFFF0E1CB),
  ];

  static Color avatarFor(int id) => avatars[id % avatars.length];

  // ── ink at opacity ─────────────────────────────────────────────────────
  static Color inkA(double o) => ink.withValues(alpha: o);
  static Color whiteA(double o) => white.withValues(alpha: o);

  static Color get line => inkA(.09);
  static Color get line10 => inkA(.10);

  // ── typography ─────────────────────────────────────────────────────────
  // Manrope ships from Google Fonts as a variable font only, so every weight
  // must carry a matching `wght` axis value — `fontWeight` alone would leave
  // canvaskit synthesising the bold.
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

  /// Instrument Serif — display face for headings and big numerals.
  static TextStyle serif(
    double size, {
    Color? color,
    double? height,
    double? letterSpacing,
    FontStyle? style,
  }) {
    return TextStyle(
      fontFamily: 'InstrumentSerif',
      fontSize: size,
      fontWeight: FontWeight.w400,
      fontStyle: style,
      color: color ?? ink,
      height: height,
      letterSpacing: letterSpacing,
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
    color: color ?? inkA(.42),
    height: 1,
    letterSpacing: size * ls,
  );

  // ── shapes ─────────────────────────────────────────────────────────────
  // Note: the border stays uniform on purpose. Flutter refuses a
  // `borderRadius` on a BoxDecoration whose border sides differ, so the
  // design's `border-left: 3px` accent is painted as a clipped stripe by
  // [BFCard] rather than as a thicker border side.
  static BoxDecoration card({
    Color background = white,
    double radius = 16,
    Color? border,
  }) {
    return BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: border ?? line),
    );
  }
}
