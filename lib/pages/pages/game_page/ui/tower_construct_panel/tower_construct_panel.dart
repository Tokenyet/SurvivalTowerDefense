import 'dart:async';

import 'package:DarkSurviver/pages/pages/game_page/ecs/entities/tower.dart';
import 'package:DarkSurviver/pages/pages/game_page/ui/tower_construct_panel/tower_construct_bloc.dart' as MPB;
import 'package:DarkSurviver/pages/pages/game_page/ui/ui_managet.dart';
import 'package:entitas_ff/entitas_ff.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TowerConstructPanel extends StatefulWidget {
  final MPB.TowerConstructBloc bloc;
  TowerConstructPanel({
    Key key,
    this.bloc
  }) :
    super(key: key);

  @override
  TowerConstructPanelState createState() => TowerConstructPanelState();
}

class TowerConstructPanelState extends State<TowerConstructPanel> {
  MPB.TowerConstructBloc _bloc;
  @override
  void initState() {
    super.initState();
    _bloc = widget.bloc;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MPB.TowerConstructBloc, MPB.TowerConstructState>(
      bloc: _bloc,
      builder: (context, state) {
        return Visibility(
          visible: state.isEnabled,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(16)
            ),
            width: 128,
            child: ListView(
              children: <Widget>[
                FlatButton(child: Text(describeEnum(TowerType.AttackTower)), onPressed: () {
                  _bloc.add(MPB.HideConstructableEvent(TowerType.AttackTower));
                },),
                FlatButton(child: Text(describeEnum(TowerType.HomeTower)), onPressed: () {
                  _bloc.add(MPB.HideConstructableEvent(TowerType.HomeTower));
                },),
                FlatButton(child: Text("Cancel"), onPressed: () {
                  _bloc.add(MPB.HideConstructableEvent(null));
                },),
              ],
            ),
          )
        );
      },
    );
  }
}