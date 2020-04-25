import 'dart:async';

import 'package:DarkSurviver/pages/_bloc/game_start_bloc.dart' as SB;
import 'package:flutter/material.dart';

class GameClearScreen extends StatefulWidget {
  final void Function() onComplete;
  GameClearScreen({
    Key key,
    this.onComplete,
  }) : super(key: key);

  @override
  _GameClearScreenState createState() => _GameClearScreenState();
}

class _GameClearScreenState extends State<GameClearScreen> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> gameOverTextTranslationAnimation;
  @override
  void initState() {
    animationController = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    gameOverTextTranslationAnimation = TweenSequence<double>([
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0.0, end: 0.5).chain(CurveTween(curve: Curves.easeIn)), weight: 30),
      TweenSequenceItem<double>(tween: ConstantTween<double>(0.5), weight: 40),
      TweenSequenceItem<double>(tween: Tween<double>(begin: 0.5, end: 1.0), weight: 30),
    ]).animate(animationController);

    animationController.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        widget.onComplete();
      }
    });
    animationController.forward();

    super.initState();
  }

  @override
  void dispose() { 
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AnimatedBuilder(
        animation: gameOverTextTranslationAnimation,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(MediaQuery.of(context).size.width * (1.0 - gameOverTextTranslationAnimation.value), 40),
            child: Text("You Win...", style: Theme.of(context).textTheme.title.copyWith(color: Colors.white),),
          );
        }
      ),
    );
  }
}