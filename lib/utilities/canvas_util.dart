import 'dart:math' as Math;

import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:flutter/cupertino.dart';

class CanvasUtil {
  static Path polygon(List<Offset> points, {double rounded = 0}) {
    assert(points.length > 2);
    assert(rounded >= 0);
    Path path = Path();

    // Regular polygon
    if(rounded == 0) {
      path.moveTo(points[0].dx, points[0].dy);
      for(int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      return path;
    }

    // Rounded polygon
    for(int i = 0; i < points.length; i++) {
      Vector2D p1 = Vector2D.fromOffset(points[i]);
      Vector2D p2 = Vector2D.fromOffset(points[i + 1]);
      Vector2D p3 = Vector2D.fromOffset(points[(i + 2) % points.length]);
      Vector2D p4 = Vector2D.fromOffset(points[(i + 3) % points.length]);
      double maxRounded = (p2 - p1).length / 2;
      double finalRounded = Math.min(rounded, maxRounded);
      Vector2D unitVector = (p2 - p1).limitVector(1);
      Vector2D spanVector = unitVector * finalRounded;
      double maxRounded2 = (p4 - p3).length / 2;
      double finalRounded2 = Math.min(rounded, maxRounded2);
      Vector2D unitVector2 = (p4 - p3).limitVector(1);
      Vector2D spanVector2 = unitVector2 * finalRounded2;

      Vector2D reP1 = p1 + (spanVector * maxRounded);
      Vector2D reP2 = p2 - (spanVector * maxRounded);
      Vector2D reP3 = p3 + (spanVector2 * maxRounded2);

      if(i == 0) {
        path.moveTo(reP1.x, reP1.y);
      } else {
        path.lineTo(reP1.x, reP1.y);
      }
      path.lineTo(reP2.x, reP2.y);
      path.arcToPoint(Offset(reP3.x, reP3.y), radius: Radius.circular(finalRounded));
    }

    return path;
  }
}