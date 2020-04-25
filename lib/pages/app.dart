import 'package:DarkSurviver/pages/_bloc/fader_bloc.dart' as FB;
import 'package:DarkSurviver/pages/_bloc/game_start_bloc.dart' as GSB;
import 'package:DarkSurviver/pages/pages/game_page/game_screen.dart';
import 'package:DarkSurviver/pages/pages/menu_page/menu_screen.dart';
import 'package:DarkSurviver/pages/pages/spalsh_page/splash_screen.dart';
// import 'package:DarkSurviver/pages/game.dart';
// import 'package:DarkSurviver/pages/terrain_ui.dart';
// import 'package:DarkSurviver/pages/ui_managet.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // PlantUiScreen plantUiScreen = PlantUiScreen();
    // UiManager.getInstacne().init(plantUiScreen);
    return MaterialApp(
      //  home: FutureBuilder(
      //     future: Flame.images.loadAll(<String>["3d.png", "SB30Pn.jpg"]),
      //     builder: (context, asyncshot) {
      //       if(asyncshot.connectionState != ConnectionState.done) return Container();
      //       print("loaded");
      //       return Scaffold(
      //         body: Stack(
      //           children: <Widget>[
      //             MainGame().widget,
      //             plantUiScreen
      //           ],
      //         )
      //       );
      //     },
      //  )
      home: Scene(),
    );
  }
}

class Scene extends StatefulWidget {
  Scene({Key key}) : super(key: key);

  @override
  _SceneState createState() => _SceneState();
}

class _SceneState extends State<Scene> {
  GSB.GameStartBloc _sceneBloc;
  FB.FaderBloc _faderBloc;
  @override
  void initState() {
    super.initState();
    _sceneBloc = GSB.GameStartBloc();
    _sceneBloc.add(GSB.InitEvent());
    _faderBloc = FB.FaderBloc();
  }

  @override
  void dispose() { 
    _sceneBloc.close();
    _faderBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GSB.GameStartBloc, GSB.GameStartScreenState>(
      bloc: _sceneBloc,
      listener: (context, state) {
        if(state is GSB.SplashState) {
          if(state.progression == 1.0) {
            print("start fade out");
            _faderBloc.add(FB.FadeOutEvent(onComplete: () {
              print("callback");
              _sceneBloc.add(GSB.RestartMenuEvent());
            },));
          }
        }
      },
      builder: (context, state) {
        if(state is GSB.SplashState) {
          return FB.Fader(
            key: Key("Splash"),
            child: SplashScreen(
              progression: state.progression,
            ),
            fadeBloc: _faderBloc,
          );
        } else if(state is GSB.MenuState) {
          print("Show menu");
          return FB.Fader(
            key: Key("MainMenu"),
            // fadeInDelay: 2000,
            child: MenuScreen(
              bloc: _sceneBloc,
              faderBloc: _faderBloc,
            ),
            fadeBloc: _faderBloc,
          );
        } else if(state is GSB.GameState) {
          return FB.Fader(
            key: Key("Game"),
            child: GameScreen(
              sceneBloc: _sceneBloc,
              faderBloc: _faderBloc,
            ),
            fadeBloc: _faderBloc,
          );
        }
        print(state);

        // state is GSB.UninitializedState
        return Container(
            color: Colors.black,
          );
      },
    );
  }
}