import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_event.dart'
    as AppStateEvent;
import 'package:super_hero_call/blocs/me_bloc/app_state.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'hero_avatar.dart';
import 'hero_list_to_call.dart';
import 'hero_picker.dart';
import 'in_calling.dart';

class MyStatus extends StatelessWidget {
  const MyStatus({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appStateBloc = BlocProvider.of<AppStateBloc>(context);

    return BlocBuilder<AppStateBloc, AppState>(
      builder: (_, state) {
        switch (state.status) {
          case Status.loading:
            return Center(
                child: CupertinoActivityIndicator(
              radius: 15,
            ));
          case Status.picking:
            return HeroPicker(
              heroes: state.heroes,
              onPicked: (hero) {
                appStateBloc.add(AppStateEvent.Pick(hero));
              },
            );

          case Status.connected:
            return HeroListToCall();

          case Status.calling:
            return CallView(
              hero: state.him,
              amICaller: true,
              onCancelRequest: () {
                appStateBloc.add(
                    AppStateEvent.Connected(state.me, cancelRequest: true));
              },
            );

          case Status.incomming:
            return CallView(
              hero: state.him,
              amICaller: false,
              onAcceptOrDecline: (accept) {
                appStateBloc.add(AppStateEvent.AcceptOrDecline(accept));
              },
            );

          case Status.inCalling:
            return InCalling();
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
