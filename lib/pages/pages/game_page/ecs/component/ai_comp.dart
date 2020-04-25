import 'package:entitas_ff/entitas_ff.dart';

abstract class AiCore {
  AiCore();

  void update(double delta);

  void onTap(Entity self, double x, double y);

  void onTapUp(Entity self, double x, double y);

  void onCollision(Entity self, Entity target);

  void onCollisionLeave(Entity self, Entity target);
}

class AiBasicCore extends AiCore {
  final void Function(double delta) _update;
  final void Function(Entity self, double x, double y) _onTap;
  final void Function(Entity self, double x, double y) _onTapUp;
  final void Function(Entity self, Entity target) _onCollision;
  final void Function(Entity self, Entity target) _onCollisionLeave;
  AiBasicCore({
    void Function(double delta) update,
    void Function(Entity self, double x, double y) onTap,
    void Function(Entity self, double x, double y) onTapUp,
    void Function(Entity self, Entity target) onCollision,
    void Function(Entity self, Entity target) onCollisionLeave
  }) :
    this._update = update,
    this._onTap = onTap,
    this._onTapUp = onTapUp,
    this._onCollision = onCollision,
    this._onCollisionLeave = onCollisionLeave;

  void update(double delta) {
    if(_update != null) this._update(delta);
  }
  void onTap(Entity self, double x, double y) {
    if(_onTap != null) this._onTap(self, x, y);
  }
  void onTapUp(Entity self, double x, double y) {
    if(_onTapUp != null) this._onTapUp(self, x, y);
  }

  void onCollision(Entity self, Entity target) {
    if(_onCollision != null) this._onCollision(self, target);
  }

  void onCollisionLeave(Entity self, Entity target) {
    if(_onCollisionLeave != null) this._onCollisionLeave(self, target);
  }
}

class AiComp extends Component {
  final AiCore core;
  AiComp(this.core);
}