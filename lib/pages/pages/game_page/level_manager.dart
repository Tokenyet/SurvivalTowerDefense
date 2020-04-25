import 'dart:async';
import 'dart:math' as Math;
import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ui/round_panel/round_panel_bloc.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/enemy.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/event_manager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/ui_managet.dart';
import 'package:DarkSurviver/utilities/cooldown.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:DarkSurviver/utilities/vector_space.dart';

import 'ecs/component/enemy_comp.dart';
import 'ecs/entities/entity_creator.dart';

class Level {
  List<Round> rounds;
  Level({
    this.rounds,
  });
}

class Round {
  double millis;
  Map<double, List<SubRound>> subrounds;
  Round({
    this.millis,
    this.subrounds,
  });
}

class SubRound {
  List<Vector2D> positions;
  EnemyType type;
  SubRound({
    this.positions,
    this.type,
  });
}

class LevelSystem {
  final EntityManager em;
  final Box2D box2d;

  List<Level> levels = [];
  Level currentLevel;
  LevelSystem(this.em, this.box2d);
  // List<List<TerrainType>> levels;

  List<List<Entity>> terrainEntities = [];
  void setUpTestLevel() {
    // cleanup terrain collision bodies
    if(terrainEntities != null && terrainEntities.isNotEmpty) {
      for(Entity e in terrainEntities.fold([], (v, entities) => v.toList() + entities)) {
        box2d.world.destroyBody((e.get<CollisionComp>().body));
        e.destroy();
      }
      terrainEntities.clear();
    }
    // Add Terrains
    double span = 90.0; /// / box2d.viewport.scale;
    B2D.Vector2 center = box2d.viewport.getWorldToScreen(B2D.Vector2(0, 0));
    for(int y = 0; y < 10; y++) {
      if(y == terrainEntities.length) terrainEntities.add(List<Entity>());
      double positionY = span / 1.5 * (y - 5) + center.y;
      bool isOffset = y % 2 == 0;
      for(int x = 0; x < 10; x++) {
        double positionX = span * (x - 5) + center.x + (isOffset ? 45 : 0);
        // B2D.Vector2 worldPos = box2d.viewport.getScreenToWorld(B2D.Vector2(positionX, positionY));
        if(x == terrainEntities[y].length) {
          // terrainEntities[y].add(Terrain.getInstance().createBasicTerrain(ObjectParams(position: Position(worldPos.x, worldPos.y))));
          terrainEntities[y].add(Terrain.getInstance().createBasicTerrain(ObjectParams(position: Position(positionX, positionY))));
        }
      }
    }

    Tower.getInstance().createHomeTower(terrainEntities[5][5]);

    addTestLevel();
    addTestLevel();
    currentLevel = levels.first;
  }

  List<Entity> homeEntities;

  // Register home to prevent
  void registerHome(Entity entity) {
    print("Register");
    if(homeEntities == null) {
      homeEntities = [];
      EventManager.getInstance().systemEventManager.createGameStartEvent();
    }
    homeEntities.add(entity);

    // UiManager.getInstacne().roundPanelBloc.startPanel();
  }

  // Unregister home
  void unregisterHome(Entity entity) {
    print("Unreigster");
    homeEntities.remove(entity);
    if(homeEntities.isEmpty) {
      print("Dispatch game over event");
     homeEntities = null;
     EventManager.getInstance().systemEventManager.createGameOverEvent();
    }
  }

  StreamSubscription _streamSubscription;
  Stream _gameStream;
  StreamSubscription _gameClearSubscription;
  Stream _gameClearStream;

  void gameStart() {
    print("Start game");
    if(_gameStream == null) {
      _gameStream = createGameStream(levels);
      _streamSubscription = _gameStream.listen((_){});
      _streamSubscription.onDone(() {
        print("Done game levels");
        _gameClearStream = createLevelClearStream();
        _gameClearSubscription = _gameClearStream.listen((_){});
        _gameClearSubscription.onDone((){
          print("Done clear game");
          EventManager.getInstance().systemEventManager.createGameClearEvent();
        });
      });
    }
  }

