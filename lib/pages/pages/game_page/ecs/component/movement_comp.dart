import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:entitas_ff/entitas_ff.dart';

class MovementComp extends Component {
  final Vector2D velocity;

  MovementComp({
    this.velocity
  });

  copyWith({
    Vector2D velocity
  }) {
    return MovementComp(
      velocity: velocity ?? this.velocity
    );
  }
}