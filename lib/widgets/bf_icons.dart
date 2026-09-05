import 'package:flutter/material.dart';

/// Hand-drawn icon set for Braidflow's navigation.
///
/// The design canvas shipped a placeholder square for every tab, so there was
/// nothing to copy. These are drawn to match the rest of the app's line
/// language: a 24-unit grid, 2-unit round-capped strokes, and corner radii in
/// the same family as the cards — so they sit next to Instrument Serif without
/// the weight of a stock Material glyph.
///
/// Everything is stroked in view-box units and scaled as a whole, so an icon
/// stays proportionate at any size.
enum BFIconType {
  /// Waiting list — rows with a leading marker each.
  queue,

  /// Walk-in check-in — a person being added.
  checkIn,

  /// Braider chairs — the 2×2 grid the screen itself uses.
  chairs,

  /// Roster — two people.
  staff,

  /// The braider's own seat.
  myChair,

  /// Who's next — time waiting.
  upNext,

  /// The braider herself.
  me,

  /// The owner's day.
  today,

  /// Navigate back.
  chevronLeft,

  /// Drill into a row.
  chevronRight,
}

class BFIcon extends StatelessWidget {
  const BFIcon(
    this.type, {
    super.key,
    required this.color,
    this.size = 22,
    this.strokeWidth = 2,
  });

  final BFIconType type;
  final Color color;
  final double size;

  /// In view-box units (out of 24), so it scales with [size].
  final double strokeWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: CustomPaint(
      painter: _BFIconPainter(
        type: type,
        color: color,
        strokeWidth: strokeWidth,
      ),
    ),
  );
}

class _BFIconPainter extends CustomPainter {
  _BFIconPainter({
    required this.type,
    required this.color,
    required this.strokeWidth,
  });

  final BFIconType type;
  final Color color;
  final double strokeWidth;

