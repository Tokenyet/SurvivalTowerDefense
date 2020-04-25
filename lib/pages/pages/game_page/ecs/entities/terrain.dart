import 'package:DarkSurviver/pages/pages/game_page/ecs/component/name_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrains/basic_terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

class Terrain {
  static Terrain _tower;
  static init(Box2D box2d, EntityManager manager) {
    _tower = Terrain(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  Terrain(this.box2d, this.manager);

  static Terrain getInstance() {
    return _tower;
  }


  Entity createBasicTerrain(ObjectParams params) {
    Entity terrainEntity = BasicTerrain().createEntity(manager, box2d, params);
    return terrainEntity + NameComp("Terrain");
  }
}