  void gameOver() {
    print("End game");
    _gameStream = null;
    if(_streamSubscription != null) _streamSubscription.cancel();
    _streamSubscription = null;
    _gameClearStream = null;
    if(_gameClearSubscription != null) _gameClearSubscription.cancel();
    _gameClearSubscription = null;
  }

  void gameClear() {
    _gameStream = null;
    if(_streamSubscription != null) _streamSubscription.cancel();
    _streamSubscription = null;
    _gameClearStream = null;
    if(_gameClearSubscription != null) _gameClearSubscription.cancel();
    _gameClearSubscription = null;
  }
  

  void createAnEnemy(Vector2D worldPosVec) {
    // print(vector2d);
    // print(Vector2D.fromVector2(box2d.viewport.getScreenToWorld(vector2d.toVector2())));
    // double x = (vector2d.x - window.physicalSize.width / 2) / box2d.viewport.scale;
    // double y = (vector2d.y + window.physicalSize.height / 2) / box2d.viewport.scale;
    // print("expected: $x, $y");
    Enemy.getInstance().createBasicEnemy(
      ObjectParams(
        position: worldPosVec.toPosition()
      )
    );
  }

  // Cooldown spawnCooldown = Cooldown(
  //   initTime: true,
  //   millis: 2000
  // );

  void round(int i) {
    DateTime time = DateTime.now();
    // UiManager.getInstacne().roundPanelBloc.startPanel();
  }

  Cooldown roundTimer = Cooldown(
    initTime: false,
    millis: 10000,
  );

  void update() {

    double totalTime = currentLevel.rounds.fold<double>(0, (value, round) => value + round.millis);

    // List<Round> rounds = levels.first.rounds;
    // for(Round round in rounds) {
    //   if(round.)
    // }
    // return;
    // spawnCooldown.execute((){
    //   Vector2D worldLeftTop = Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(0, 0).toVector2()));
    //   Vector2D worldRightBottom = Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(box2d.viewport.size.width, box2d.viewport.size.height).toVector2()));

    //   // Allow spawn area 
    //   // Left: -2 ~ -1 (any y in height)
    //   // Right: width ~ width + 2 (any y in height)
    //   // Top: 0 - 2 ~ 0 - 1 (any x in width)
    //   // Bottom: height + 2 ~ height + 1 (any x in width)

    //   switch(Math.Random().nextInt(4)) {
    //     case 0:
    //       createAnEnemy(Vector2D(worldLeftTop.x -2, worldRightBottom.y * 2 * Math.Random().nextDouble() - worldRightBottom.y));
    //       break;
    //     case 1:
    //       createAnEnemy(Vector2D(worldRightBottom.x + 2, worldRightBottom.y * 2 * Math.Random().nextDouble() - worldRightBottom.y));
    //       break;
    //     case 2:
    //       createAnEnemy(Vector2D(worldRightBottom.x * 2 * Math.Random().nextDouble() - worldRightBottom.x, worldLeftTop.y + 2));
    //       break;
    //     case 3:
    //       createAnEnemy(Vector2D(worldRightBottom.x  * 2 * Math.Random().nextDouble() - worldRightBottom.x, worldRightBottom.y - 2));
    //       break;
    //   };
    // });

  }

