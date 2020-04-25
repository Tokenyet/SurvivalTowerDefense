import 'package:DarkSurviver/pages/pages/game_page/ui/round_panel/round_panel_bloc.dart' as MPB;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoundPanel extends StatefulWidget {
  final MPB.RoundPanelBloc bloc;
  RoundPanel({
    Key key,
    this.bloc
  }) : super(key: key);

  @override
  _RoundPanelState createState() => _RoundPanelState();
}

class _RoundPanelState extends State<RoundPanel> {
  MPB.RoundPanelBloc _bloc;
  @override
  void initState() { 
    super.initState();
    _bloc = widget.bloc;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      // data: ThemeData(accentColor: Colors.white, primaryColor: Colors.blueAccent),
      style: TextStyle(color: Colors.white),
      child: IgnorePointer(
        child: BlocBuilder<MPB.RoundPanelBloc, MPB.RoundPanelState>(
          bloc: _bloc,
          builder: (context, state) {
            if(state is MPB.RoundState) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Level: ${state.level}"),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text("Progression: ${state.roundProgress}"),
                      ],
                    ),
                    Text("Remain: ${state.currentSeconds} / ${state.maximumSeconds}")
                  ],
                ),
              );
            } else if(state is MPB.WaitState) {
              return Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Text("Remain: ${state.currentSeconds} / ${state.maximumSeconds}")
                  ],
                ),
              );
            }
            return Container();
          },
        )
      )
    );
  }
}