import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/resource_panel/resource_bloc.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/round_panel/round_panel_bloc.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/static_screen_bloc.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/tower_construct_panel/tower_construct_bloc.dart';
import 'package:entitas_ff/entitas_ff.dart';

class UiManager {
  UiManager._();
  static UiManager _instance;

  TowerConstructBloc towerConstructBloc;
  ResourcePanelBloc resourcePanelBloc;
  RoundPanelBloc roundPanelBloc;
  StaticScreenBloc staticScreenBloc;

  void init(TowerConstructBloc towerConstructBloc, ResourcePanelBloc resourcePanelBloc, RoundPanelBloc roundPanelBloc, StaticScreenBloc staticScreenBloc) {
    this.towerConstructBloc = towerConstructBloc;
    this.resourcePanelBloc = resourcePanelBloc;
    this.roundPanelBloc = roundPanelBloc;
    this.staticScreenBloc = staticScreenBloc;
  }
  

  // void showPlantMenu(void Function(TowerType) callback, Entity terrainEntity) {
  //   hide();
  //   towerConstructPanel.towerConstructPanelState.show(callback, terrainEntity);
  // }

  // void hide() {
  //   towerConstructPanel.towerConstructPanelState.hide();
  // }

  static UiManager getInstacne() {
    if(_instance == null) _instance = UiManager._();
    return _instance;
  }
}