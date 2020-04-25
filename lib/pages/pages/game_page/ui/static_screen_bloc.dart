import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

enum StaticScreenEvent {
  EmptyScreen,
  GameOverScreen,
  GameWinScreen,
}

class StaticScreenState extends Equatable {
  final bool isGameOverScreen;
  final bool isGameWinScreen;
  StaticScreenState({
    this.isGameOverScreen = false,
    this.isGameWinScreen = false,
  });
  
  @override
  List<Object> get props => [
    isGameOverScreen,
    isGameWinScreen
  ];
}

class StaticScreenBloc extends Bloc<StaticScreenEvent, StaticScreenState> {
  @override
  StaticScreenState get initialState => StaticScreenState();

  @override
  Stream<StaticScreenState> mapEventToState(StaticScreenEvent event) async* {
    if(event == StaticScreenEvent.GameOverScreen) {
      yield StaticScreenState(
        isGameWinScreen: false,
        isGameOverScreen: true,
      );
    } else if(event == StaticScreenEvent.GameWinScreen) {
      yield StaticScreenState(
        isGameWinScreen: true,
        isGameOverScreen: false,
      );
    } else {
      yield StaticScreenState(
        isGameWinScreen: false,
        isGameOverScreen: false,
      );
    }
  }

}

