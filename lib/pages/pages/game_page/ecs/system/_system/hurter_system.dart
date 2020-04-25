
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/attack_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/health_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/hurter_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/component/system/removable_comp.dart';
import 'package:DarkSurviver/pages/pages/game_page/ecs/system/collision_system.dart';
import 'package:entitas_ff/entitas_ff.dart';

class HurterSystem extends ExecuteSystem {
  Box2D box2d;
  EntityManager em;
  HurterSystem(Box2D box2d, EntityManager em) {
    this.box2d = box2d;
    this.em = em;
  }

  @override
  execute() {
    Group hurterGroup = em.group(all: [HurterComp]);
    for(Entity e in hurterGroup.entities) {
      HurterComp hurterComp = e.get<HurterComp>();
      doDamage(hurterComp.hurtInfo);
      e.destroy();
      // immediately delete entity
    }
  }

  void doDamage(HurtInfo hurtInfo) {
    Entity emitter = hurtInfo.attacker;
    Entity victim = hurtInfo.target;
    int damage = hurtInfo.damage;

    if(emitter != null && !emitter.isAlive) return;
    if(!victim.isAlive) return;
    if(damage == 0) return;

    // if(!emitter.has(AttackComp)) return;
    if(!victim.has(HealthComp)) return;
    if(victim.has(RemovableComp)) return;

    int realDamage = damage ?? emitter?.get<AttackComp>()?.attack?.power ?? 0;
    victim.get<HealthComp>().health.hurt(realDamage);
    // if(victim.get<HealthComp>().health.currentHp == 0) victim + RemovableComp();
  }

}