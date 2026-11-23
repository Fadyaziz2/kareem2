import 'package:flutter/material.dart';
import '../../core/theme.dart';

/// Oqoody Brand Logo Widget
/// Renders the luxury Emerald & Gold balance scale emblem with 100% reliability
/// on Flutter Web, Android, and iOS using hardware-accelerated vector canvas painting
/// with instant offline and multi-resolution support.
class OqoodyLogo extends StatelessWidget {
  final double size;
  final double? borderRadius;
  final bool hasGlow;
  final bool hasBorder;

  const OqoodyLogo({
    super.key,
    this.size = 90,
    this.borderRadius,
    this.hasGlow = false,
    this.hasBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = borderRadius ?? (size * 0.26);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: OqoodyTheme.cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: hasBorder
            ? Border.all(
                color: OqoodyTheme.accentGold.withOpacity(0.5),
                width: 1.5,
              )
            : null,
        boxShadow: hasGlow
            ? [
                BoxShadow(
                  color: OqoodyTheme.accentGold.withOpacity(0.25),
                  blurRadius: size * 0.3,
                  spreadRadius: size * 0.02,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 1: Hardware-accelerated custom vector painting (100% guaranteed to show on Web)
            CustomPaint(
              size: Size(size, size),
              painter: _OqoodyScalePainter(
                goldColor: OqoodyTheme.accentGold,
              ),
            ),
            // Layer 2: High-resolution PNG asset overlay if available
            Image.asset(
              'assets/images/oqoody_logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

class _OqoodyScalePainter extends CustomPainter {
  final Color goldColor;

  _OqoodyScalePainter({
    required this.goldColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double s = size.width / 200.0;

    final strokePaint = Paint()
      ..color = goldColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = goldColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    // Central Pillar: (100, 35) to (100, 155)
    canvas.drawLine(Offset(100 * s, 35 * s), Offset(100 * s, 155 * s), strokePaint);

    // Pillar Base: (60, 155) to (140, 155)
    canvas.drawLine(Offset(60 * s, 155 * s), Offset(140 * s, 155 * s), strokePaint);

    // Crossbar: (50, 70) to (150, 70)
    canvas.drawLine(Offset(50 * s, 70 * s), Offset(150 * s, 70 * s), strokePaint);

    // Top Balance Knob / Finial
    canvas.drawCircle(Offset(100 * s, 35 * s), 4.5 * s, Paint()..color = goldColor);

    // Left Pan: M50 70 L35 110 C35 120 65 120 65 110 Z
    final leftPan = Path()
      ..moveTo(50 * s, 70 * s)
      ..lineTo(35 * s, 110 * s)
      ..cubicTo(35 * s, 122 * s, 65 * s, 122 * s, 65 * s, 110 * s)
      ..close();
    canvas.drawPath(leftPan, fillPaint);
    canvas.drawPath(leftPan, strokePaint);

    // Right Pan: M150 70 L135 110 C135 120 165 120 165 110 Z
    final rightPan = Path()
      ..moveTo(150 * s, 70 * s)
      ..lineTo(135 * s, 110 * s)
      ..cubicTo(135 * s, 122 * s, 165 * s, 122 * s, 165 * s, 110 * s)
      ..close();
    canvas.drawPath(rightPan, fillPaint);
    canvas.drawPath(rightPan, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

