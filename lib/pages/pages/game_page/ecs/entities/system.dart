import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/hurter_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

class SystemEntity {
  static SystemEntity _system;
  static init(Box2D box2d, EntityManager manager) {
    _system = SystemEntity(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  SystemEntity(this.box2d, this.manager);

  static SystemEntity getInstance() {
    return _system;
  }


  Entity createHurter(HurtInfo hurtInfo) {
    return manager.createEntity() + HurterComp(hurtInfo: hurtInfo);
  }
}