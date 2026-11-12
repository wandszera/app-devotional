import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Cruz latina minimalista desenhada em traço fino.
class CrossMark extends StatelessWidget {
  const CrossMark({this.size = 28, this.color = AppColors.gold, super.key});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.62, size),
      painter: _CrossPainter(color),
    );
  }
}

class _CrossPainter extends CustomPainter {
  _CrossPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;
    final cx = size.width / 2;
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), paint);
    canvas.drawLine(
      Offset(0, size.height * 0.32),
      Offset(size.width, size.height * 0.32),
      paint,
    );
  }

  @override
  bool shouldRepaint(_CrossPainter old) => old.color != color;
}

/// Divisor ornamental: filete dourado com uma cruz ao centro.
class OrnamentDivider extends StatelessWidget {
  const OrnamentDivider({super.key});

  @override
  Widget build(BuildContext context) {
    const line = Expanded(
      child: Divider(color: AppColors.goldLight, thickness: 1, height: 1),
    );
    return const Row(
      children: [
        line,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: CrossMark(size: 16),
        ),
        line,
      ],
    );
  }
}
