import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';

abstract class FaderEvent extends Equatable {
}

class InitEvent extends FaderEvent {
  final AnimationController controller;
  InitEvent({
    this.controller,
  });
  @override
  List<Object> get props => [controller];
}

/// Use fadeIn event to init screen
class FadeInEvent extends FaderEvent {
  final double completeTime;
  final void Function() onComplete;
  final int delayedMillis;

  FadeInEvent({
    this.completeTime = 0.8, // 1 to 0
    this.onComplete,
    this.delayedMillis = 0
  });

  @override
  List<Object> get props => [
    completeTime,
    onComplete
  ];
}

/// Use fadeout event to leave screen
class FadeOutEvent extends FaderEvent {
  final double completeTime; // trans to black // 0 to 1
  final void Function() onComplete;
  final int delayedMillis;

  FadeOutEvent({
    this.completeTime = 0.8,
    this.onComplete,
    this.delayedMillis = 0
  });

  @override
  List<Object> get props => [
    completeTime,
    onComplete
  ];
}

abstract class FaderState extends Equatable {
}

class UninitalizedState extends FaderState {
  @override
  List<Object> get props => [];
}

class InitializedState extends FaderState {
  final AnimationController controller;
  InitializedState({
    this.controller,
  });
  @override
  List<Object> get props => [controller];
}

class FaderBloc extends Bloc<FaderEvent, FaderState> {
  @override
  FaderState get initialState => UninitalizedState();

  AnimationController controller;
  FaderBloc();

  bool isCalled = false;

  Function _fadeInInstance;
  Function _fadeOutInstance;

  @override
  Stream<FaderState> mapEventToState(FaderEvent event) async* {
    if(event is InitEvent) {
      this.controller = event.controller;
      yield InitializedState(controller: event.controller);
    } else if(event is FadeInEvent) {
      if(controller.isAnimating) return;
      controller.removeListener(_fadeInInstance);
      controller.removeListener(_fadeOutInstance);
      controller.value = 1.0;
      controller.reverse();
      isCalled = false;
      await Future.delayed(Duration(milliseconds: event.delayedMillis)); // might cause some issue
      _fadeInInstance = () => _fadeIn(event);
      controller.addListener(_fadeInInstance);
    } else if(event is FadeOutEvent) {
      if(controller.isAnimating) return;
      controller.removeListener(_fadeInInstance);
      controller.removeListener(_fadeOutInstance);
      controller.reset();
      controller.forward();
      isCalled = false;
      await Future.delayed(Duration(milliseconds: event.delayedMillis)); // might cause some issue
      _fadeOutInstance = () => _fadeOut(event);
      controller.addListener(_fadeOutInstance);
    }
  }

  void _fadeIn(FadeInEvent event) {
    if(isCalled) return;        
    if(controller.value < event.completeTime) {
      if(event.onComplete != null) event.onComplete();
      isCalled = true;
    }
    if(controller.isCompleted) if(event.onComplete != null) event.onComplete();
  }

  void _fadeOut(FadeOutEvent event) {
    if(isCalled) return;        
    if(controller.value > event.completeTime) {
      if(event.onComplete != null) event.onComplete();
      isCalled = true;
    }
    if(controller.isCompleted) if(event.onComplete != null) event.onComplete();
  }
}

class Fader extends StatefulWidget {
  final FaderBloc fadeBloc;
  final Widget child;
  final int fadeInDelay;
  Fader({Key key, this.fadeBloc, this.child, this.fadeInDelay = 0}) : super(key: key);

  @override
  _FaderState createState() => _FaderState();
}

class _FaderState extends State<Fader> with SingleTickerProviderStateMixin {
  AnimationController _controller;
  FaderBloc _faderBloc;
  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: Duration(seconds: 1));
    _controller.addListener(() {
      // print("Screen refresh: ${_controller.value}");
      setState((){});
    });
    _controller.value = 1.0;
    _faderBloc = widget.fadeBloc;
    _faderBloc.add(InitEvent(controller: _controller));
    _faderBloc.add(FadeInEvent(delayedMillis: widget.fadeInDelay));
    // _controller.forward();
    super.initState();
  }

  @override
  void dispose() { 
    _controller.dispose();
    // _faderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // _faderBloc.add(FadeInEvent());
    // _controller.forward();
    // print("_controller.isDismissed: ${_controller.isDismissed}");
    // print("_controller.isCompleted: ${_controller.isCompleted}");
    // print("_controller.isAnimating: ${_controller.isAnimating}");
    return Stack(
      children: <Widget>[
        RepaintBoundary(
          child: widget.child,
        ),
        Positioned.fill(
          child: IgnorePointer(
            ignoring: _controller.isDismissed || _controller.isCompleted,
            child: Container(
              color: Colors.black.withOpacity(_controller.value),
            )
          )
        )
      ],
    );
  }
}