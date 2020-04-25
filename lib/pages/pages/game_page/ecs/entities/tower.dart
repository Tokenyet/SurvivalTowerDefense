import 'dart:math' as Math;
import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/event_manager.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart' as ANIM;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/name_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/towers/basic_tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/towers/home_tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/game.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';

import 'entity_creator.dart';

enum TowerType {
  HomeTower,
  AttackTower,
}

enum TowerUpgradeActionType {
  PowerUpgrade,
  StrengthUpgrade,
  ShieldUpgrade,
  HeatlhUpgrade,
  TowerUpgrade,
}

class TowerConstructAction {
  final TowerType type;
  final Entity terrain;
  TowerConstructAction({
    this.type,
    this.terrain,
  });
}

class TowerUpgradeAction {
  final TowerType type;
  final TowerUpgradeActionType upgradeType;
  final Entity tower;
  final void Function() customUpgrade;

  TowerUpgradeAction({
    this.type,
    this.upgradeType,
    this.tower,
    this.customUpgrade,
  });
}

class Tower {
  static Tower _tower;
  static init(Box2D box2d, EntityManager manager) {
    _tower = Tower(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  Tower(this.box2d, this.manager);

  static Tower getInstance() {
    return _tower;
  }

  Entity createByTowerType(Entity terrainEntity, TowerType type) {
    if(type == TowerType.AttackTower) {
      return createBaseFingerPrintTower(terrainEntity);
    }
    if(type == TowerType.HomeTower) {
      return createHomeTower(terrainEntity);
    }
    return null;
  }

  // ALWAYS create object in worldPos
  Entity createBaseFingerPrintTower(Entity terrainEntity) {
    print("ce: ${terrainEntity.get<PropertyComp>().x}, ${terrainEntity.get<PropertyComp>().y}");
    Entity e = BasicTower().createEntity(manager, box2d, ObjectParams(
      position: Vector2D.fromVector2(
        box2d.viewport.getScreenToWorld(
          Vector2D(terrainEntity.get<PropertyComp>().x, terrainEntity.get<PropertyComp>().y).toVector2()
        )
      ).toPosition()
    ));
    e + TowerComp(terrainEntity) + NameComp("3D");
    _ocupyTerrain(terrainEntity, e);
    return e;
  }


  Entity createHomeTower(Entity terrainEntity) {
    print("ce: ${terrainEntity.get<PropertyComp>().x}, ${terrainEntity.get<PropertyComp>().y}");
    Entity e = HomeTower().createEntity(manager, box2d, ObjectParams(
      position: Vector2D.fromVector2(
        box2d.viewport.getScreenToWorld(
          Vector2D(terrainEntity.get<PropertyComp>().x, terrainEntity.get<PropertyComp>().y).toVector2()
        )
      ).toPosition()
    ));
    e + TowerComp(terrainEntity) + NameComp("HomeTower");
    // e.addObserver(HomeTowerSpecialObserver());
    _ocupyTerrain(terrainEntity, e);
    return e;
  }

  void _ocupyTerrain(Entity terrainEntity, Entity towerEntity) {
    terrainEntity.get<AnimatableComp>().info.setAnimationByKey(TerrainState.PLANTED.toString());
    terrainEntity + terrainEntity.get<TerrainComp>().copyWith(ocupiedEntity: towerEntity);
  }
}

// class HomeTowerSpecialObserver extends EntityObserver {
//   @override
//   destroyed(Entity e) {
//     EventManager.getInstance().systemEventManager.unregisterHomeBaseEvent(e);
//   }

//   @override
//   exchanged(Entity e, Component oldC, Component newC) {
//   }
// }