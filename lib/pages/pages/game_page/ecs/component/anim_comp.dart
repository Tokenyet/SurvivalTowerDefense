import 'dart:ui';

import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';

abstract class Animation {
  final bool isRepeatable;
  Paint paint;
  Animation([
    this.isRepeatable = false,
  ]) :
    paint = Paint();  
  void execute(Canvas canvas, PropertyComp propertyComp);


  void reset();
}


class StaticSpriteAnimation extends SpriteAnimation {
  StaticSpriteAnimation(Sprite sprite) : super(sprite);

  @override
  void executeAnimation(Canvas canvas, PropertyComp comp, double t) {
    Position center = Position(comp.x, comp.y);
    sprite.renderCentered(canvas, center, size: Position(comp.width, comp.height), overridePaint: paint);
  }
}

mixin AnimationCallbackMixin {
  void Function(double t) onProgress;
  void Function() onComplete;
}

abstract class PainterAnimation extends Animation with AnimationCallbackMixin {
  int _timestamp;
  int millis = 1500;

  PainterAnimation({this.millis = 1500, bool isRepeatable = false}) : super(isRepeatable);

  // void Function(double t) onProgress;
  // void Function() onComplete;

  @override
  void execute(Canvas canvas, PropertyComp comp) {
    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    int difference = time.millisecondsSinceEpoch - _timestamp;
    // print("$difference $millis");
    double t = difference.toDouble() / millis.toDouble();
    executeAnimation(canvas, comp, t);
    if(onProgress != null) onProgress(t);

    if(isRepeatable && difference > millis) {
      _timestamp = time.millisecondsSinceEpoch;
    }

    if(!isRepeatable && difference > millis) {
      if(onComplete != null) onComplete();
    }
  }

  void executeAnimation(Canvas canvas, PropertyComp comp, double t);

  @override
  void reset() {
    _timestamp = DateTime.now().millisecondsSinceEpoch;
    // onComplete = null;
    // onProgress = null;
  }
}

abstract class SpriteAnimation extends Animation with AnimationCallbackMixin {
  int _timestamp;
  Sprite sprite;
  int millis = 1500;

  SpriteAnimation(this.sprite, {this.millis = 1500, bool isRepeatable = false}) : super(isRepeatable) {
    paint = sprite.paint;
  }

  @override
  void execute(Canvas canvas, PropertyComp comp) {
    DateTime time = DateTime.now();

    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    int difference = time.millisecondsSinceEpoch - _timestamp;
    // print("$difference $millis");
    double t = difference.toDouble() / millis.toDouble();

    executeAnimation(canvas, comp, t);

    if(onProgress != null) onProgress(t);

    if(isRepeatable && difference > millis) {
      _timestamp = time.millisecondsSinceEpoch;
    }

    if(!isRepeatable && difference > millis) {
      if(onComplete != null) onComplete();
    }
  }

  void executeAnimation(Canvas canvas, PropertyComp comp, double t);

  @override
  void reset() {
    _timestamp = DateTime.now().millisecondsSinceEpoch;
  }
}

class AnimationInfo {
  final Map<String, Animation> sprites;
  MapEntry<String, Animation> currentAnimation;

  AnimationInfo({
    this.sprites,
    // this.currentAnimation,
    String initAnimationKey
  }) :
    assert(sprites.containsKey(initAnimationKey), initAnimationKey),
    currentAnimation = MapEntry(initAnimationKey, sprites[initAnimationKey]);

  void setAnimationByKey(String animationName, [bool force = false]) {
    if(this.currentAnimKey == animationName && !force) return;
    if(this.sprites.containsKey(animationName)) {
      this.currentAnimation = MapEntry(
        animationName,
        this.sprites[animationName]
      );
    }
  }

  Animation get currentAnim => this.currentAnimation.value;

  String get currentAnimKey => this.currentAnimation.key;

  bool isAnimationKeyExist(String animationName) {
    return this.sprites.containsKey(animationName);
  }
}

class AnimatableComp extends Component {
  // final Map<String, Animation> sprites;
  // final MapEntry<String, Animation> currentAnimation;
  // AnimatableComp(this.sprites, this.currentAnimation);
  final AnimationInfo info;
  AnimatableComp(this.info);
  // AnimatableComp(this.sprites) {
  //   // Tween(begin: 0.1, end: 1.0).transform(t);
  //   // CurveTween(curve: Curves.bounceIn).transform(3.0);
  // }
  // AnimatableComp copyWith({
  //   Map<String, Animation> sprites,
  //   MapEntry<String, Animation> currentAnimation
  // }) {
  //   return AnimatableComp(
  //     sprites ?? this.sprites,
  //     currentAnimation ?? this.currentAnimation
  //   );
  // }
}