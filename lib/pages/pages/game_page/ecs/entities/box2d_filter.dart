import 'package:box2d_flame/box2d.dart' as B2D;

enum Box2DFilter {
  Default,
  Detector,
  Tower,
  Enemy,
}

enum FilterType {
  Tower,
  TowerDetector,
  Enemy,
}

extension Box2dFilterExtension on Box2DFilter {
  int get bits {
    return 1 << (this.index + 1);
  }
}

class Bodx2dFilterBits {
  static B2D.Filter bits(FilterType type) {
    B2D.Filter filter = B2D.Filter();
    switch(type) {
      case FilterType.TowerDetector:
        return filter
          ..categoryBits = Box2DFilter.Detector.bits
          ..maskBits = Box2DFilter.Enemy.bits;
      case FilterType.Tower:
        return filter
          ..categoryBits = Box2DFilter.Tower.bits
          ..maskBits = Box2DFilter.Enemy.bits;
      case FilterType.Enemy:
        return filter
          ..categoryBits = Box2DFilter.Enemy.bits
          ..maskBits = Box2DFilter.Tower.bits & Box2DFilter.Detector.bits; // Enemy should ignore when collide with Detector
    }
    return null;
  }
}