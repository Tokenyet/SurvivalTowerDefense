import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/enermies/basic_enemy.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrains/basic_terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

enum EnemyType {
  basicEnemy,
}

class Enemy {
  static Enemy _enemy;
  static init(Box2D box2d, EntityManager manager) {
    _enemy = Enemy(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  Enemy(this.box2d, this.manager);

  static Enemy getInstance() {
    return _enemy;
  }


  Entity createBasicEnemy(ObjectParams params) {
    return BasicEnemy().createEntity(manager, box2d, params);
  }
}