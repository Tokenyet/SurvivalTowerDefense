import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flame/flame.dart';

abstract class GameStartScreenEvent extends Equatable {
}

class InitEvent extends GameStartScreenEvent {
  @override
  List<Object> get props => [];
}

class StartGameEvent extends GameStartScreenEvent {
  @override
  List<Object> get props => [];
}

class QuitEvent extends GameStartScreenEvent {
  @override
  List<Object> get props => [];
}

class RestartMenuEvent extends GameStartScreenEvent {
  @override
  List<Object> get props => [];
}

abstract class GameStartScreenState extends Equatable {
} 

class UninitializedState extends GameStartScreenState {
  @override
  List<Object> get props => [];
}

class SplashState extends GameStartScreenState {
  final double progression;
  SplashState({
    this.progression,
  });
  @override
  List<Object> get props => [progression];
}

class MenuState extends GameStartScreenState {
  @override
  List<Object> get props => [];
}

class GameState extends GameStartScreenState {
  @override
  List<Object> get props => [];
}

class GameStartBloc extends Bloc<GameStartScreenEvent, GameStartScreenState> {
  @override
  GameStartScreenState get initialState => UninitializedState();

  @override
  Stream<GameStartScreenState> mapEventToState(GameStartScreenEvent event) async* {
    if(event is InitEvent) {
      List<Future> imagesLoaderFuture = [
        Flame.images.load("3d.png"),
        Flame.images.load("SB30Pn.jpg"),
        Flame.images.load("fingerprint.png"),
        Future.delayed(const Duration(seconds: 1)),
        Future.delayed(const Duration(seconds: 2)),
        Future.delayed(const Duration(seconds: 3)),
        Future.delayed(const Duration(seconds: 1)),
        Future.delayed(const Duration(seconds: 4)),
        Future.delayed(const Duration(seconds: 5)),
      ];
      yield SplashState(progression: 0);
      for(int i = 0; i < imagesLoaderFuture.length; i++) {
        await imagesLoaderFuture[i];
        yield SplashState(progression: (i + 1).toDouble() / imagesLoaderFuture.length.toDouble());
      }
      // yield MenuState();
    } else if(event is StartGameEvent) {
      yield GameState();
    } else if(event is QuitEvent) {
      exit(0);
    } else if(event is RestartMenuEvent) {
      yield MenuState();
    }
  }
}