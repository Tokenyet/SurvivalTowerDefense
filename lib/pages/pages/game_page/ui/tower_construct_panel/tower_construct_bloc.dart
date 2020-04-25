import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:equatable/equatable.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/ui_managet.dart';

abstract class TowerConstructEvent extends Equatable {
}

class ShowConstructableEvent extends TowerConstructEvent {
  final Entity terrainEntity;
  final void Function(TowerType) callback;
  ShowConstructableEvent({
    this.terrainEntity,
    this.callback
  });

  @override
  List<Object> get props => [terrainEntity, callback];
}

class HideConstructableEvent extends TowerConstructEvent {
  final TowerType type;
  HideConstructableEvent([this.type]);

  @override
  List<Object> get props => [type];
}

class TowerConstructState extends Equatable {
  final Entity terrainEntity;
  final bool isEnabled;
  final void Function(TowerType) callback;

  TowerConstructState({
    this.terrainEntity,
    this.isEnabled,
    this.callback
  });

  @override
  List<Object> get props => [terrainEntity, isEnabled, callback];


  TowerConstructState copyWith({
    Entity terrainEntity,
    bool isEnabled,
    void Function(TowerType) callback,
  }) {
    return TowerConstructState(
      terrainEntity: terrainEntity ?? this.terrainEntity,
      isEnabled: isEnabled ?? this.isEnabled,
      callback: callback ?? this.callback,
    );
  }
}

class TowerConstructBloc extends Bloc<TowerConstructEvent, TowerConstructState> {
  @override
  TowerConstructState get initialState => TowerConstructState(isEnabled: false);

  void Function(TowerType type) emptyCallback = (TowerType type){};

  @override
  Stream<TowerConstructState> mapEventToState(TowerConstructEvent event) async* {
    if(event is ShowConstructableEvent) {
      yield state.copyWith(
        terrainEntity: event.terrainEntity,
        callback: event.callback,
        isEnabled: true
      );
    } else if(event is HideConstructableEvent) {
      print("state.callback == null: ${state.callback == null}");
      if(this.state.callback != null) this.state.callback(event.type);
      yield state.copyWith(
        terrainEntity: null,
        isEnabled: false,
        callback: emptyCallback
      );
    }
  }

}