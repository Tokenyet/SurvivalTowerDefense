import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events.dart';
import 'package:entitas_ff/entitas_ff.dart';

import 'event.dart';

abstract class SystemEvent extends Event {}

class AddPowerEvent extends SystemEvent {
  final int value;
  AddPowerEvent(this.value);
}

class AddMoneyEvent extends SystemEvent {
  final int value;
  AddMoneyEvent(this.value);
}

class RegisterHomeEvent extends SystemEvent {
  final Entity homeTowerEntity;

  RegisterHomeEvent(this.homeTowerEntity);
}

class UnregisterHomeEvent extends SystemEvent {
  final Entity homeTowerEntity;

  UnregisterHomeEvent(this.homeTowerEntity);
}

class GameStartEvent extends SystemEvent {
}

class GamePauseEvent extends SystemEvent {
}

class GameOverEvent extends SystemEvent {
}

class GameClearEvent extends SystemEvent {
}

// class UpgradeEvent extends SystemEvent {
//   final Entity originalEntity;
//   final Entity targetEntity;
// }