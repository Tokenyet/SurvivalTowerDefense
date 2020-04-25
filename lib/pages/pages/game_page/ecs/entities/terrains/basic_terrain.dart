import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/event_manager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../entity_creator.dart';
import '../terrain.dart';

class BasicTerrain extends EntityCreator {
  @override
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params) {
    Entity e = manager.createEntity();
    AnimatableComp animatableComp = AnimatableComp(
      AnimationInfo(
        sprites: {
          TerrainState.UNPLANTED.toString(): StaticSpriteAnimation(
            Sprite("terrain_basic.png")
          ),
          TerrainState.UNPLANTED_SELECT.toString(): StaticSpriteAnimation(
            Sprite("terrain_basic.png")..paint = Paint()
            ..paint.colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop)
          ),
          TerrainState.PLANTED.toString(): StaticSpriteAnimation(
            Sprite("terrain_basic.png")..paint = Paint()
            ..paint.colorFilter = ColorFilter.mode(Colors.redAccent, BlendMode.srcATop)
          ),
          TerrainState.PLANTED_SELECT.toString(): StaticSpriteAnimation(
            Sprite("terrain_basic.png")..paint = Paint()
            ..paint.colorFilter = ColorFilter.mode(Colors.green, BlendMode.srcATop)
          ),
        },
        initAnimationKey: TerrainState.UNPLANTED.toString()
      ),
    );
    const TILE_WIDTH = 44.0 / 4.0;
    final B2D.PolygonShape shape = B2D.PolygonShape();
    shape.set(
      [
        B2D.Vector2(0, TILE_WIDTH),
        B2D.Vector2(TILE_WIDTH, 15.0 / 4.0),
        B2D.Vector2(TILE_WIDTH, -15.0 / 4.0),
        B2D.Vector2(0, -TILE_WIDTH),
        B2D.Vector2(-TILE_WIDTH, -15.0 / 4.0),
        B2D.Vector2(-TILE_WIDTH, 15.0 / 4.0),
      ],
      6
    );

    // print("${params.position.x} ${params.position.y}");
    // print("${box2d.dimensions}");
    // print("${box2d.viewport.scale}");
    // print("${box2d.viewport.center}");

    final fixtureDef = B2D.FixtureDef();
    // To be able to determine object in collision
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.0;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;
    fixtureDef.isSensor = true;
    fixtureDef.setUserData(e);

    final bodyDef = B2D.BodyDef();
    // bodyDef.position = B2D.Vector2(params.position.x, params.position.y);
    B2D.Vector2 worldPos = box2d.viewport.getScreenToWorld(B2D.Vector2(params.position.x, params.position.y));
    bodyDef.position = B2D.Vector2(worldPos.x, worldPos.y);
    bodyDef.angularVelocity = 4.0;
    bodyDef.type = B2D.BodyType.STATIC;

    B2D.Body body = box2d.world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);
    CollisionComp collisionComp = CollisionComp(
      body
    );
    
    B2D.Vector2 position = box2d.viewport.getWorldToScreen(B2D.Vector2(bodyDef.position.x, bodyDef.position.y));
    PropertyComp propertyComp = PropertyComp(
      height: 90,
      width: 90,
      x: position.x,
      y: position.y,
    );

    e + animatableComp + collisionComp + propertyComp + TerrainComp(null) + AiComp(
      AiBasicCore(
        update: (delta) {
        
        },
        onTap: (self, x, y) {
          TerrainComp comp = self.get<TerrainComp>();
          if(comp.ocupiedEntity != null) return;
          if(comp.state == TerrainState.UNPLANTED) {
            // print(e.get<AnimatableComp>().currentAnimation.key);
            // Change to selecting state
            print("SELECT");
            animatableComp.info.setAnimationByKey(
              TerrainState.UNPLANTED_SELECT.toString()
            );

            TerrainComp comp = e.get<TerrainComp>();
            e.remove<TerrainComp>();
            e + comp.copyWith(state: TerrainState.UNPLANTED_SELECT);


            EventManager.getInstance().uiEventManager.createInitTowerMenuEvent(e);

            // Show UI to change state
          //   UiManager.getInstacne().showPlantMenu((PlantCommand command) {
          //     if(command == PlantCommand.SelectTowerA) {
          //       // PLANTED
          //       animatableComp.info.setAnimationByKey(
          //         TerrainState.PLANTED.toString(),
          //       );
          //       TerrainComp comp = e.get<TerrainComp>();
          //       e.remove<TerrainComp>();
          //       e + comp.copyWith(state: TerrainState.PLANTED);
          //     } else {
          //       // UNPLANTED
          //       animatableComp.info.setAnimationByKey(
          //         TerrainState.UNPLANTED.toString()
          //       );
          //       TerrainComp comp = e.get<TerrainComp>();
          //       e.remove<TerrainComp>();
          //       e + comp.copyWith(state: TerrainState.UNPLANTED);
          //     }
          //   }, e);
          }
        } 
      )
    );
    return e;
  }
}


