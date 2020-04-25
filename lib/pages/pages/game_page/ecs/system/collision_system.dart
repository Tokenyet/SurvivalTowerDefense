import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/anim_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/collision_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/enemy_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/input_mouse_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/movement_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/property_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/tower_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/box2d_filter.dart';
import 'package:DarkSurviver/utilities/vector_2d.dart';
// import 'package:DarkSurviver/pages/ecs/component/sprite_comp.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/rendering.dart';
import 'package:box2d_flame/box2d.dart' as B2D;

class Box2D extends Box2DComponent {
  final EntityManager em;
  Box2D(this.em) : super(dimensions: Size(1920, 1080),scale: 4.0, gravity: 0.0);

  @override
  void initializeWorld() {
  }

  Entity getNearestTowerEntity(Vector2D pos) {
    Group towers = em.group(all: [TowerComp]);
    double minDistance = 99999999;
    Entity nearestTower;
    for(Entity e in towers.entities) {
      Vector2D towerWorldPos = Vector2D.fromVector2(e.get<CollisionComp>().body.position);
      if(minDistance > (towerWorldPos - pos).length) {
        minDistance = (towerWorldPos - pos).length;
        nearestTower = e;
      }
    }
    return nearestTower;
  }
}

// class CollisionFilter extends B2D.ContactFilter {
//   @override
//   bool shouldCollide(B2D.Fixture fixtureA, B2D.Fixture fixtureB) {
//     B2D.Filter filterA = fixtureA.getFilterData();
//     B2D.Filter filterB = fixtureB.getFilterData();

//     if (filterA.groupIndex == filterB.groupIndex && filterA.groupIndex != 0) {
//       return filterA.groupIndex > 0;
//     }

//     bool collide = ((filterA.maskBits & filterB.categoryBits) != 0) &&
//         ((filterA.categoryBits & filterB.maskBits) != 0);
//     return collide;
//   }
// }

class CollisionListener extends B2D.ContactListener {
  @override
  void beginContact(B2D.Contact contact) {
    B2D.Fixture fixtureA = contact.fixtureA;
    B2D.Fixture fixtureB = contact.fixtureB;
    dynamic entityA = contact.fixtureA.getBody().userData;
    dynamic entityB = contact.fixtureB.getBody().userData;

    if(fixtureA.isSensor() && fixtureB.isSensor()) return;

    if(fixtureA.isSensor()) { // only sensor get notified
      if(entityA is Entity && entityB is Entity) {
        if(entityA.has(AiComp)) {
          print("sensor A");
          entityA.get<AiComp>().core.onCollision(entityA, entityB);
          return;
        }
      }
    }

    if(fixtureB.isSensor()) { // only sensor get notified
      if(entityA is Entity && entityB is Entity) {
        if(entityB.has(AiComp)) {
          print("sensor B");
          entityB.get<AiComp>().core.onCollision(entityB, entityA);
          return;
        }
      }
    }
    
    if(entityA is Entity && entityB is Entity) {
      Entity tower = entityA.has(TowerComp) ? entityA : entityB.has(TowerComp) ? entityB : null;
      Entity enemy = entityA.has(EnemyComp) ? entityA : entityB.has(EnemyComp) ? entityB : null;
      if(tower == null || enemy == null) return;
      if(tower.has(AiComp)) tower.get<AiComp>().core.onCollision(tower, enemy);
      if(enemy.has(AiComp)) enemy.get<AiComp>().core.onCollision(enemy, tower);
    }
  }

  @override
  void endContact(B2D.Contact contact) {
    B2D.Fixture fixtureA = contact.fixtureA;
    B2D.Fixture fixtureB = contact.fixtureB;
    dynamic entityA = contact.fixtureA.getBody().userData;
    dynamic entityB = contact.fixtureB.getBody().userData;

    if(fixtureA.isSensor() && fixtureB.isSensor()) return;

    if(fixtureA.isSensor()) { // only sensor get notified
      if(entityA is Entity && entityB is Entity) {
        if(entityA.has(AiComp)) {
          entityA.get<AiComp>().core.onCollisionLeave(entityA, entityB);
          return;
        }
      }
    }

    if(fixtureB.isSensor()) { // only sensor get notified
      if(entityA is Entity && entityB is Entity) {
        if(entityB.has(AiComp)) {
          entityB.get<AiComp>().core.onCollisionLeave(entityB, entityA);
          return;
        }
      }
    }

    if(entityA is Entity && entityB is Entity) {
      Entity tower = entityA.has(TowerComp) ? entityA : entityB.has(TowerComp) ? entityB : null;
      Entity enemy = entityA.has(EnemyComp) ? entityA : entityB.has(EnemyComp) ? entityB : null;
      if(tower == null || enemy == null) return;
      if(tower.has(AiComp)) tower.get<AiComp>().core.onCollisionLeave(tower, enemy);
      if(enemy.has(AiComp)) enemy.get<AiComp>().core.onCollisionLeave(enemy, tower);
    }
  }

  @override
  void postSolve(B2D.Contact contact, B2D.ContactImpulse impulse) {
  }

  @override
  void preSolve(B2D.Contact contact, B2D.Manifold oldManifold) {
  }

}

class CollisionSystem extends EntityManagerSystem implements ExecuteSystem {
  final Box2DComponent _box2dComponent;
  CollisionSystem(
    Box2D box2d
  ):
    _box2dComponent = box2d {
      box2d.world.setContactListener(CollisionListener());
      // box2d.world.setContactFilter(filter)
  }
  int _timestamp;


  @override
  execute() {
    Group collisionGroup = entityManager.group(all: [CollisionComp]);
    // Group movementGroup = entityManager.group(all: [MovementComp]);
    // final InputMouseComp inputComp = entityManager.getUnique<InputMouseComp>();
    // final SpriteComp spriteComp = entityManager.getUnique<SpriteComp>();
    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    int difference = time.millisecondsSinceEpoch - _timestamp;
    // int iteration = (time.millisecondsSinceEpoch - _timestamp) ~/ 16;
    // _timestamp += iteration * 16
    _box2dComponent.update(difference.toDouble() / 1000.0);
    _timestamp = time.millisecondsSinceEpoch;
    // for(Entity movementEntity in movementGroup.entities) {
    //   movementEntity.remove<MovementComp>();
    // }

    for(Entity e in collisionGroup.entities) {
      // print(DateTime.now());
      if(e.has(PropertyComp)) {
        double centerX = e.get<CollisionComp>().body.position.x;
        double centerY = e.get<CollisionComp>().body.position.y;
        double angle = e.get<CollisionComp>().body.getAngle();
        // print(centerX);
        // print(centerY);
        B2D.Vector2 screenPos = _box2dComponent.viewport.getWorldToScreen(B2D.Vector2(centerX, centerY));
        PropertyComp originalProp = e.get<PropertyComp>();
        e.remove<PropertyComp>();
        e + originalProp.copyWith(x: screenPos.x, y: screenPos.y, angle: angle);
        // if(e.has(MovementComp)) {
        //   MovementComp movementComp = e.get<MovementComp>();
        //   e.remove<MovementComp>();
        //   e + movementComp.copyWith(velocity: Vector2D.fromVector2(e.get<CollisionComp>().body.linearVelocity));
        // }
      }
    }
  }


}