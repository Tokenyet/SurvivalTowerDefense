import 'package:entitas_ff/entitas_ff.dart';

class PropertyComp extends Component {
  final double x;
  final double y;
  final double width;
  final double height;
  final double scale;
  final double angle; // radian

  PropertyComp({
    this.x,
    this.y,
    this.width,
    this.height,
    this.scale,
    this.angle
  });

  copyWith({
    double x,
    double y,
    double width,
    double height,
    double scale,
    double angle
  }) {
    return PropertyComp(
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      scale: scale ?? this.scale,
      angle: angle ?? this.angle
    );
  }
}