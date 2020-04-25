import 'package:entitas_ff/entitas_ff.dart';

import 'event.dart';

abstract class UiEvent extends Event {}

class OpenTowerInitMenu extends UiEvent {
  Entity terrainEntity;
  
  OpenTowerInitMenu({
    this.terrainEntity,
  });
}
