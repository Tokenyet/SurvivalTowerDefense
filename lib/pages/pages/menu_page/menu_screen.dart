import 'dart:async';

import 'package:DarkSurviver/pages/_bloc/fader_bloc.dart' as FB;
import 'package:DarkSurviver/pages/_bloc/game_start_bloc.dart' as SB;
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  final SB.GameStartBloc bloc;
  final FB.FaderBloc faderBloc;
  MenuScreen({
    Key key,
    this.bloc,
    this.faderBloc
  }) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  SB.GameStartBloc _bloc;
  FocusNode _startBtn;
  int renderCount = 0;

  Timer _sceneOnLoadTimer;

  @override
  void initState() {
    _bloc = widget.bloc;
    _startBtn = FocusNode();
    _sceneOnLoadTimer = Timer(Duration(milliseconds: 1000), () {
      WidgetsBinding.instance.addPostFrameCallback((_){
        _startBtn.requestFocus();
      });
    });
    super.initState();
  }
  
  @override
  void dispose() {
    _sceneOnLoadTimer.cancel();
    _startBtn.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.grey,
        child: Column(
          children: <Widget>[
            Expanded(child: Container(),),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueGrey, Colors.blueAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter
                ),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.black, width: 3)
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  FlatButton(
                    focusNode: _startBtn,
                    focusColor: Colors.white.withOpacity(0.5),
                    child: Text("Start"),
                    onPressed: (){
                      widget.faderBloc.add(FB.FadeOutEvent(
                        onComplete: () {
                          _bloc.add(SB.StartGameEvent());
                        }
                      ));
                    },
                  ),
                  FlatButton(
                    child: Text("Quit"),
                    focusColor: Colors.white.withOpacity(0.5),
                    onPressed: (){
                      widget.faderBloc.add(FB.FadeOutEvent(
                        onComplete: () {
                          _bloc.add(SB.QuitEvent());
                        }
                      ));
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 48,),
          ],
        ),
      ),
    );
  }
}