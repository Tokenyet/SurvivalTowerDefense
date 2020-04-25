import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/enemy.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';

import 'event.dart';

abstract class SpawnEvent extends Event {}

class SpawnEnemyEvent extends SpawnEvent {
  final EnemyType enemy;
  final Vector2D worldPos;

  SpawnEnemyEvent(this.enemy, this.worldPos);
}