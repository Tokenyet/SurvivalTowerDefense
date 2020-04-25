import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/displays/basic_text.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrains/basic_terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

enum TextState {
  JustAppear,
  Appear,
  JustDead,
  Dead
}

class Display {
  static Display _display;
  static init(Box2D box2d, EntityManager manager) {
    _display = Display(box2d, manager);
  }

  final Box2D box2d;
  final EntityManager manager;
  Display(this.box2d, this.manager);

  static Display getInstance() {
    return _display;
  }


  Entity createDisplayText(ObjectParams params, String text) {
    return BasicText().createEntity(manager, box2d, params, text);
  }
}