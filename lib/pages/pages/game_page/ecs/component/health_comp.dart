import 'package:entitas_ff/entitas_ff.dart';
import 'dart:math' as Math;

class Health {
  int maximumHp;
  int currentHp;
  int shield;
  bool isDisplay;
  Health({
    this.maximumHp,
    this.currentHp,
    this.shield,
    this.isDisplay = true
  });

  void hurt(int pureDamage) {
    currentHp -= Math.max(pureDamage - shield, 0);
    if(currentHp < 0) currentHp = 0;
  }
}

class HealthComp extends Component {
  final Health health;
  HealthComp({
    int maxHp = 10,
    int currentHp = 10,
    int shield = 0,
    bool isDisplay = true
  }) :
    assert(maxHp >= currentHp),
    health = Health(currentHp: currentHp, maximumHp: maxHp, shield: shield, isDisplay: isDisplay);
}