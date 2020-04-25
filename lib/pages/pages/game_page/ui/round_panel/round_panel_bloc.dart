import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

abstract class RoundPanelEvent extends Equatable {}

class SyncRoundEvent extends RoundPanelEvent {
  final int currentSeconds;
  final int maximumSeconds;
  final List<double> roundTimeline;
  final double roundProgress;
  final int level;
  SyncRoundEvent({
    this.currentSeconds,
    this.maximumSeconds,
    this.roundTimeline,
    this.roundProgress,
    this.level,
  });
  @override
  List<Object> get props => [
    this.currentSeconds,
    this.maximumSeconds,
    this.roundTimeline,
    this.roundProgress,
    this.level,
  ];
}

class SyncWaitEvent extends RoundPanelEvent {
  final int currentSeconds;
  final int maximumSeconds;
  SyncWaitEvent({
    this.currentSeconds,
    this.maximumSeconds,
  });
  @override
  List<Object> get props => [
    this.currentSeconds,
    this.maximumSeconds,
  ];
}

class HideEvent extends RoundPanelEvent {
  @override
  List<Object> get props => [];
}

abstract class RoundPanelState extends Equatable {}

class EmptyState extends RoundPanelState {
  @override
  List<Object> get props => [];
}

class RoundState extends RoundPanelState {
  final int currentSeconds;
  final int maximumSeconds;
  final List<double> roundTimeline;
  final double roundProgress;
  final int level;
  RoundState({
    this.currentSeconds,
    this.maximumSeconds,
    this.roundTimeline,
    this.roundProgress,
    this.level,
  });
  @override
  List<Object> get props => [
    currentSeconds,
    maximumSeconds,
    roundTimeline,
    roundProgress,
    level,
  ];

  RoundState copyWith({
    int currentSeconds,
    int maximumSeconds,
    List<double> roundTimeline,
    double roundProgress,
    int level,
  }) {
    return RoundState(
      currentSeconds: currentSeconds ?? this.currentSeconds,
      maximumSeconds: maximumSeconds ?? this.maximumSeconds,
      roundTimeline: roundTimeline ?? this.roundTimeline,
      roundProgress: roundProgress ?? this.roundProgress,
      level: level ?? this.level,
    );
  }
}

class WaitState extends RoundPanelState {
  final int currentSeconds;
  final int maximumSeconds;
  WaitState({
    this.currentSeconds,
    this.maximumSeconds,
  });
  @override
  List<Object> get props => [currentSeconds, maximumSeconds];

  WaitState copyWith({
    int currentSeconds,
    int maximumSeconds,
  }) {
    return WaitState(
      currentSeconds: currentSeconds ?? this.currentSeconds,
      maximumSeconds: maximumSeconds ?? this.maximumSeconds,
    );
  }
}


class RoundPanelBloc extends Bloc<RoundPanelEvent, RoundPanelState> {
  @override
  RoundPanelState get initialState => EmptyState();

  @override
  Stream<RoundPanelState> mapEventToState(RoundPanelEvent event) async* {
    // RoundState currentState = state;
    if(event is HideEvent) {
      yield EmptyState();
    } else if(event is SyncRoundEvent) {
      yield RoundState(
        currentSeconds: event.currentSeconds,
        maximumSeconds: event.maximumSeconds,
        roundTimeline: event.roundTimeline,
        roundProgress: event.roundProgress,
        level: event.level
      );
    } else if(event is SyncWaitEvent) {
      yield WaitState(
        currentSeconds: event.currentSeconds,
        maximumSeconds: event.maximumSeconds,
      );
    }
  }
}