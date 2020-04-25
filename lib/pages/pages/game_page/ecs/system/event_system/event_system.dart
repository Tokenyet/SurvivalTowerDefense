import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/terrain_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/level_manager.dart';
// import 'package:DarkSurviver/pages/pages/game_page/game_storage_system/energy_resource.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/resource_panel/resource_bloc.dart' as UI_RESOURCE;
import 'package:DarkSurviver/pages/pages/game_page/ui/static_screen_bloc.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/tower_construct_panel/tower_construct_bloc.dart' as UI_TOWER_CONSTRUCT;
import 'package:DarkSurviver/pages/pages/game_page/ui/ui_managet.dart';
import 'package:entitas_ff/entitas_ff.dart';

class EventSystem extends EntityManagerSystem implements ExecuteSystem {
  LevelSystem levelSystem;
  EventSystem(this.levelSystem);
  int _timestamp;
  
  @override
  execute() {
    Group eventGroup = entityManager.group(all: [EventComp]);

    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    double difference = (time.millisecondsSinceEpoch - _timestamp) / 1000;
    // int iteration = (time.millisecondsSinceEpoch - _timestamp) ~/ 16;
    // _timestamp += iteration * 16;
    _timestamp = time.millisecondsSinceEpoch;

    for(Entity e in eventGroup.entities) {
      _processEvents(e.get<EventComp>().event);
      e.destroy();
    }

    // for(int i = 0; i < iteration; i++) {
    //   for(Entity e in entities) {
    //     final AnimatableComp animatableComp = e.get<AnimatableComp>();
    //     animatableComp.currentAnimation.value.execute();
    //   }
    // }
  }

  void _processEvents(Event event) {
    if(event is SystemEvent) _processSystemEvent(event);
    if(event is SpawnEvent) _processSpawnEvent(event);
    if(event is UiEvent) _processUiEvent(event);
  }

  void _processSystemEvent(SystemEvent event) {
    print("SYSTEM_EVENT: $event");
    if(event is AddPowerEvent) {
      // EnergyResource.getInstance().addPower(event.value);
      UiManager.getInstacne().resourcePanelBloc.add(
        UI_RESOURCE.AddPowerEvent(event.value)
      );
    } else if(event is AddMoneyEvent) {
      UiManager.getInstacne().resourcePanelBloc.add(
        UI_RESOURCE.AddMoneyEvent(event.value)
      );
    } else if(event is RegisterHomeEvent) {
      print("Inner Register Home Evewt");
      levelSystem.registerHome(event.homeTowerEntity);
    } else if(event is UnregisterHomeEvent) {
      levelSystem.unregisterHome(event.homeTowerEntity);
    } else if(event is GameStartEvent) {
      levelSystem.gameStart();
    } else if(event is GameOverEvent) {
      levelSystem.gameOver();
      UiManager.getInstacne().staticScreenBloc.add(StaticScreenEvent.GameOverScreen);
    } else if(event is GameClearEvent) {
      levelSystem.gameClear();
      UiManager.getInstacne().staticScreenBloc.add(StaticScreenEvent.GameWinScreen);
    }
  }

  void _processSpawnEvent(SpawnEvent event) {

  }
  
  void _processUiEvent(UiEvent event) {
    print("UI EVENT");
    if(event is OpenTowerInitMenu)  {
      Entity e = event.terrainEntity;
      AnimatableComp animatableComp = e.get<AnimatableComp>();
      // Show UI to change state
      print("ProcessUiEvent");
      UiManager.getInstacne().towerConstructBloc.add(UI_TOWER_CONSTRUCT.HideConstructableEvent(null));

      animatableComp.info.setAnimationByKey(
        TerrainState.UNPLANTED_SELECT.toString()
      );

      TerrainComp comp = e.get<TerrainComp>();
      e.remove<TerrainComp>();
      e + comp.copyWith(state: TerrainState.UNPLANTED_SELECT);


      UiManager.getInstacne().towerConstructBloc.add(
        UI_TOWER_CONSTRUCT.ShowConstructableEvent(
          callback: (TowerType type) {
            if(type != null) {
              // PLANTED
              animatableComp.info.setAnimationByKey(
                TerrainState.PLANTED.toString(),
              );
              TerrainComp comp = e.get<TerrainComp>();
              e.remove<TerrainComp>();
              e + comp.copyWith(state: TerrainState.PLANTED);
              Tower.getInstance().createByTowerType(e, type);
            } else {
              // UNPLANTED
              animatableComp.info.setAnimationByKey(
                TerrainState.UNPLANTED.toString()
              );
              TerrainComp comp = e.get<TerrainComp>();
              e.remove<TerrainComp>();
              e + comp.copyWith(state: TerrainState.UNPLANTED);
            }
          },
          terrainEntity: e
        )
      );
    }
  }
}