import 'dart:math';
import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:pigment/pigment.dart';

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  final double color;

  AnimatedWave({this.height, this.speed, this.offset = 0.0, this.color});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        height: height,
        width: constraints.biggest.width,
        child: ControlledAnimation(
            playback: Playback.LOOP,
            duration: Duration(milliseconds: (5000 / speed).round()),
            tween: Tween(begin: 0.0, end: 2 * pi),
            builder: (context, value) {
              return CustomPaint(
                foregroundPainter: CurvePainter(value + offset, color),
              );
            }),
      );
    });
  }
}

class CurvePainter extends CustomPainter {
  final double value;
  final double color;

  CurvePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    var pickedColor;
    if (color == 0) {
      pickedColor = "7BC89B"; //green
    } else {
      pickedColor = "ffe34c"; //yellow
    }

    //final white = Paint()..color = Colors.white.withAlpha(60);
    final white = Paint()..color = Pigment.fromString(pickedColor);
    final path = Path();

    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
