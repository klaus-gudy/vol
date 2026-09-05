import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../theme/tokens.dart';

/// `700 10.5px / .14em / uppercase` — the section label used on every screen.
class SectionLabel extends StatelessWidget {
  const SectionLabel(
    this.text, {
    super.key,
    this.color,
    this.size = 10.5,
    this.ls = .14,
  });

  final String text;
  final Color? color;
  final double size;
  final double ls;

  @override
  Widget build(BuildContext context) => Text(
    text.toUpperCase(),
    style: BF.eyebrow(color: color, size: size, ls: ls),
  );
}

/// White rounded card with the hairline ink border.
class BFCard extends StatelessWidget {
  const BFCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.background,
    this.radius = 16,
    this.border,
    this.leftAccent,
    this.blur = false,
  });

  final Widget child;
  final EdgeInsets padding;

  /// Defaults to [BF.glass] — translucent, so the page gradient shows through.
  final Color? background;
  final double radius;
  final Color? border;
  final Color? leftAccent;

  /// Applies a real backdrop blur. Reserved for floating chrome: a blur layer
  /// per row in a long list is expensive, and over a flat gradient ground the
  /// translucent fill alone is visually near-identical.
  final bool blur;

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      decoration: BF.card(
        background: background,
        radius: radius,
        border: border,
      ),
      padding: padding,
      child: child,
    );

    if (blur) {
      body = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: BF.blurSigma, sigmaY: BF.blurSigma),
          child: body,
        ),
      );
    }

    if (leftAccent == null) return body;

    // `border-left: 3px solid <accent>` — drawn over the hairline border and
    // clipped to the card's radius.
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Stack(
        children: [
          body,
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 3,
            child: ColoredBox(color: leftAccent!),
          ),
        ],
      ),
    );
  }
}

/// Rounded square holding a person's initials, tinted from the avatar palette.
class Avatar extends StatelessWidget {
  const Avatar({
    super.key,
    required this.initials,
    required this.color,
    this.size = 42,
    this.radius = 12,
    this.fontSize = 14,
  });

  final String initials;
  final Color color;
  final double size;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Text(initials, style: BF.sans(fontSize, 700, color: BF.ink)),
  );
}

/// The stacked `012 / QUEUE` chip on customer rows.
class QueueBadge extends StatelessWidget {
  const QueueBadge({
    super.key,
    required this.no,
    required this.background,
    required this.foreground,
    this.size = 46,
    this.showCaption = true,
    this.fontSize = 15,
  });

  final String no;
  final Color background;
  final Color foreground;
  final double size;
  final bool showCaption;
  final double fontSize;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Queue number $no',
    child: ExcludeSemantics(child: _badge()),
  );

  Widget _badge() => Container(
    // minWidth/minHeight rather than a fixed box: at large accessibility
    // text sizes the number and caption need more room, and the row this
    // sits in is content-sized, so growing is harmless.
    constraints: BoxConstraints(minWidth: size, minHeight: size),
    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
    decoration: BoxDecoration(
      color: background,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(no, style: BF.sans(fontSize, 800, color: foreground, height: 1)),
        if (showCaption) ...[
          const SizedBox(height: 2),
          Text(
            'QUEUE',
            style: BF.sans(
              7.5,
              700,
              color: foreground.withValues(alpha: .65),
              height: 1,
              letterSpacing: .75,
            ),
          ),
        ],
      ],
    ),
  );
}

/// Filled pill button — the primary action across the app.
class BFButton extends StatelessWidget {
  const BFButton({
    super.key,
    required this.label,
    required this.onTap,
    this.background,
    this.foreground = BF.white,
    this.minHeight = 54,
    this.radius = 14,
    this.fontSize = 15,
    this.border,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onTap;

  /// Null paints DSE's accent gradient with a matching glow — the primary
  /// call to action. Pass a colour for secondary and destructive buttons.
  final Color? background;
  final Color foreground;
  final double minHeight;
  final double radius;
  final double fontSize;
  final Color? border;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final primary = background == null;

    // Material asserts that `shape` and `borderRadius` are never both set, so
    // the radius rides on the shape alone. Passing both looked fine in the
    // release web build only because assertions are stripped there.
    final button = Semantics(
      button: true,
      enabled: onTap != null,
      label: label,
      child: ExcludeSemantics(
        child: Material(
          color: primary ? Colors.transparent : background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius),
            side: border == null ? BorderSide.none : BorderSide(color: border!),
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(radius),
            child: Container(
              width: expand ? double.infinity : null,
              constraints: BoxConstraints(minHeight: minHeight),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: BF.sans(fontSize, 700, color: foreground),
              ),
            ),
          ),
        ),
      ),
    );

    if (!primary) return button;

    // The gradient and its glow sit behind the Material so the ink ripple
    // still lands on top of them.
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: BF.accentGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: onTap == null ? null : BF.glow(BF.acc),
      ),
      child: button,
    );
  }
}

