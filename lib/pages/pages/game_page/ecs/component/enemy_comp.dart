import 'package:entitas_ff/entitas_ff.dart';

enum EnemyState {
  IDLE,
  WALK,
  RUN,
  ATTACK,
  DYING,
  DEAD
}
class EnemyComp extends Component {
  final EnemyState state;
  EnemyComp([this.state = EnemyState.IDLE]);

  EnemyComp copyWith({
    EnemyState state
  }) {
    return EnemyComp(
      state ?? this.state
    );
  }
}