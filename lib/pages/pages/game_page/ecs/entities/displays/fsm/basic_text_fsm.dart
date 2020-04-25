import 'package:state_machine/state_machine.dart';

class BasicTextFSM {
  StateMachine text;
  State isJustAppear;
  State isAppear;
  State isJustDead;
  State isDead;
  StateTransition triggerToAppear;
  StateTransition triggerToDying;
  StateTransition triggerToDead;

  BasicTextFSM() {
    text = StateMachine("text");
    isJustAppear = text.newState("justAppear");
    isAppear = text.newState("appear");
    isJustDead = text.newState("justDead");
    isDead = text.newState("dead");

    triggerToAppear = text.newStateTransition('triggerToAppear', [isJustAppear], isAppear);
    triggerToDying = text.newStateTransition('triggerToDying', [isAppear], isJustDead);
    triggerToDead = text.newStateTransition('triggerToDead', [isJustDead], isDead);

    text.start(isJustAppear); 
  }


}