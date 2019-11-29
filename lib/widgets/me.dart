import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_hero_call/blocs/me_bloc/me_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_event.dart' as MeEvent;
import 'package:super_hero_call/blocs/me_bloc/me_state.dart';
import 'package:super_hero_call/models/super_hero.dart';

import 'hero_avatar.dart';
import 'hero_list_to_call.dart';

class Me extends StatelessWidget {
  final Widget pickHero;
  final VoidCallback onFinishCall;
  final Function(bool) onAcceptOrDecline;
  const Me(
      {Key key,
      @required this.pickHero,
      this.onAcceptOrDecline,
      this.onFinishCall})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meBloc = BlocProvider.of<MeBloc>(context);

    return BlocBuilder<MeBloc, MeState>(
      builder: (_, state) {
        print("me stattus ${state.status}");
        switch (state.status) {
          case Status.connecting:
            return Center(
                child: CupertinoActivityIndicator(
              radius: 15,
            ));
          case Status.picking:
            return pickHero;

          case Status.connected:
            return HeroListToCall(
              meState: state,
            );

          case Status.calling:
            return CallView(
              hero: state.him,
              amICaller: true,
              onCancelRequest: () {
                meBloc.add(MeEvent.Connected(state.me, cancelRequest: true));
              },
            );

          case Status.incomming:
            return CallView(
              hero: state.him,
              amICaller: false,
              onAcceptOrDecline: onAcceptOrDecline,
            );

          case Status.inCalling:
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
                          Text(state.him.name,
                              style: TextStyle(color: Colors.white))
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: CupertinoButton(
                      onPressed: onFinishCall,
                      borderRadius: BorderRadius.circular(30),
                      padding:
                          EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      color: Colors.redAccent,
                      child: Icon(Icons.call_end, size: 40),
                    ),
                  )
                ],
              ),
            );
        }
      },
    );
  }
}

class CallView extends StatelessWidget {
  final SuperHero hero;
  final bool amICaller;
  final VoidCallback onCancelRequest;
  final Function(bool) onAcceptOrDecline;
  const CallView(
      {Key key,
      this.onCancelRequest,
      this.onAcceptOrDecline,
      @required this.hero,
      @required this.amICaller})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              SpinKitRipple(
                size: 150,
                color: Colors.white,
                borderWidth: 30,
                duration: Duration(seconds: 3),
              ),
              HeroAvatar(size: 100, imageUrl: hero.avatar)
            ],
          ),
          Text(
            amICaller ? "Calling to" : "Incomming",
            style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                letterSpacing: 1),
          ),
          Text(
            hero.name,
            style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
                letterSpacing: 1),
          ),
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              if (!amICaller)
                FloatingActionButton(
                  onPressed: () => onAcceptOrDecline(true),
                  child: Icon(Icons.call),
                  backgroundColor: Colors.green,
                ),
              FloatingActionButton(
                onPressed: amICaller
                    ? onCancelRequest
                    : () => onAcceptOrDecline(false),
                child: Icon(Icons.call_end),
                backgroundColor: Colors.redAccent,
              ),
            ],
          )
        ]);
  }
}