  Vector2D getRandomPos() {
    Vector2D worldLeftTop = Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(0, 0).toVector2()));
    Vector2D worldRightBottom = Vector2D.fromVector2(box2d.viewport.getScreenToWorld(Vector2D(box2d.viewport.size.width, box2d.viewport.size.height).toVector2()));

    // Allow spawn area 
    // Left: -2 ~ -1 (any y in height)
    // Right: width ~ width + 2 (any y in height)
    // Top: 0 - 2 ~ 0 - 1 (any x in width)
    // Bottom: height + 2 ~ height + 1 (any x in width)

    switch(Math.Random().nextInt(4)) {
      case 0:
        return Vector2D(worldLeftTop.x -2, worldRightBottom.y * 2 * Math.Random().nextDouble() - worldRightBottom.y);
        break;
      case 1:
        return Vector2D(worldRightBottom.x + 2, worldRightBottom.y * 2 * Math.Random().nextDouble() - worldRightBottom.y);
        break;
      case 2:
        return Vector2D(worldRightBottom.x * 2 * Math.Random().nextDouble() - worldRightBottom.x, worldLeftTop.y + 2);
        break;
      case 3:
        return Vector2D(worldRightBottom.x  * 2 * Math.Random().nextDouble() - worldRightBottom.x, worldRightBottom.y - 2);
        break;
    };

    return worldLeftTop;
  }

  void addTestLevel() {
    levels.add(Level(
      rounds: [
        Round(
          millis: 20000,
          subrounds: {
            0.1: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
            0.5: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
          }
        ),
        Round(
          millis: 20000,
          subrounds: {
            0.1: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
            0.5: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
          }
        ),
        Round(
          millis: 20000,
          subrounds: {
            0.1: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
            0.5: [
              SubRound(
                positions: [
                  getRandomPos(),
                  getRandomPos(),
                  getRandomPos(),
                ],
                type: EnemyType.basicEnemy
              )
            ],
          }
        ),
      ]
    ));
  }

// gameStartEvent
// Stream => RoundStream according to round
// Stream => RestStream 30 sec
// Stream => RoundStream according to round
// Stream => RestStream 30 sec
// ...
// gameOverEvent / gameEndEvent

  Stream<dynamic> createLevelStream(Level level, int index) async* {
    double maximumDistance = currentLevel.rounds.fold<double>(0, (value, round) => value + round.millis);
    int totalTicks = maximumDistance ~/ 100;
    for(Round round in level.rounds) {
      int ticks = round.millis ~/ 100;
      for(int i = 0; i < ticks; i++) {
        int second = i ~/ 10;
        // Update round display bloc
        await Future.delayed(const Duration(milliseconds: 100));
        yield null;
        Map<double, List<SubRound>> timerounds = round.subrounds;
        // print("Sync round");
        UiManager.getInstacne().roundPanelBloc.add(
          SyncRoundEvent(
            currentSeconds: second,
            maximumSeconds: round.millis ~/ 1000,
            roundProgress: Math.max(1.0, second * 100 / round.millis),
            roundTimeline: timerounds.keys.toList(),
            level: index
          )
        );
        for(MapEntry<double, List<SubRound>> timeRound in timerounds.entries) {
          if(i >= ticks * timeRound.key) {
            timeRound.value.forEach((SubRound round) {
              round.positions.forEach((Vector2D pos) {
                Enemy.getInstance().createBasicEnemy(ObjectParams(position: pos.toPosition()));
              });
            });
            timerounds.remove(timeRound.key);
            break;
          }
        }
      }
    }
  }


  Stream<dynamic> createGameStream(List<Level> levels) async* {
    for(int i = 0; i < levels.length; i++) {
      for(int i = 0; i < 30; i++) {
        // print("Sync wait");
        UiManager.getInstacne().roundPanelBloc.add(SyncWaitEvent(currentSeconds: i + 1, maximumSeconds: 30));
        yield null;
        await Future.delayed(const Duration(seconds: 1));
      }
      yield* createLevelStream(levels[i], i);
    }
  }

  Stream<bool> createLevelClearStream() async* {
    while(true) {
      Group enemyEntities = em.group(all: [EnemyComp]);
      int enemyCount = enemyEntities.entities.length;
      if(enemyCount == 0) {
        print("Level Clear");
        yield true;
        break;
      }
      await Future.delayed(const Duration(seconds: 1));
      yield false;
    }
  }
}