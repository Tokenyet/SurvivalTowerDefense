import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/name_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrains/basic_terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/level_manager.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'entity_creator.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events/system_event.dart' as SYSTEM;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events/spawn_event.dart' as SPAWN;
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events/ui_event.dart' as UI;

class EventManager {
  static EventManager _eventManager;
  static init(Box2D box2d, EntityManager manager, LevelSystem levelSystem) {
    _eventManager = EventManager(box2d, manager, levelSystem);
  }

  final Box2D box2d;
  final EntityManager manager;
  final LevelSystem levelSystem;
  EventManager(
    this.box2d,
    this.manager,
    this.levelSystem,
  ):
    systemEventManager = _SystemEventManager(box2d, manager, levelSystem),
    spawnEventManager = _SpawnEventManager(box2d, manager, levelSystem),
    uiEventManager = _UiEventManager(box2d, manager, levelSystem);

  final _SystemEventManager systemEventManager;
  final _SpawnEventManager spawnEventManager;
  final _UiEventManager uiEventManager;


  static EventManager getInstance() {
    return _eventManager;
  }

  void createSystemEvent() {    
  }
}

class _SystemEventManager {
  final Box2D box2d;
  final EntityManager manager;
  final LevelSystem levelSystem;
  _SystemEventManager(this.box2d, this.manager, this.levelSystem);

  void createAddPowerEvent(int value) {
    manager.createEntity() + EventComp(event: SYSTEM.AddPowerEvent(value));
  }

  void createAddMoneyEvent(int value) {
    manager.createEntity() + EventComp(event: SYSTEM.AddMoneyEvent(value));
  }

  void registerHomeBaseEvent(Entity entity) {
    manager.createEntity() + EventComp(event: SYSTEM.RegisterHomeEvent(entity));
  }

  void unregisterHomeBaseEvent(Entity entity) {
    manager.createEntity() + EventComp(event: SYSTEM.UnregisterHomeEvent(entity));
  }

  void createGameStartEvent() {
    manager.createEntity() + EventComp(event: SYSTEM.GameStartEvent());
  }

  void createGameOverEvent() {
    manager.createEntity() + EventComp(event: SYSTEM.GameOverEvent());
  }

  void createGameClearEvent() {
    manager.createEntity() + EventComp(event: SYSTEM.GameClearEvent());
  }
}

class _SpawnEventManager {
  final Box2D box2d;
  final EntityManager manager;
  final LevelSystem levelSystem;
  _SpawnEventManager(this.box2d, this.manager, this.levelSystem);
}

class _UiEventManager {
  final Box2D box2d;
  final EntityManager manager;
  final LevelSystem levelSystem;
  _UiEventManager(this.box2d, this.manager, this.levelSystem);

  void createInitTowerMenuEvent(Entity terrainEntity) {
    print("createInitTowerMenuEvent");
    manager.createEntity() + EventComp(event: UI.OpenTowerInitMenu(terrainEntity: terrainEntity));
  }
}