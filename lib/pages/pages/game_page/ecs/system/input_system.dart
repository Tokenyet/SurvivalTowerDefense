
import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/entity_creator.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/sprite.dart';

class InputSystem extends ReactiveSystem {
  InputSystem();

  @override
  GroupChangeEvent get event => GroupChangeEvent.addedOrUpdated;

  @override
  EntityMatcher get matcher => EntityMatcher(any: [InputMouseComp]);

  
  @override
  executeWith(List<Entity> entities) {
    // final InputMouseComp inputComp = entityManager.getUnique<InputMouseComp>();
    // final SpriteComp spriteComp = entityManager.getUnique<SpriteComp>();
    print("input system: ${entities.length}");
    for(Entity e in entities) {
      final position = e.get<InputMouseComp>().position;
      // mouse postion to world
      // -params.position.x - window.physicalSize.width / 2) / box2d.viewport.scale, (params.position.y + window.physicalSize.height / 2) / box2d.viewport.scale


      // Entity entity = Tower.getInstance().createBaseFingerPrintTower(ObjectParams(position: position));
      // Entity entity = entityManager.createEntity();
      // entity + SpriteComp(
      //   Sprite(
      //     "SB30Pn.jpg",
      //     x: position.x,
      //     y: position.y
      //   ),
      //   null,
      // );
      print(".....");
      e.destroy();
    }
    
    // entityManager.setUnique(CountComponent(count + 1));
  }


}