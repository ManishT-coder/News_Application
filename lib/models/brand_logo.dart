import 'dart:math' as math;
import 'package:flutter/material.dart';

class AmBrand {
  AmBrand();
  static const navy = Color(0xFF12263F);
  static const sun  = Color(0xFFF9A825);
}

// The sunrise logo drawn with code (no image asset needed)
class SunriseLogo extends StatelessWidget {
  final double size;
  const SunriseLogo({super.key, this.size = 32});

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: SunrisePainter()),
    );
  }
}

class SunrisePainter extends CustomPainter {
  const SunrisePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    // Navy rounded tile background
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(w * 0.22)),
      Paint()..color = AmBrand.navy,
    );

    final center   = Offset(w * 0.5, w * 0.6);
    final sunPaint = Paint()..color = AmBrand.sun;

    // Half sun
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: w * 0.225),
      math.pi, math.pi, true, sunPaint,
    );

    // Sun rays
    final rayPaint = Paint()
      ..color      = AmBrand.sun
      ..strokeWidth = w * 0.035
      ..strokeCap  = StrokeCap.round;
    for (final deg in const [30, 60, 90, 120, 150]) {
      final a   = deg * math.pi / 180;
      final dir = Offset(math.cos(a), -math.sin(a));
      canvas.drawLine(center + dir * (w * 0.31), center + dir * (w * 0.40), rayPaint);
    }

    // Horizon line
    canvas.drawLine(
      Offset(w * 0.17, w * 0.6), Offset(w * 0.83, w * 0.6),
      Paint()..color = Colors.white..strokeWidth = w * 0.02,
    );

    // Two text bars
    void bar(double l, double r, double y, Color c) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(w * l, w * (y - 0.02), w * r, w * (y + 0.02)),
          Radius.circular(w * 0.02),
        ),
        Paint()..color = c,
      );
    }
    bar(0.24, 0.76, 0.77, Colors.white);
    bar(0.24, 0.575, 0.86, const Color(0xFFB4BAC5));
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

// Logo + "AM News" text used in the app bar
class AmNewsWordmark extends StatelessWidget {
  const AmNewsWordmark({super.key});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.titleLarge?.copyWith(
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SunriseLogo(size: 32),
        const SizedBox(width: 10),
        Text.rich(
          TextSpan(style: style, children: [
            TextSpan(
              text: 'AM',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
            const TextSpan(text: ' News'),
          ]),
        ),
      ],
    );
  }
}