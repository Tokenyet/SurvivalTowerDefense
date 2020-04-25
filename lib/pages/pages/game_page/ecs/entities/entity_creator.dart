import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/position.dart';
import 'package:flutter/cupertino.dart';

class ObjectParams {
  final Position position;
  ObjectParams({
    this.position
  });

  factory ObjectParams.alignment({
    Entity entity,
    Alignment alignment = Alignment.center
  }) {
    assert(entity.has(PropertyComp), "ObjectParams.alignment need property comp");
    PropertyComp propertyComp = entity.get<PropertyComp>();
    double x = propertyComp.x;
    double y = propertyComp.y;
    double xAlignment = propertyComp.width / 2;
    double yAlignment = propertyComp.height / 2;
    Vector2D vec = Vector2D(x - xAlignment, y + yAlignment); // center
    if(alignment == Alignment.center) { vec = Vector2D(x - xAlignment, y + yAlignment); }
    else if(alignment == Alignment.topLeft) { vec = Vector2D(x - xAlignment, y - yAlignment); }
    else if(alignment == Alignment.topCenter) { vec = Vector2D(x, y - yAlignment); }
    else if(alignment == Alignment.topRight) { vec = Vector2D(x + xAlignment, y - yAlignment); }
    else if(alignment == Alignment.centerLeft) { vec = Vector2D(x - xAlignment, y); }
    else if(alignment == Alignment.centerRight) { vec = Vector2D(x + xAlignment, y); }
    else if(alignment == Alignment.bottomLeft) { vec = Vector2D(x - xAlignment, y + yAlignment); }
    else if(alignment == Alignment.bottomCenter) { vec = Vector2D(x, y + yAlignment); }
    else if(alignment == Alignment.bottomRight) { vec = Vector2D(x + xAlignment, y + yAlignment); }
    return ObjectParams(position: vec.toPosition());
  }
}

abstract class EntityCreator {
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params);
}

abstract class DamangerCreator {
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params, Entity self, Entity target);
}