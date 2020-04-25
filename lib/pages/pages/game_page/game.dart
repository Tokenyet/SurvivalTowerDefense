import 'dart:ui';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/name_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/box2d_filter.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/damager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/display.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/enemy.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/event_manager.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/terrain.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/_system/hurter_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/_system/recycle_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/_system/render_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/ai_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/event_system/event_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/input_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/movement_system.dart';
import 'package:DarkSurviver/pages/pages/game_page/level_manager.dart';
import 'package:DarkSurviver/utilities/box2d_debugger_render.dart';
import 'package:DarkSurviver/utilities/box2d_fixer.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:DarkSurviver/utilities/vector_space.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/position.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
// import 'package:ecs_dart/ecs_dart.dart';
import 'package:entitas_ff/entitas_ff.dart';

import 'ecs/component/anim_comp.dart';
import 'ecs/system/collision_system.dart';

import 'package:box2d_flame/box2d.dart' as B2D;

class MouseRaycast extends B2D.RayCastCallback {
  final double Function(B2D.Fixture fixture, B2D.Vector2 point, B2D.Vector2 normal, double fraction) callback;
  MouseRaycast(this.callback);

  @override
  double reportFixture(B2D.Fixture fixture, B2D.Vector2 point, B2D.Vector2 normal, double fraction) {
    return callback(fixture, point, normal, fraction);
  }
}

class MouseQuery extends B2D.QueryCallback {
  final bool Function(B2D.Fixture fixture) callback;
  MouseQuery(this.callback);

  @override
  bool reportFixture(B2D.Fixture fixture) {
    return callback(fixture);
  }
}

class MainGame extends BaseGame {
  static final Paint paint = Paint()..color = const Color(0xFF888888);
  static Box2D box2d;
  static EntityManager em;
  static RootSystem rootSystem;
  static RenderSystem renderSystem;

  var movingLeft = false;
  var movingRight = false;
  var movingUp = false;
  var movingDown = false;

  double x = 0;
  double y = 0;

  LevelSystem levelSystem;

  MainGame()
  {
    em = EntityManager();
    box2d = Box2D(em); // pass em for retreiving nearest tower/enemy...
    levelSystem = LevelSystem(em, box2d);
    Tower.init(box2d, em);
    Terrain.init(box2d, em);
    Enemy.init(box2d, em);
    Damager.init(box2d, em);
    Display.init(box2d, em);
    SystemEntity.init(box2d, em);
    EventManager.init(box2d, em, levelSystem);
    rootSystem = RootSystem(
      em,
      [
        InputSystem(),
        CollisionSystem(box2d),
        AiSystem(),
        HurterSystem(box2d, em),
        MovementSystem(box2d),
        EventSystem(levelSystem),
        RecycleSystem(box2d, em),
      ]
    );
    renderSystem = RenderSystem.getInstance();
    rootSystem.init();
    renderSystem.init(box2d, em);
    // levelSystem = LevelSystem(em, box2d);
    _start();
  }

  @override
  void resize(Size size) {
    box2d.resize(size);
    components.forEach((c) {
      c.resize(size);
    });
    super.resize(size);
  }

  @override
  void onDetach() {
    super.onDetach();
    levelSystem.gameOver();
  }

  @override
  Color backgroundColor() => Color(0xff2e2e2e);

  Entity _lastTapDownEntity;
  @override
  void onTapUp(TapUpDetails details) {
    B2D.Vector2 worldPos = box2d.viewport.getScreenToWorld(B2D.Vector2(details.globalPosition.dx, details.globalPosition.dy));
    print(worldPos);
    if(_lastTapDownEntity != null) {
      if(_lastTapDownEntity.has(AiComp)) {
        print("ontapup with entity");
        _lastTapDownEntity.get<AiComp>().core.onTapUp(_lastTapDownEntity, worldPos.x, worldPos.y);
        _lastTapDownEntity = null;
        return;
      }
    }
    box2d.world.queryAABB(MouseQuery((B2D.Fixture fixture) {
      if(fixture.getFilterData().categoryBits & Box2DFilter.Detector.bits > 0) return true;
      // print("castcallback");
      dynamic entity = fixture.userData;
      if(!Box2dFixer.testPoint(fixture, Vector2D.fromVector2(worldPos))) return true;
      if(entity != _lastTapDownEntity) return true; // not the entity, keep finding
      // print(entity);
      if(entity is Entity) {
        if(entity.has(NameComp)) print("OnTapUp: ${entity.get<NameComp>().name}");
        // print("OnTapDown: ${entity.has(TowerComp)}");
        if(entity.has(AiComp)) {
          // print("ontap");
          entity.get<AiComp>().core.onTapUp(entity, worldPos.x, worldPos.y);
          _lastTapDownEntity = null;
          return false;
        }
      }
      return true;
    }), B2D.AABB.withVec2(B2D.Vector2(worldPos.x - 0.01, worldPos.y - 0.01), B2D.Vector2(worldPos.x + 0.01, worldPos.y + 0.01)));
  }

  @override
  void onTapCancel() {
    if(_lastTapDownEntity != null) {
      if(_lastTapDownEntity.has(AiComp)) {
        print("ontapup with entity");
        _lastTapDownEntity.get<AiComp>().core.onTapUp(_lastTapDownEntity, 0, 0);
        _lastTapDownEntity = null;
        return;
      }
    }
  }

