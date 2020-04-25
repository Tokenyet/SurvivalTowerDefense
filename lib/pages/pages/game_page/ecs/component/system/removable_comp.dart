import 'package:entitas_ff/entitas_ff.dart';

// rendersystem handle fadeout
// recyclesystem handle destroy
class RemovableComp extends Component {
  final double delayMillis;
  final bool isFadeOut;
  final DateTime timestamp;
  final bool isKeepTerrain;

  RemovableComp({
    this.delayMillis,
    this.isFadeOut,
    this.isKeepTerrain = false
  }) :
    this.timestamp = DateTime.now();
}