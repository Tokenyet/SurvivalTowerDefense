import 'package:flame/position.dart';
import 'package:box2d_flame/box2d.dart' as B2D;
import 'dart:math' as Math;

import 'package:flutter/rendering.dart';

class Vector2D {
  final double x;
  final double y;
  Vector2D(
    this.x, this.y
  ) :
    assert(x != null),
    assert(y != null);

  static Vector2D get zero {
    return Vector2D(0, 0);
  }

  factory Vector2D.fromVector2(
    B2D.Vector2 vector2
  ) {
    return Vector2D(
      vector2.x,
      vector2.y
    );
  }

  factory Vector2D.fromPosition(
    Position position
  ) {
    return Vector2D(
      position.x,
      position.y
    );
  }

  factory Vector2D.fromOffset(
    Offset vector2
  ) {
    return Vector2D(
      vector2.dx,
      vector2.dy
    );
  }

  Vector2D limitVector(double distance) {
    double fullLength = length;
    return Vector2D(this.x / fullLength, this.y / fullLength) * distance;
  }

  double get length => Math.sqrt(this.x * this.x + this.y * this.y);

  double get lengthOfPower2 => this.x * this.x + this.y * this.y;

  double cross(Vector2D vec) {
    return this.x * vec.y - vec.x * this.y;
  }

  double dot(Vector2D vec) {
    return vec.x * this.x + vec.y * this.y;
  }

  Vector2D operator *(double value) {
    return Vector2D(this.x * value, this.y * value);
  }

  Vector2D operator -(Vector2D target) {
    return Vector2D(this.x - target.x, this.y - target.y);
  }
  
  Vector2D operator +(Vector2D target) {
    return Vector2D(this.x + target.x, this.y + target.y);
  }

  B2D.Vector2 toVector2() {
    return B2D.Vector2(
      x, y
    );
  }

  Position toPosition() {
    return Position(
      x,y
    );
  }

  Offset toOffset() {
    return Offset(
      x,y
    );
  }

  @override
  String toString() =>
'''Vector2: ($x, $y)''';
  
}