  /// All geometry below is authored against a 24×24 grid.
  static const double _viewBox = 24;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / _viewBox);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color
      ..isAntiAlias = true;

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = color
      ..isAntiAlias = true;

    switch (type) {
      case BFIconType.queue:
        _queue(canvas, stroke, fill);
      case BFIconType.checkIn:
        _checkIn(canvas, stroke);
      case BFIconType.chairs:
        _chairs(canvas, stroke);
      case BFIconType.staff:
        _staff(canvas, stroke);
      case BFIconType.myChair:
        _myChair(canvas, stroke);
      case BFIconType.upNext:
        _upNext(canvas, stroke);
      case BFIconType.me:
        _me(canvas, stroke);
      case BFIconType.today:
        _today(canvas, stroke, fill);
      case BFIconType.chevronLeft:
        _chevron(canvas, stroke, pointsLeft: true);
      case BFIconType.chevronRight:
        _chevron(canvas, stroke, pointsLeft: false);
    }

    canvas.restore();
  }

  /// Three rows, each with a filled marker — the waiting list.
  void _queue(Canvas canvas, Paint stroke, Paint fill) {
    for (final y in const [6.0, 12.0, 18.0]) {
      canvas.drawCircle(Offset(4.4, y), 1.5, fill);
      canvas.drawLine(Offset(9.4, y), Offset(20.0, y), stroke);
    }
  }

  /// A person plus a `+` — adding a walk-in to the queue.
  void _checkIn(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(9.2, 8.4), 3.4, stroke);
    canvas.drawPath(
      _torso(cx: 9.2, halfWidth: 6.0, top: 14.4, bottom: 20.5),
      stroke,
    );
    canvas.drawLine(const Offset(18.8, 4.4), const Offset(18.8, 10.4), stroke);
    canvas.drawLine(const Offset(15.8, 7.4), const Offset(21.8, 7.4), stroke);
  }

  /// The 2×2 card grid the Chairs screen lays out.
  void _chairs(Canvas canvas, Paint stroke) {
    const positions = [
      Offset(3.4, 3.4),
      Offset(13.2, 3.4),
      Offset(3.4, 13.2),
      Offset(13.2, 13.2),
    ];
    for (final p in positions) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.dx, p.dy, 7.4, 7.4),
          const Radius.circular(2.2),
        ),
        stroke,
      );
    }
  }

  /// Two people, the second set back and slightly smaller.
  void _staff(Canvas canvas, Paint stroke) {
    // Behind, right.
    canvas.drawCircle(const Offset(17.6, 9.0), 2.4, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(16.6, 15.0)
        ..cubicTo(19.4, 15.3, 21.6, 17.4, 21.6, 20.4),
      stroke,
    );
    // In front, left.
    canvas.drawCircle(const Offset(8.1, 8.2), 3.2, stroke);
    canvas.drawPath(
      _torso(cx: 8.1, halfWidth: 5.7, top: 14.2, bottom: 20.4),
      stroke,
    );
  }

  /// A front-facing armchair.
  void _myChair(Canvas canvas, Paint stroke) {
    // Backrest.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(6.0, 3.2, 12.0, 9.4),
        const Radius.circular(3.0),
      ),
      stroke,
    );
    // Seat and arms.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3.4, 11.4, 17.2, 5.8),
        const Radius.circular(2.4),
      ),
      stroke,
    );
    // Legs.
    canvas.drawLine(const Offset(6.6, 17.2), const Offset(6.6, 20.6), stroke);
    canvas.drawLine(const Offset(17.4, 17.2), const Offset(17.4, 20.6), stroke);
  }

  /// A clock — the queue is measured in waiting time.
  void _upNext(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(12, 12), 8.6, stroke);
    canvas.drawPath(
      Path()
        ..moveTo(12, 6.8)
        ..lineTo(12, 12.4)
        ..lineTo(16.0, 14.6),
      stroke,
    );
  }

  /// A single person, centred.
  void _me(Canvas canvas, Paint stroke) {
    canvas.drawCircle(const Offset(12, 8.0), 3.7, stroke);
    canvas.drawPath(
      _torso(cx: 12, halfWidth: 7.6, top: 13.6, bottom: 20.6),
      stroke,
    );
  }

  /// A calendar with today marked.
  void _today(Canvas canvas, Paint stroke, Paint fill) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(3.4, 5.0, 17.2, 15.6),
        const Radius.circular(2.6),
      ),
      stroke,
    );
    canvas.drawLine(const Offset(3.4, 9.8), const Offset(20.6, 9.8), stroke);
    canvas.drawLine(const Offset(8.2, 3.0), const Offset(8.2, 6.6), stroke);
    canvas.drawLine(const Offset(15.8, 3.0), const Offset(15.8, 6.6), stroke);
    canvas.drawCircle(const Offset(12, 15.4), 1.9, fill);
  }

  /// Replaces the ‹ / › text glyphs the design used, so the arrows match the
  /// stroke weight and cap style of everything else here.
  void _chevron(Canvas canvas, Paint stroke, {required bool pointsLeft}) {
    final tip = pointsLeft ? 8.5 : 15.5;
    final tail = pointsLeft ? 15.0 : 9.0;
    canvas.drawPath(
      Path()
        ..moveTo(tail, 4.5)
        ..lineTo(tip, 12)
        ..lineTo(tail, 19.5),
      stroke,
    );
  }

  /// Shared shoulder curve so every figure in the set has the same build.
  Path _torso({
    required double cx,
    required double halfWidth,
    required double top,
    required double bottom,
  }) {
    final lift = (bottom - top) * 0.62;
    return Path()
      ..moveTo(cx - halfWidth, bottom)
      ..cubicTo(
        cx - halfWidth,
        bottom - lift,
        cx - halfWidth * 0.56,
        top,
        cx,
        top,
      )
      ..cubicTo(
        cx + halfWidth * 0.56,
        top,
        cx + halfWidth,
        bottom - lift,
        cx + halfWidth,
        bottom,
      );
  }

  @override
  bool shouldRepaint(covariant _BFIconPainter old) =>
      old.type != type || old.color != color || old.strokeWidth != strokeWidth;
}
