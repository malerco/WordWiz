
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../domain/entities/point.dart';


class WhiteCircle extends StatelessWidget {

  const WhiteCircle();

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      size: Size.infinite,

      painter: CirclePainter(),
    );
  }
}

class CirclePainter extends CustomPainter {

  CirclePainter();

  @override
  void paint(Canvas canvas, Size size) {

    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    double radius = min(size.width / 2, size.height / 2);
    Offset center = Offset(size.width / 2, size.height - radius);

    canvas.drawCircle(center, radius, paint);

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
