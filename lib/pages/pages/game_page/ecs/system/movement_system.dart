import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/movement_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
// import 'package:DarkSurviver/pages/ecs/component/sprite_comp.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/rendering.dart';
import 'package:box2d_flame/box2d.dart' as B2D;

class MovementSystem extends EntityManagerSystem implements ExecuteSystem {
  final Box2DComponent _box2dComponent;
  MovementSystem(
    Box2D box2d
  ):
    _box2dComponent = box2d;
  int _timestamp;


  @override
  execute() {
    Group collisionGroup = entityManager.group(all: [CollisionComp, MovementComp]);
    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    int difference = time.millisecondsSinceEpoch - _timestamp;
    // int iteration = (time.millisecondsSinceEpoch - _timestamp) ~/ 16;
    // _timestamp += iteration * 16
    // _box2dComponent.update(difference.toDouble() / 1000.0);
    _timestamp = time.millisecondsSinceEpoch;
    for(Entity e in collisionGroup.entities) {
      Vector2D velocity = e.get<MovementComp>().velocity;
      // print(Vector2D.fromVector2(e.get<CollisionComp>().body.position));
      e.get<CollisionComp>().body.linearVelocity = velocity.toVector2();
      // print(velocity);
      // print(velocity.toVector2());
      // print(e.get<CollisionComp>().body.linearVelocity);
    }
  }
}