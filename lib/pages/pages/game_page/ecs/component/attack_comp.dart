import 'package:entitas_ff/entitas_ff.dart';

class Attack {
  int power;
  Attack({
    this.power,
  });
}

class AttackComp extends Component {
  final Attack attack;
  AttackComp({
    int power = 2,
  }) :
    attack = Attack(power: power);
}