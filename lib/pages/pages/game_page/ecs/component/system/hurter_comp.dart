import 'package:entitas_ff/entitas_ff.dart';

class HurtInfo {
  final Entity attacker;
  final Entity target;
  final int damage;
  HurtInfo({
    this.attacker,
    this.target,
    this.damage,
  });
}

class HurterComp extends Component {
  final HurtInfo hurtInfo;

  HurterComp({
    this.hurtInfo,
  });
}
