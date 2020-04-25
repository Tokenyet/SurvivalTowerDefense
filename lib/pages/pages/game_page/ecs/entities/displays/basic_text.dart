
import 'dart:ui';
import 'dart:math' as Math;

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart' as AC;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/removable_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/display.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/entity_creator.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';

class TextAnimation extends AC.PainterAnimation {
  TextPainter textPainter;
  TextAnimation([InlineSpan span]) : super(millis: 1500, isRepeatable: false) {
    _textSpan = span;
    textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      text: span
    );
  }

  InlineSpan _textSpan;
  
  set text(InlineSpan textSpan) {
    _textSpan = textSpan;
  }

  @override
  void executeAnimation(Canvas canvas, PropertyComp comp, double t) {
    textPainter.text = TextSpan(
      children:[_textSpan],
      style: TextStyle(color: Colors.blueAccent.withOpacity(Math.max(Math.min(t, 0.0), 1.0)))
    );
    textPainter.layout();
    double width = textPainter.width;
    double height = textPainter.height;
    textPainter.paint(canvas, Offset(comp.x - width / 2, comp.y - height / 2));
  }
}

class TextAiCore extends AiCore {
  TextAnimation animation;
  Entity _self;
  TextAiCore(TextSpan span, Entity self) {
    _self = self;
     AC.AnimatableComp animComp = _self.get<AC.AnimatableComp>();
    animation = animComp.info.currentAnim as TextAnimation;
    animation.onComplete = () {
      self + RemovableComp();
    };
  }
  
  @override
  void onCollision(Entity self, Entity target) {
  }

  @override
  void onCollisionLeave(Entity self, Entity target) {
  }

  @override
  void onTap(Entity self, double x, double y) {
  }

  @override
  void onTapUp(Entity self, double x, double y) {
  }

  @override
  void update(double delta) {
  }

}


class BasicText {
  Entity createEntity(EntityManager manager, Box2D box2d, ObjectParams params, String text) {
    Entity e = manager.createEntity();
    AC.AnimatableComp animatableComp = AC.AnimatableComp(
      AC.AnimationInfo(
        sprites: {
          TextState.JustAppear.toString(): TextAnimation(TextSpan(text: text)),
        },
        initAnimationKey: TextState.JustAppear.toString()
      )
    );
    // animatableComp.info.setAnimationByKey(TextState.JustAppear.toString());
    
    PropertyComp propertyComp = PropertyComp(
      x: params.position.x,
      y: params.position.y,
    );

    e + animatableComp + propertyComp + AiComp(
      TextAiCore(TextSpan(text: text), e)
    );
    return e;
  }
}


