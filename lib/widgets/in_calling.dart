import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_event.dart'
    as AppStateEvent;

class InCalling extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);

    return Container(
      height: double.infinity,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 20,
            left: 20,
            child: Container(
              child: Row(
                children: <Widget>[
                  Icon(Icons.donut_large, color: Colors.green),
                  SizedBox(width: 10),
                  //Text(state.him.name, style: TextStyle(color: Colors.white))
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Transform.scale(
              alignment: Alignment.center,
              scale: 1.5,
              child: RTCVideoView(appStateBloc.remoteRenderer),
            ),
          ),
          Positioned(
            bottom: 120,
            left: 20,
            child: Transform.scale(
              scale: 0.3,
              alignment: Alignment.bottomLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  width: 480,
                  height: 640,
                  color: Color(0xfff0f0f0),
                  child: RTCVideoView(appStateBloc.localRenderer),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: SafeArea(
                          child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.mic, size: 35),
                  ),
                  CupertinoButton(
                    onPressed: () {
                      //finish the call
                      appStateBloc.add(AppStateEvent.FinishCall());
                    },
                    borderRadius: BorderRadius.circular(30),
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    color: Colors.redAccent,
                    child: Icon(Icons.call_end, size: 40),
                  ),
                  FloatingActionButton(
                    onPressed: () {},
                    child: Icon(Icons.camera_front, size: 35),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
