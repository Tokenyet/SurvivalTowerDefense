import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';

class VectorSpace {

  static Vector2D getMousePositionToWorldPosition(double mosX, double mosY, Box2D box2d) {
    return Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(mosX, mosY).toVector2()));
  }
  
}