import 'package:entitas_ff/entitas_ff.dart';

enum TerrainState {
  UNPLANTED,
  UNPLANTED_SELECT,
  PLANTED,
  PLANTED_SELECT,
}
class TerrainComp extends Component {
  final TerrainState state;
  final Entity ocupiedEntity;
  // final bool isHomable;
  TerrainComp(this.ocupiedEntity, [
    this.state = TerrainState.UNPLANTED,
  ]);

  TerrainComp copyWith({
    Entity ocupiedEntity,
    TerrainState state
  }) {
    return TerrainComp(
      ocupiedEntity ?? this.ocupiedEntity,
      state ?? this.state
    );
  }
}