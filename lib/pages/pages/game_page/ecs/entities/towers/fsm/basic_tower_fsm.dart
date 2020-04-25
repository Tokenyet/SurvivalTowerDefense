import 'package:state_machine/state_machine.dart';

class BasicTowerFSM {
  StateMachine tower;
  State isConstructing;
  State isIdle; // no enemy for attack tower, no resource for resource tower
  State isAttack;
  State isDying;
  State isDead;
  StateTransition buildComplete;
  StateTransition findTarget;
  StateTransition missTarget;
  StateTransition exhaustHp;
  StateTransition goDead;

  BasicTowerFSM() {
    tower = StateMachine("tower");
    isConstructing = tower.newState("constructing");
    isIdle = tower.newState("idle");
    isAttack = tower.newState("attack");
    isDying = tower.newState("dying");
    isDead = tower.newState("dead");

    buildComplete = tower.newStateTransition('buildComplete', [isConstructing], isIdle);
    findTarget = tower.newStateTransition('findTarget', [isIdle], isAttack);
    missTarget = tower.newStateTransition('missTarget', [isAttack], isIdle);
    exhaustHp = tower.newStateTransition('exhaustHp', [isIdle, isAttack], isDying);
    goDead = tower.newStateTransition('goDead', [isDying], isDead);

    tower.start(isConstructing); 
  }


}