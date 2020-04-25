import 'dart:ui';
import 'dart:math' as Math;

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/attack_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/health_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/hurter_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/canvas_util.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart' as AC;
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import '../entity_creator.dart';
import '../terrain.dart';

class DamagerAnimation extends AC.PainterAnimation {
  Paint paint;
  Entity self;
  Entity target;
  Vector2D originPos;
  double speed;
  DamagerAnimation({
    this.self,
    this.target,
    this.speed = 0.1
  }) : super(
    isRepeatable: false
  ) {
    paint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;
    originPos = Vector2D(
      self.get<PropertyComp>().x,
      self.get<PropertyComp>().y
    );
    Vector2D targetPos = Vector2D(
      target.get<PropertyComp>().x,
      target.get<PropertyComp>().y
    );
    latestTargetPos = targetPos;
    this.millis = (targetPos - originPos).length ~/ speed;
  }

  Vector2D latestTargetPos;

  @override
  void executeAnimation(Canvas canvas, PropertyComp comp, double t) {
    Vector2D originPos = this.originPos;
    Vector2D targetPos = target.isAlive ? Vector2D(target.get<PropertyComp>().x, target.get<PropertyComp>().y) : latestTargetPos;
    if(targetPos == null) print("targetPos = null");
    if(originPos == null) print("originPos = null");
    Vector2D startPos = (targetPos - originPos).limitVector((targetPos - originPos).length * t);
    Vector2D endPos = (targetPos - originPos).limitVector((targetPos - originPos).length * Math.min(t + 0.2, 1.0));
    Vector2D startPosA = startPos + Vector2D(0, 5);
    Vector2D startPosB = startPos + Vector2D(0, -5);
    Vector2D endPosA = endPos + Vector2D(0, 5);
    Vector2D endPosB = endPos + Vector2D(0, -5);
    canvas.drawPath(CanvasUtil.polygon([
      (originPos + startPosA).toOffset(),
      (originPos + endPosA).toOffset(),
      (originPos + endPosB).toOffset(),
      (originPos + startPosB).toOffset(),
    ]), paint);
    // canvas.drawLine((originPos + startPos).toOffset(), (originPos + endPos).toOffset(), paint);
  }
}

class BasicDamager extends DamangerCreator {
  @override
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params, Entity emitter, Entity target) {
    Entity e = manager.createEntity();
    
    // B2D.Vector2 position = box2d.viewport.getWorldToScreen(B2D.Vector2(params.position.x, params.position.y));
    // PropertyComp propertyComp = PropertyComp(
    //   height: 90,
    //   width: 90,
    //   x: position.x,
    //   y: position.y,
    // );

    Map<String, AC.Animation> animations = {
      "Shoot": DamagerAnimation(self: emitter, target: target)
    };
    AnimatableComp animatableComp = AnimatableComp(
      AnimationInfo(
        initAnimationKey: "Shoot",
        sprites: animations
      )
    );

    (animatableComp.info.currentAnimation.value as DamagerAnimation).onComplete = () {
      print("Hurt enemy");
      // if(target.isAlive && emitter.isAlive) target.get<HealthComp>().health.hurt(emitter.get<AttackComp>().attack.power);
      // e.destroy();
      SystemEntity.getInstance().createHurter(HurtInfo(
        attacker: emitter,
        target: target,
      ));
      e.destroy();
    };

    e + animatableComp;
    return e;
  }
}