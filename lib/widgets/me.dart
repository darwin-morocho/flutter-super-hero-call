import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_hero_call/blocs/me_bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';

import 'hero_avatar.dart';
import 'hero_list_to_call.dart';

class Me extends StatelessWidget {
  final Widget pickHero;
  final Function(bool) onAcceptOrDecline;
  const Me({Key key, @required this.pickHero, this.onAcceptOrDecline})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final meBloc = BlocProvider.of<MeBloc>(context);

    return BlocBuilder<MeBloc, MeState>(
      builder: (_, meState) {
        if (meState.isPicking) {
          return Center(
              child: CupertinoActivityIndicator(
            radius: 15,
          ));
        } else if (meState.myHero == null) {
          return pickHero;
        } else if (meState.callTo != null) {
          return CallView(
            amICaller: true,
            onCancelRequest: () {
              meBloc.add(CancelCallMeEvent());
            },
          );
        } else if (meState.callFrom != null) {
          return CallView(
            amICaller: false,
            onAcceptOrDecline: onAcceptOrDecline,
          );
        } else {
          return HeroListToCall(
            meState: meState,
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
      this.hero,
      this.amICaller})
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
            "Calling to",
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
              if (amICaller)
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
