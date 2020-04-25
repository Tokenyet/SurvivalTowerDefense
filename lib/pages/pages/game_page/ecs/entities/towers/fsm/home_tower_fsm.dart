import 'package:state_machine/state_machine.dart';

class HomeTowerFSM {
  StateMachine tower;
  State isUnactive; // dark shiny
  State isActiving; // light to top
  State isConstructing; // full light a litte time
  State isIdle; // light shiny
  State isAttack;
  State isDying;
  State isDead;
  StateTransition backToUnactive;
  StateTransition triggerActive;
  StateTransition triggerToConstructing;
  StateTransition buildComplete;
  StateTransition findTarget;
  StateTransition missTarget;
  StateTransition exhaustHp;
  StateTransition goDead;

  HomeTowerFSM() {
    tower = StateMachine("tower");
    isUnactive = tower.newState("unactive");
    isActiving = tower.newState("activing");
    isConstructing = tower.newState("constructing");
    isIdle = tower.newState("idle");
    isAttack = tower.newState("attack");
    isDying = tower.newState("dying");
    isDead = tower.newState("dead");

    triggerActive = tower.newStateTransition('triggerActive', [isUnactive], isActiving);
    backToUnactive = tower.newStateTransition('backToUnactive', [isActiving], isUnactive);
    triggerToConstructing = tower.newStateTransition('triggerToConstructing', [isActiving], isConstructing);
    buildComplete = tower.newStateTransition('buildComplete', [isConstructing], isIdle);
    findTarget = tower.newStateTransition('findTarget', [isIdle], isAttack);
    missTarget = tower.newStateTransition('missTarget', [isAttack], isIdle);
    exhaustHp = tower.newStateTransition('exhaustHp', [isIdle, isAttack], isDying);
    goDead = tower.newStateTransition('goDead', [isDying], isDead);

    tower.start(isUnactive); 
  }


}