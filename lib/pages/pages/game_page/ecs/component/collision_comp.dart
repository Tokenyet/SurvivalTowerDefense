import 'package:entitas_ff/entitas_ff.dart';
import 'package:flame/box2d/box2d_component.dart';
import 'package:box2d_flame/box2d.dart';

class CollisionComp extends Component {
  final Body body;
  CollisionComp(
    this.body
  );
}