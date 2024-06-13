
import 'dart:math';

import 'package:flutter/material.dart';
import '../../../domain/entities/point.dart';


class CustomCircle extends StatelessWidget {
  final List<String> letters;
  final List<int> pressedLettersIndex;
  final Map<int, Point> lettersPoint;

  const CustomCircle({required this.letters, required this.pressedLettersIndex, required this.lettersPoint});

  @override
  Widget build(BuildContext context) {

    return CustomPaint(
      size: Size.infinite,

      painter: CirclePainter(letters: letters, pressedLettersIndex: pressedLettersIndex, lettersPoint: lettersPoint),
    );
  }
}

class CirclePainter extends CustomPainter {
  final List<String> letters;
  final List<int> pressedLettersIndex;
  final Map<int, Point> lettersPoint;


  CirclePainter({required this.letters, required this.pressedLettersIndex, required this.lettersPoint});

  @override
  void paint(Canvas canvas, Size size) {

    double radius = min(size.width / 2, size.height / 2);
    Offset center = Offset(size.width / 2, size.height - radius);

    double angleStep = 2 * pi / letters.length;
    double angle = -pi / 2;

    const TextStyle textStyle = TextStyle(color: Colors.black, fontSize: 20);
    int i = 0;
    for (String letter in letters) {

      double x = center.dx + radius * 0.8 * cos(angle);
      double y = center.dy + radius * 0.8 * sin(angle);

      lettersPoint[i] = Point(x: x, y: y);

      if (pressedLettersIndex.contains(i)) {
        final Paint letterCirclePaint = Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.fill;

        canvas.drawCircle(Offset(x, y), 25, letterCirclePaint);
      }

      TextSpan span = TextSpan(style: textStyle, text: letter);
      TextPainter textPainter = TextPainter(text: span, textDirection: TextDirection.ltr);
      textPainter.layout();

      textPainter.paint(canvas, Offset(x - textPainter.width / 2, y - textPainter.height / 2));

      angle += angleStep;
      i++;
    }

  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
