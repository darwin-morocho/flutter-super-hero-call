import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_event.dart' as AppStateEvent;
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';

import 'package:super_hero_call/utils/signaling.dart';
import 'package:super_hero_call/widgets/me.dart';

class HomePage extends StatelessWidget {
  // Signaling _signaling = Signaling();
  //final _localRenderer = new RTCVideoRenderer();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              BlocBuilder<AppStateBloc, AppState>(
                builder: (_, state) {
                  return Me(
                    onFinishCall: () {
                      appStateBloc.add(AppStateEvent.FinishCall());
                    },
                    onAcceptOrDecline: (bool accept) {
                      appStateBloc.add(AppStateEvent.AcceptOrDecline(accept));
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
