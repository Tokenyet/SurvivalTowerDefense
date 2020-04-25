import 'dart:ui';

import 'dart:math' as Math;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart' as AC;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/attack_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/health_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/removable_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/box2d_filter.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/damager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/display.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/towers/fsm/basic_tower_fsm.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/cooldown.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../entity_creator.dart';

class AttackTowerAiCore extends AiCore {
  final Entity _self;
  final Box2D _box2d;
  final BasicTowerFSM fsm;

  // final Cooldown attackCooldown;

  final Cooldown constructCooldown;
  final Cooldown attackCooldown;
  AttackTowerAiCore(
    Entity self,
    Box2D box2d,
  ) :
    _self = self,
    _box2d = box2d,
    fsm = BasicTowerFSM(),
    constructCooldown = Cooldown(millis: 1000, initTime: true),
    attackCooldown = Cooldown(millis: 500);
    // attackCooldown = Cooldown(attackCooldown);

  List<Entity> _nearestEnemies = [];

  // bool _isOnTarget = false;

  @override
  void onCollision(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = true;
    // if(target == _nearest) fsm.onTarget();
    // print('Tower add collision target');
    _nearestEnemies.add(target);
  }

  @override
  void onCollisionLeave(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = false;
    // if(target == _nearest) fsm.goToNearestTarget();
    _nearestEnemies.remove(target);
  }

  @override
  void onTap(Entity self, double x, double y) {
  }

  Cooldown dyingTimer;
  @override
  void update(double delta) {
    if(fsm.isIdle() || fsm.isAttack()) {
      // print("${_self.get<HealthComp>().health.currentHp}");
      if(_self.get<HealthComp>().health.currentHp == 0) {
        fsm.exhaustHp();
      }
    }

    if(fsm.isConstructing()) {
      // print("Tower Consturcting");
      constructCooldown.execute((){
        fsm.buildComplete();
      });
    } else if(fsm.isIdle()) {
      // print("Tower Idle");
      if(_nearestEnemies.isNotEmpty) fsm.findTarget();
      // searchForEnemy
    } else if(fsm.isAttack()) {
      // print("Tower Attack");
      if(_nearestEnemies.isEmpty) {
        fsm.missTarget();
        return;
      }
      attackCooldown.execute((){
        print("tower attack");
        for(Entity e in _nearestEnemies) {
          Damager.getInstance().createBasicDamager(ObjectParams(), _self, e);
          break;
        }
      });
    } else if(fsm.isDying()) {
      print("dying");
      if(dyingTimer == null) dyingTimer = Cooldown(millis: 500, initTime: true);
      dyingTimer.execute((){
        fsm.goDead();
      });
    } else if(fsm.isDead() && _self.isAlive) {
      print("dead");
      // AC.AnimatableComp animatableComp = _self.get<TowerComp>().terrainEntity.get<AnimatableComp>();
      // Entity terrainEntity = _self.get<TowerComp>().terrainEntity;
      // terrainEntity + animatableComp.copyWith(
      //   currentAnimation: MapEntry(
      //     TerrainState.UNPLANTED.toString(),
      //     _self.get<TowerComp>().terrainEntity.get<AnimatableComp>().sprites[TerrainState.UNPLANTED.toString()] 
      //   )
      // );
      // terrainEntity + TerrainComp();
      // _box2d.world.destroyBody(_self.get<CollisionComp>().body);
      // _self.destroy();
      _self + RemovableComp();
    }
  }

  @override
  void onTapUp(Entity self, double x, double y) {
    // TODO: implement onTapUp
  }
}

class TowerAiCore extends AiCore {
  final Entity _self;
  final Box2D _box2d;
  final BasicTowerFSM fsm;

  // final Cooldown attackCooldown;

  final Cooldown constructCooldown;
  TowerAiCore(
    Entity self,
    Box2D box2d,
  ) :
    _self = self,
    _box2d = box2d,
    fsm = BasicTowerFSM(),
    constructCooldown = Cooldown(millis: 1000, initTime: true);
    // attackCooldown = Cooldown(attackCooldown);

