import 'package:DarkSurviver/pages/_bloc/fader_bloc.dart' as FB;
import 'package:DarkSurviver/pages/_bloc/game_start_bloc.dart' as SB;
import 'package:DarkSurviver/pages/pages/game_page/game.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/game_clear_screen/game_clear_screen.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/game_over_screen/game_over_screen.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/resource_panel/resource_bloc.dart' as RESOURCE_B;
import 'package:DarkSurviver/pages/pages/game_page/ui/resource_panel/resource_panel.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/round_panel/round_panel.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/round_panel/round_panel_bloc.dart' as ROUND_B;
import 'package:DarkSurviver/pages/pages/game_page/ui/static_screen_bloc.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/tower_construct_panel/tower_construct_bloc.dart' as TOWER_CB;
import 'package:DarkSurviver/pages/pages/game_page/ui/tower_construct_panel/tower_construct_panel.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/ui_managet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameScreen extends StatefulWidget {
  final SB.GameStartBloc sceneBloc;
  final FB.FaderBloc faderBloc;
  GameScreen({
    Key key,
    this.sceneBloc,
    this.faderBloc
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  TOWER_CB.TowerConstructBloc _towerConstructBloc;
  TowerConstructPanel towerConstructPanel;
  RESOURCE_B.ResourcePanelBloc _resourcePanelBloc;
  ROUND_B.RoundPanelBloc _roundPanelBloc;
  StaticScreenBloc _staticScreenBloc;
  ResourcePanel resourceScreen;
  MainGame _mainGame;
  @override
  void initState() {
    _towerConstructBloc = TOWER_CB.TowerConstructBloc();
    _resourcePanelBloc = RESOURCE_B.ResourcePanelBloc();
    _roundPanelBloc = ROUND_B.RoundPanelBloc();
    _staticScreenBloc = StaticScreenBloc();
    // towerConstructPanel = TowerConstructPanel();
    // resourceScreen = ResourceScreen();
    UiManager.getInstacne().init(
      _towerConstructBloc,
      _resourcePanelBloc,
      _roundPanelBloc,
      _staticScreenBloc
    );
    _mainGame = MainGame();
    super.initState();
  }

  @override
  void dispose() {
    _towerConstructBloc.close();
    _resourcePanelBloc.close();
    _roundPanelBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          print("???");
          widget.faderBloc.add(FB.FadeOutEvent(
            onComplete: () {
              widget.sceneBloc.add(SB.RestartMenuEvent());
            }
          ));
          return false;
        },
        child: Stack(
          children: <Widget>[
            _mainGame.widget,
            Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 16,),
                  ResourcePanel(bloc: _resourcePanelBloc),
                  SizedBox(height: 16,),
                  Expanded(
                    child: TowerConstructPanel(bloc: _towerConstructBloc,),
                  ),
                  SizedBox(height: 16,),
                ],
              )
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 24),
                child: RoundPanel(
                  bloc: _roundPanelBloc,
                ),
              ),
            ),
            BlocBuilder<StaticScreenBloc, StaticScreenState>(
              bloc: _staticScreenBloc,
              condition: (prev, state) => prev.isGameOverScreen != state.isGameOverScreen,
              builder: (context, state) {
                if(state.isGameOverScreen) {
                  return GameOverScreen(
                    onComplete: (){
                      widget.faderBloc.add(FB.FadeOutEvent(
                        onComplete: () {
                          widget.sceneBloc.add(SB.RestartMenuEvent());
                        }
                      ));
                    },
                  );
                }
                return Container();
              },
            ),
            BlocBuilder<StaticScreenBloc, StaticScreenState>(
              bloc: _staticScreenBloc,
              condition: (prev, state) => prev.isGameWinScreen != state.isGameWinScreen,
              builder: (context, state) {
                if(state.isGameWinScreen) {
                  return GameClearScreen(
                    onComplete: (){
                      widget.faderBloc.add(FB.FadeOutEvent(
                        onComplete: () {
                          widget.sceneBloc.add(SB.RestartMenuEvent());
                        }
                      ));
                    },
                  );
                }
                return Container();
              },
            )
          ],
        )
      )
    );
  }
}