import 'package:state_machine/state_machine.dart';

class BasicEnemyFSM {
  StateMachine enemy;
  State isWalk;
  State isAttack;
  State isDying;
  State isDead;
  StateTransition onTarget;
  StateTransition goToNearestTarget;
  StateTransition exhaustHp;
  StateTransition dying;

  BasicEnemyFSM() {
    enemy = StateMachine("enemy");
    isWalk = enemy.newState("walk");
    isAttack = enemy.newState("attack");
    isDying = enemy.newState("dying");
    isDead = enemy.newState("dead");

    onTarget = enemy.newStateTransition('onTarget', [isWalk], isAttack);
    goToNearestTarget = enemy.newStateTransition('goToNearestTarget', [isAttack], isWalk);
    exhaustHp = enemy.newStateTransition('exhaustHp', [isWalk, isAttack], isDying);
    dying = enemy.newStateTransition('dying', [isDying], isDead);

    enemy.start(isWalk); 
  }


}