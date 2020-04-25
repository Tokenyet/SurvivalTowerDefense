import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:DarkSurviver/pages/pages/game_page/ecs/component/events/events/system_event.dart';

abstract class ResourcePanelEvent extends Equatable {
}

class AddMoneyEvent extends ResourcePanelEvent {
  final int value;

  AddMoneyEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UseMoneyEvent extends ResourcePanelEvent {
  final int value;

  UseMoneyEvent(this.value);
  @override
  List<Object> get props => [value];
}

class AddPowerEvent extends ResourcePanelEvent {
  final int value;

  AddPowerEvent(this.value);

  @override
  List<Object> get props => [value];
}

class UsePowerEvent  extends ResourcePanelEvent {
  final int value;

  UsePowerEvent(this.value);

  @override
  List<Object> get props => [value];
}


class ResourcePanelState extends Equatable {
  final int power;
  final int money;
  ResourcePanelState({
    this.power,
    this.money,
  });

  @override
  List<Object> get props => [power, money];

  ResourcePanelState copyWith({
    int power,
    int money,
  }) {
    return ResourcePanelState(
      power: power ?? this.power,
      money: money ?? this.money,
    );
  }
}

class ResourcePanelBloc extends Bloc<ResourcePanelEvent, ResourcePanelState> {
  @override
  ResourcePanelState get initialState => ResourcePanelState(money: 0, power: 0);

  @override
  Stream<ResourcePanelState> mapEventToState(ResourcePanelEvent event) async* {
    if(event is AddMoneyEvent) {
      yield state.copyWith(money: state.money + event.value);
    } else if(event is AddPowerEvent) {
      yield state.copyWith(power: state.power + event.value);
    } else if(event is UseMoneyEvent) {
      yield state.copyWith(money: state.money - event.value);
    } else if(event is UsePowerEvent) {
      yield state.copyWith(power: state.power - event.value);
    }
  }

}

