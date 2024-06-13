import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/entities/line_points.dart';
import '../game_screen/game_screen_view_model.dart';



class LinePainterWidget extends StatelessWidget {
  const LinePainterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameScreenViewModel>();
    return CustomPaint(
        size: Size.infinite,
        painter: LinePainter(start: model.startPoint, end: model.endPoint, points: model.linesPoint)
    );
  }
}


class LinePainter extends CustomPainter {
  final Offset? start;
  final Offset? end;
  final List<LinePoints> points;

  LinePainter({required this.start, required this.end, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 5;

    if (start != null && end != null) {

      for (LinePoints linePoints in points){
        canvas.drawLine(Offset(linePoints.startX, linePoints.startY), Offset(linePoints.endX, linePoints.endY), paint);
      }

      canvas.drawLine(start!, end!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}