  // Entity _nearest;

  // bool _isOnTarget = false;

  @override
  void onCollision(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = true;
    // if(target == _nearest) fsm.onTarget();
  }

  @override
  void onCollisionLeave(Entity self, Entity target) {
    // if(target == _nearest) _isOnTarget = false;
    // if(target == _nearest) fsm.goToNearestTarget();
  }

  @override
  void onTap(Entity self, double x, double y) {
  }


  Cooldown dyingTimer;
  @override
  void update(double delta) {
    if(fsm.isIdle() || fsm.isAttack()) {
      // print("${_self.get<HealthComp>().health.currentHp}");
      if(_self.get<HealthComp>().health.currentHp == 0) {
        fsm.exhaustHp();
      }
    }

    if(fsm.isConstructing()) {
      constructCooldown.execute((){
        fsm.buildComplete();
      });
    } else if(fsm.isIdle()) {
    } else if(fsm.isAttack()) {
    } else if(fsm.isDying()) {
      print("dying");
      if(dyingTimer == null) dyingTimer = Cooldown(millis: 500, initTime: true);
      dyingTimer.execute((){
        fsm.goDead();
      });
    } else if(fsm.isDead() && _self.isAlive) {
      print("dead");
      AC.AnimatableComp animatableComp = _self.get<TowerComp>().terrainEntity.get<AnimatableComp>();
      Entity terrainEntity = _self.get<TowerComp>().terrainEntity;
      animatableComp.info.setAnimationByKey(
        TerrainState.UNPLANTED.toString()
      );
      terrainEntity + TerrainComp(_self);
      _box2d.world.destroyBody(_self.get<CollisionComp>().body);
      _self.destroy();
    }
  }

  @override
  void onTapUp(Entity self, double x, double y) {
    // TODO: implement onTapUp
  }
}

class FingerprintIdlePressingAnimation extends AC.SpriteAnimation {
  Paint paint;
  FingerprintIdlePressingAnimation() : super(
    Sprite("3d.png"),
    millis: 1500,
    isRepeatable: true
  ) {
    paint = Paint();
    paint.color = Colors.red;
  }

  @override
  void executeAnimation(Canvas canvas, PropertyComp comp, double t) {
    Position cneter = Position(comp.x, comp.y);
    if(sprite.loaded()) {
      CurveTween tween = CurveTween(curve: Curves.easeInOutSine);
      double opacity = 0;
      if(t < 0.5) {
        opacity = tween.transform(t * 2);
      } else {
        opacity = tween.transform(Math.max(1.0 - (t - 0.5) * 2, 0));
      }

      // draw base pattern
      canvas.saveLayer(null, Paint());
      sprite.paint = paint
        ..colorFilter = ColorFilter.mode(Colors.black, BlendMode.srcATop)
        ..imageFilter = null;
      sprite.renderCentered(canvas, cneter, size: Position(comp.width, comp.height),);
      canvas.restore();
      
      // draw lighting pattern
      canvas.saveLayer(null, Paint());
      sprite.paint = paint
        ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop)
        ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);
      canvas.clipRect(Offset(0, sprite.size.y - 60) & Size(sprite.size.x, 60), clipOp: ClipOp.intersect);
      sprite.renderCentered(canvas, cneter, size: Position(comp.width, comp.height));
      sprite.paint = paint
        ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop)
        ..imageFilter = ImageFilter.blur(sigmaX: 4, sigmaY: 4);
      sprite.renderCentered(canvas, cneter, size: Position(comp.width, comp.height));
      canvas.restore();
      
      // sprite.paint = paint..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop);
      // sprite.renderCentered(canvas, Position(sprite.size.x / 2, sprite.size.y / 2),);
      // canvas.restore();

      // sprite.paint = paint..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop);
      // sprite.paint..color = sprite.paint.color.withOpacity(opacity);
      // sprite.render(canvas);
    }
  }
}

class FingerprintIdleAnimation extends AC.SpriteAnimation {
  FingerprintIdleAnimation() : super(
    Sprite("3d.png"),
    millis: 1500,
    isRepeatable: true
  );
  
