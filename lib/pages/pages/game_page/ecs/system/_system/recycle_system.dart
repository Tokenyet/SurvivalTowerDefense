
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/removable_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';

class RecycleSystem extends CleanupSystem {
  Box2D box2d;
  EntityManager em;
  RecycleSystem(Box2D box2d, EntityManager em) {
    this.box2d = box2d;
    this.em = em;
  }

  @override
  cleanup() {
    Group removableGroup = em.group(all: [RemovableComp]);
    for(Entity e in removableGroup.entities) {
      RemovableComp removableComp = e.get<RemovableComp>();
      // immediately delete entity
      if(removableComp.delayMillis == null) {
        removeEntity(e, removableComp);
        continue;
      } 

      // delay delete entity
      DateTime removableTimpestamp = removableComp.timestamp.add(Duration(milliseconds: removableComp.delayMillis.toInt()));
      if(!DateTime.now().difference(removableTimpestamp).isNegative) removeEntity(e, removableComp);
    }
  }

  
  void removeEntity(Entity e, RemovableComp comp) {
    // remove box2d body
    if(e.has(CollisionComp)) box2d.world.destroyBody(e.get<CollisionComp>().body);
    if(e.has(TowerComp) && !comp.isKeepTerrain) {
      Entity terrainEntity = e.get<TowerComp>().terrainEntity;
      AnimatableComp animatableComp = terrainEntity.get<AnimatableComp>();
      animatableComp.info.setAnimationByKey(
        TerrainState.UNPLANTED.toString()
      );
      TerrainComp terrainComp = terrainEntity.get<TerrainComp>();
      terrainEntity + terrainComp.copyWith(ocupiedEntity: null);
    }
    // remove entity
    e.destroy();
  }
}