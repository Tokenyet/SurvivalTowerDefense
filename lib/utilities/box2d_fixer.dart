import 'package:DarkSurviver/utilities/vector_2d.dart';
import 'package:box2d_flame/box2d.dart' as B2D;

class Box2dFixer {

  // Box2d bug testPoint on CircleShape
  //     print(
  // '''
  // q: $q
  // tp: $tp
  // centerx: $centerx
  // centery: $centery
  // centerx * centerx + centery * centery <= radius * radius: ${centerx * centerx + centery * centery} <= ${radius * radius} = ${centerx * centerx + centery * centery <= radius * radius}
  // '''
  //     );
  static bool testPoint(B2D.Fixture fixture, Vector2D worldPos) {
    if(fixture.getShape() is B2D.CircleShape) {
      B2D.CircleShape circleShape = fixture.getShape() as B2D.CircleShape;
      Vector2D localPos = Vector2D.fromVector2(circleShape.p);
      Vector2D bodyWorldPos = Vector2D.fromVector2(fixture.getBody().position);
      Vector2D fixtureWorldPos = bodyWorldPos + localPos;
      double radius = circleShape.radius;

      Vector2D fastCheckVec = (worldPos - fixtureWorldPos); // prevent use .length for perfomance

      // print("Circle");
      return fastCheckVec.x * fastCheckVec.x + fastCheckVec.y * fastCheckVec.y <= radius * radius;
    }

    return fixture.testPoint(worldPos.toVector2());
  }
}