  @override
  void executeAnimation(Canvas canvas, PropertyComp comp, double t) {
    Position cneter = Position(comp.x, comp.y);
    if(sprite.loaded()) {
      CurveTween tween = CurveTween(curve: Curves.easeInOutSine);
      double opacity = 0;
      if(t < 0.5) {
        opacity = tween.transform(t * 2);
      } else {
        opacity = tween.transform(Math.max(1.0 - (t - 0.5) * 2, 0));
      }
      
      sprite.paint = paint
        ..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop)
        ..color = paint.color.withOpacity(opacity);
      sprite.renderCentered(canvas, cneter, size: Position(comp.width, comp.height));
      // canvas.restore();

      // sprite.paint = paint..colorFilter = ColorFilter.mode(Colors.blue, BlendMode.srcATop);
      // sprite.paint..color = sprite.paint.color.withOpacity(opacity);
      // sprite.render(canvas);
    }
  }
}


enum TowerState {
  idle, // fingerprint
  idleToActive,
  active,
}

class BasicTower extends EntityCreator {
  @override
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params) {
    Entity e = manager.createEntity();
    AC.AnimatableComp animatableComp = AC.AnimatableComp(
      AC.AnimationInfo(
        sprites: {
          TowerState.idle.toString(): FingerprintIdleAnimation(),
          TowerState.idleToActive.toString(): FingerprintIdlePressingAnimation()
        },
        initAnimationKey: TowerState.idle.toString()
      ),
    );

    final B2D.CircleShape shape = B2D.CircleShape();
    shape.radius = 5;

    print("${params.position.x} ${params.position.y}");
    print("${box2d.dimensions}");
    print("${box2d.viewport.scale}");
    // print("${box2d.viewport.center}");

    final fixtureDef = B2D.FixtureDef();
    // To be able to determine object in collision
    fixtureDef.shape = shape;
    fixtureDef.restitution = 0.0;
    fixtureDef.density = 1.0;
    fixtureDef.friction = 0.1;
    // fixtureDef.filter = Bodx2dFilterBits.bits(FilterType.Tower);
    fixtureDef.setUserData(e);

    final attackFixtureDef = B2D.FixtureDef();
    // To be able to determine object in collision
    attackFixtureDef.shape = B2D.CircleShape()..radius = 30;
    attackFixtureDef.restitution = 0.0;
    attackFixtureDef.density = 1.0;
    attackFixtureDef.friction = 0.1;
    attackFixtureDef.isSensor = true;
    attackFixtureDef.filter..categoryBits = Box2DFilter.Detector.bits;
    // attackFixtureDef.filter = Bodx2dFilterBits.bits(FilterType.TowerDetector);
    attackFixtureDef.setUserData(e);

    final bodyDef = B2D.BodyDef();
    bodyDef.position = B2D.Vector2(params.position.x, params.position.y);
    bodyDef.angularVelocity = 4.0;
    bodyDef.type = B2D.BodyType.STATIC;
    bodyDef.setUserData(e);

    B2D.Body body = box2d.world.createBody(bodyDef);
    body.createFixtureFromFixtureDef(fixtureDef);
    body.createFixtureFromFixtureDef(attackFixtureDef);
    CollisionComp collisionComp = CollisionComp(
      body
    );
    
    B2D.Vector2 position = box2d.viewport.getWorldToScreen(B2D.Vector2(bodyDef.position.x, bodyDef.position.y));
    PropertyComp propertyComp = PropertyComp(
      height: 96,
      width: 96,
      x: position.x, // screenPos
      y: position.y,
    );

    HealthComp healthComp = HealthComp(
      currentHp: 100,
      maxHp: 100,
      shield: 1,
    );

    AttackComp attakComp = AttackComp(
      power: 5
    );

    e + animatableComp + collisionComp + propertyComp + healthComp + attakComp +  AiComp(AttackTowerAiCore(e, box2d));//AiComp(TowerAiCore(e, box2d));
    return e;
  }
}