/// Text field styled like the design's `#FCFAF6` inputs.
class BFField extends StatelessWidget {
  const BFField({
    super.key,
    required this.value,
    required this.onChanged,
    required this.hint,
    this.label,
    this.minHeight = 48,
    this.radius = 12,
    this.keyboardType,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final String? label;
  final double minHeight;
  final double radius;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    final field = _ControlledField(
      value: value,
      onChanged: onChanged,
      hint: hint,
      minHeight: minHeight,
      radius: radius,
      keyboardType: keyboardType,
    );
    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: BF.sans(12, 600, color: BF.inkA(.55))),
        const SizedBox(height: 6),
        field,
      ],
    );
  }
}

class _ControlledField extends StatefulWidget {
  const _ControlledField({
    required this.value,
    required this.onChanged,
    required this.hint,
    required this.minHeight,
    required this.radius,
    this.keyboardType,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String hint;
  final double minHeight;
  final double radius;
  final TextInputType? keyboardType;

  @override
  State<_ControlledField> createState() => _ControlledFieldState();
}

class _ControlledFieldState extends State<_ControlledField> {
  late final TextEditingController _c = TextEditingController(
    text: widget.value,
  );
  late final FocusNode _focus = FocusNode()..addListener(() => setState(() {}));

  @override
  void didUpdateWidget(covariant _ControlledField old) {
    super.didUpdateWidget(old);
    // The store owns the value; resync only when it diverges (e.g. the
    // check-in form clearing itself after submit).
    if (widget.value != _c.text) _c.text = widget.value;
  }

  @override
  void dispose() {
    _c.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final focused = _focus.hasFocus;
    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        color: focused ? BF.whiteA(.09) : BF.field,
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: focused ? BF.acc : BF.inkA(.16)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: _c,
        focusNode: _focus,
        onChanged: widget.onChanged,
        keyboardType: widget.keyboardType,
        cursorColor: BF.acc,
        style: BF.sans(15.5, 500, color: BF.ink),
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
          hintText: widget.hint,
          hintStyle: BF.sans(15.5, 500, color: BF.inkA(.35)),
        ),
      ),
    );
  }
}

/// Dashed-border empty state ("Nobody waiting", "Queue is empty").
class EmptyNote extends StatelessWidget {
  const EmptyNote(this.text, {super.key, this.padding = 22});

  final String text;
  final double padding;

  @override
  Widget build(BuildContext context) => DottedBorder(
    radius: 14,
    color: BF.inkA(.18),
    child: Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: BF.sans(13.5, 500, color: BF.inkA(.45)),
      ),
    ),
  );
}

/// Minimal dashed-rectangle painter — used for the two dashed containers in
/// the design without pulling in a package for it.
class DottedBorder extends StatelessWidget {
  const DottedBorder({
    super.key,
    required this.child,
    required this.color,
    this.radius = 14,
    this.dash = 5,
    this.gap = 4,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  Widget build(BuildContext context) => CustomPaint(
    // foregroundPainter, not painter: the dashes must land on top of an
    // opaque child (the "Register a braider" button fills its own bounds).
    foregroundPainter: _DashPainter(
      color: color,
      radius: radius,
      dash: dash,
      gap: gap,
    ),
    child: child,
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter({
    required this.color,
    required this.radius,
    required this.dash,
    required this.gap,
  });

  final Color color;
  final double radius;
  final double dash;
  final double gap;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(radius),
    );
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        final end = (d + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(d, end), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashPainter old) =>
      old.color != color || old.radius != radius;
}

/// Thin rounded progress bar (elapsed vs. the style's average duration).
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    required this.color,
    this.background,
    this.height = 4,
  });

  /// 0..1
  final double value;
  final Color color;
  final Color? background;
  final double height;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(99),
    child: Container(
      height: height,
      color: background ?? BF.inkA(.08),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: value.clamp(0.0, 1.0),
        child: Container(color: color),
      ),
    ),
  );
}

/// Wraps a card in an ink ripple without altering its painted decoration.
class Tappable extends StatelessWidget {
  const Tappable({
    super.key,
    required this.child,
    required this.onTap,
    this.radius = 14,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double radius;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(radius),
      child: child,
    ),
  );
}