  @override
  void onTapDown(TapDownDetails details) {
    Entity inputEntity = em.createEntity();
    inputEntity + InputMouseComp(
      Position(-details.globalPosition.dx, -details.globalPosition.dy)
    );

    B2D.Vector2 worldPos = box2d.viewport.getScreenToWorld(B2D.Vector2(details.globalPosition.dx, details.globalPosition.dy));
    print(worldPos);
    box2d.world.queryAABB(MouseQuery((B2D.Fixture fixture) {
      if(fixture.getFilterData().categoryBits & Box2DFilter.Detector.bits > 0) return true;
      print("categoryBits: ${fixture.getFilterData().categoryBits}");
      // print("castcallback");
      dynamic entity = fixture.userData;
      if(!Box2dFixer.testPoint(fixture, Vector2D.fromVector2(worldPos))) {
        // if(fixture.getShape() is! B2D.CircleShape) { // CirculeShape testpoint bug.... fuck
        //   return true;
        // }
        print("Missing???: ${worldPos} ${fixture.getBody().position} ${fixture.testPoint(B2D.Vector2(worldPos.x, worldPos.y))}");
        return true;
      }
      // print(entity);
      if(entity is Entity) {
        if(entity.has(NameComp)) print("OnTapDown: ${entity.get<NameComp>().name}");
        // print("OnTapDown: ${entity.has(TowerComp)}");
        if(entity.has(AiComp)) {
          // print("ontap");
          entity.get<AiComp>().core.onTap(entity, worldPos.x, worldPos.y);
          _lastTapDownEntity = entity;
          return false;
        }
      }
      return true; // keeup tracking
    }), B2D.AABB.withVec2(B2D.Vector2(worldPos.x - 0.01, worldPos.y - 0.01), B2D.Vector2(worldPos.x + 0.01, worldPos.y + 0.01)));

    // levelSystem.createAnEnemy(VectorSpace.getMousePositionToWorldPosition(details.globalPosition.dx, details.globalPosition.dy, box2d));
    // levelSystem.setUpTestLevel();
  }

  Sprite sprite;
  Sprite terrainSprite;


  void _start() {
    sprite = Sprite(
      "SB30Pn.jpg",
      x: 0,
      y: 0,
      width: 1920,
      height: 1080
    );
    terrainSprite = Sprite(
      "terrain_basic.png",
    );
    levelSystem.setUpTestLevel();
    RawKeyboard.instance.addListener((RawKeyEvent e) {
      // final bool isKeyDown = e is RawKeyDownEvent;

      // final keyLabel = e.data.logicalKey.keyLabel;

      // if (keyLabel == "a") {
      //   movingLeft = isKeyDown;
      // }

      // if (keyLabel == "d") {
      //   movingRight = isKeyDown;
      // }

      // if (keyLabel == "w") {
      //   movingUp = isKeyDown;
      // }

      // if (keyLabel == "s") {
      //   movingDown = isKeyDown;
      // }
    });
  }

  @override
  void update(double dt) {
    // if (movingLeft) {
    //   x -= 100 * dt;
    // } else if (movingRight) {
    //   x += 100 * dt;
    // }

    // if (movingUp) {
    //   y -= 100 * dt;
    // } else if (movingDown) {
    //   y += 100 * dt;
    // }
    // print(DateTime.now());
    levelSystem.update();
    rootSystem.execute();
    // rootSystem.cleanup();
  }

  @override
  void render(Canvas canvas) {
    renderSystem.render(canvas);
    // canvas.drawColor(Colors.transparent, BlendMode.clear);
    // canvas.drawRect(Rect.fromLTWH(x, y, 100, 100), paint);
    // // em.entities
    // Group group = em.group(all: [SpriteComp]);
    // print(group.entities?.length ?? "null");
    // for(Entity e in group.entities) {
    //   e.get<SpriteComp>().sprite.render(canvas);
    // }
    // double span = 90.0; /// / box2d.viewport.scale;
    // B2D.Vector2 center = box2d.viewport.getWorldToScreen(B2D.Vector2(0, 0));
    // Group terrainGroup = em.group(all: [TerrainComp]);
    // for(Entity e in terrainGroup.entities) {
    //   // print("update terrain");
    //   TerrainComp comp = e.get<TerrainComp>();
    //   for(int y = 0; y < comp.maps.length; y++) {
    //     double positionY = span / 1.5 * (y - 5) + center.y;
    //     bool isOffset = y % 2 == 0;
    //     for(int x = 0; x < comp.maps.length; x++) {
    //       double positionX = span * (x - 5) + center.x + (isOffset ? 45 : 0);
    //       terrainSprite.renderCentered(canvas, Position(positionX, positionY));
    //     }
    //   }
    // }

    // Group group = em.group(all: [AnimatableComp]);
    // for(Entity e in group.entities) {
    //   if(e.has(PropertyComp)) e.get<AnimatableComp>().currentAnimation.value.execute(canvas, e.get<PropertyComp>());
    // }

    // Group colGroup = em.group(all: [CollisionComp]);
    // for(Entity e in colGroup.entities) {
    //   Box2dDebuggerRender.getInstance().render(canvas, e.get<CollisionComp>().body, box2d.viewport);
    // }
    

    // sprite.render(canvas);

    // canvas.drawImageRect(image, src, dst, overridePaint ?? paint);
    rootSystem.cleanup();
  }
}
