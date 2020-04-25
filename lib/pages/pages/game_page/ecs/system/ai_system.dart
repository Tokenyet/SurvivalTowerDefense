import 'package:DarkSurviver/pages/pages/game_page/ecs/component/ai_comp.dart';
import 'package:entitas_ff/entitas_ff.dart';

class AiSystem extends EntityManagerSystem implements ExecuteSystem {
  AiSystem();
  int _timestamp;
  
  @override
  execute() {
    Group aiGroup = entityManager.group(all: [AiComp]);

    DateTime time = DateTime.now();
    if(_timestamp == null) _timestamp = time.millisecondsSinceEpoch;
    double difference = (time.millisecondsSinceEpoch - _timestamp) / 1000;
    // int iteration = (time.millisecondsSinceEpoch - _timestamp) ~/ 16;
    // _timestamp += iteration * 16;
    _timestamp = time.millisecondsSinceEpoch;

    for(Entity e in aiGroup.entities) {
      e.get<AiComp>().core.update(difference);
    }

    // for(int i = 0; i < iteration; i++) {
    //   for(Entity e in entities) {
    //     final AnimatableComp animatableComp = e.get<AnimatableComp>();
    //     animatableComp.currentAnimation.value.execute();
    //   }
    // }
  }
}