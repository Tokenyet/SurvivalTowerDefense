import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
// import 'package:DarkSurviver/pages/ecs/component/sprite_comp.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/sprite.dart';

class AnimateSystem extends ReactiveSystem {
  AnimateSystem();
  int _timestamp;

  @override
  GroupChangeEvent get event => GroupChangeEvent.addedOrUpdated;

  @override
  EntityMatcher get matcher => EntityMatcher(any: [AnimatableComp]);

  
  @override
  executeWith(List<Entity> entities) {
    // final InputMouseComp inputComp = entityManager.getUnique<InputMouseComp>();
    // final SpriteComp spriteComp = entityManager.getUnique<SpriteComp>();
    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    int iteration = (time.millisecondsSinceEpoch - _timestamp) ~/ 16;
    _timestamp += iteration * 16;

    // for(int i = 0; i < iteration; i++) {
    //   for(Entity e in entities) {
    //     final AnimatableComp animatableComp = e.get<AnimatableComp>();
    //     animatableComp.currentAnimation.value.execute();
    //   }
    // }
  }
}