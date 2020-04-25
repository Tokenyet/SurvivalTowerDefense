import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/damagers/basic_damager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

class Damager {
  static Damager _damager;
  static init(Box2D box2d, EntityManager manager) {
    _damager = Damager(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  Damager(this.box2d, this.manager);

  static Damager getInstance() {
    return _damager;
  }


  Entity createBasicDamager(ObjectParams params, Entity entity, Entity target) {
    return BasicDamager().createEntity(manager, box2d, params, entity, target);
  }
}