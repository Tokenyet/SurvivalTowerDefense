import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/attack_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/enemy_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/health_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/movement_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/hurter_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/box2d_filter.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/enermies/fsm/basic_enemy_fsm.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/cooldown.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' hide State;
import 'package:state_machine/state_machine.dart';

import '../entity_creator.dart';

///
/// Requirement Components
/// - CollisionComp
/// - 
/// - 
///
class EnemyAiAttackCore extends AiCore {
  final Entity _self;
  final Box2D _box2d;
  final BasicEnemyFSM fsm;

  final Cooldown attackCooldown;
  EnemyAiAttackCore(
    Entity self,
    Box2D box2d,
    {
      double attackCooldown = 500
    }
  ) :
    _self = self,
    _box2d = box2d,
    fsm = BasicEnemyFSM(),
    attackCooldown = Cooldown(millis: attackCooldown);

  Entity _nearest;

  bool _isOnTarget = false;

  @override
  void onCollision(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = true;
    print("enemey on collision");
    if(target == _nearest) fsm.onTarget();
  }

  @override
  void onCollisionLeave(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = false;
    if(target == _nearest && fsm.isAttack()) fsm.goToNearestTarget();
  }

  @override
  void onTap(Entity self, double x, double y) {
  }

  @override
  void update(double delta) {
    _self.remove<MovementComp>();
    _self.get<CollisionComp>().body.linearVelocity = Vector2D.zero.toVector2();
    if(_self.get<HealthComp>().health.currentHp == 0 && (fsm.isAttack() || fsm.isWalk())) fsm.exhaustHp();
    if(fsm.isWalk()) {
      if(_nearest == null || !_nearest.isAlive) _nearest = _box2d.getNearestTowerEntity(Vector2D.fromVector2(this._self.get<CollisionComp>().body.position));
      if(_isOnTarget) return;
      if(_nearest == null) return;

      CollisionComp selfCollisionComp = _self.get<CollisionComp>();
      CollisionComp targetComp = _nearest.get<CollisionComp>();

      Vector2D v = Vector2D(
        targetComp.body.position.x - selfCollisionComp.body.position.x,
        targetComp.body.position.y - selfCollisionComp.body.position.y
      );
      _self + MovementComp(velocity: v.limitVector(500 * delta));
    } else if(fsm.isAttack()) {
      // print("Attack!!");
      attackCooldown.execute((){
        SystemEntity.getInstance().createHurter(HurtInfo(
          attacker: _self,
          target: _nearest,
        ));
        // int damage = _self.get<AttackComp>().attack.power;
        // _nearest.get<HealthComp>().health.hurt(damage);
      });
    } else if(fsm.isDying()) {
      fsm.dying();
    } else if(fsm.isDead() && _self.isAlive) {
      _box2d.world.destroyBody(_self.get<CollisionComp>().body);
      _self.destroy();
    }
  }

  @override
  void onTapUp(Entity self, double x, double y) {
    // TODO: implement onTapUp
  }
}

class BasicEnemy extends EntityCreator {
  @override
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params) {
    Entity e = manager.createEntity();
    AnimatableComp animatableComp = AnimatableComp(
      AnimationInfo(
        sprites: {
          TerrainState.UNPLANTED.toString(): StaticSpriteAnimation(
            Sprite("terrain_basic.png")..paint = Paint()
            ..paint.colorFilter = ColorFilter.mode(Colors.yellow, BlendMode.srcATop)
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
      )
    );
    animatableComp.info.setAnimationByKey(TerrainState.UNPLANTED.toString());
    
    const scale = 0.2;
    const TILE_WIDTH = 44.0 / 4.0 * scale;
    final B2D.PolygonShape shape = B2D.PolygonShape();
    shape.set(
      [
        B2D.Vector2(0, TILE_WIDTH),
        B2D.Vector2(TILE_WIDTH, 15.0 / 4.0 * scale),
        B2D.Vector2(TILE_WIDTH, -15.0 / 4.0 * scale),
        B2D.Vector2(0, -TILE_WIDTH),
        B2D.Vector2(-TILE_WIDTH, -15.0 / 4.0 * scale),
        B2D.Vector2(-TILE_WIDTH, 15.0 / 4.0 * scale),
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
    // fixtureDef.filter = Bodx2dFilterBits.bits(FilterType.Enemy);
    // fixtureDef.isSensor = true;
    fixtureDef.setUserData(e);

    final bodyDef = B2D.BodyDef();
    // bodyDef.position = B2D.Vector2(params.position.x, params.position.y);
    // B2D.Vector2 worldPos = box2d.viewport.getScreenToWorld(B2D.Vector2(params.position.x, params.position.y));
    bodyDef.position = B2D.Vector2(params.position.x, params.position.y);
    bodyDef.angularVelocity = 4.0;
    bodyDef.type = B2D.BodyType.DYNAMIC;
    bodyDef.setUserData(e);

    B2D.Body body = box2d.world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);
    CollisionComp collisionComp = CollisionComp(
      body
    );
    
    B2D.Vector2 position = box2d.viewport.getWorldToScreen(B2D.Vector2(bodyDef.position.x, bodyDef.position.y));
    print("create enemy: ${position.x} ${position.y}");
    PropertyComp propertyComp = PropertyComp(
      height: 90 * scale,
      width: 90 * scale,
      x: position.x,
      y: position.y,
    );

    HealthComp healthComp = HealthComp();
    AttackComp attackComp = AttackComp(
      power: 10
    );

    e + animatableComp + collisionComp + propertyComp + EnemyComp() + healthComp + attackComp + AiComp(
      EnemyAiAttackCore(e, box2d)
    );
    return e;
  }
}


