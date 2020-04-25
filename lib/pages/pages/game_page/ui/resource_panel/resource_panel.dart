import 'package:DarkSurviver/pages/pages/game_page/ui/resource_panel/resource_bloc.dart' as MPB;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResourcePanel extends StatefulWidget {
  final MPB.ResourcePanelBloc bloc;
  ResourcePanel({Key key, this.bloc}) : super(key: key);

  @override
  _ResourcePanelState createState() => _ResourcePanelState();
}

class _ResourcePanelState extends State<ResourcePanel> {
  MPB.ResourcePanelBloc _bloc;

  @override
  void initState() { 
    super.initState();
    _bloc = widget.bloc;
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MPB.ResourcePanelBloc, MPB.ResourcePanelState>(
      bloc: _bloc,
      builder: (context, state) {
        return Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.black87),
            borderRadius: BorderRadius.circular(32)
          ),
          // height: 48,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Power: ${state.power}")
                ],
              ),
              SizedBox(width: 16,),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text("Money: ${state.money}")
                ],
              )
            ],
          ),
        );
      },
    );
  }
}