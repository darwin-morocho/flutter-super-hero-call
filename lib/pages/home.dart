import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_event.dart' as MeEvent;
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';

import 'package:super_hero_call/utils/signaling.dart';
import 'package:super_hero_call/widgets/me.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  // Signaling _signaling = Signaling();
  //final _localRenderer = new RTCVideoRenderer();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  SuperheroesBloc _superHeroBloc;
  MeBloc _meBloc;

  @override
  void afterFirstLayout(BuildContext context) {
    _meBloc = BlocProvider.of<MeBloc>(context);
  }

  @override
  void initState() {
    super.initState();

    //_signaling.init();
    //_localRenderer.initialize();

    // _signaling.onLocalStream = (MediaStream stream) {
    //   _localRenderer.srcObject = stream;
    //   _localRenderer.mirror = true;
    // };
  }

  void _showSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      backgroundColor: Colors.red,
      content: Text(message, style: TextStyle(color: Colors.white)),
      duration: Duration(seconds: 2),
    ));
  }

  @override
  void dispose() {
    // _signaling.dispose();
    _meBloc.close();
    super.dispose();
  }

  Widget _loading() => Center(
          child: CupertinoActivityIndicator(
        radius: 15,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Me(
                onFinishCall: () {
                  _meBloc.add(MeEvent.FinishCall());
                },
                onAcceptOrDecline: (bool accept) {
                  _meBloc.add(MeEvent.AcceptOrDecline(accept));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
