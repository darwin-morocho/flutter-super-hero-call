import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:super_hero_call/blocs/me_bloc/bloc.dart';
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/widgets/hero_avatar.dart';
import 'package:super_hero_call/widgets/hero_list_to_call.dart';
import '../utils/socket_client.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with AfterLayoutMixin {
  SocketClient _socketClient = new SocketClient();
  StreamSubscription _meBlocSubscription;

  SuperheroesBloc _superHeroBloc;
  MeBloc _meBloc;

  @override
  void initState() {
    super.initState();
    _socketClient.connect();
    _socketClient.onConnected = (data) {
      _superHeroBloc.add(LoadedSuperheroesEvent(data));
    };

    _socketClient.onAssigned = (superHeroName) {
      if (superHeroName != null) {
        final hero = _superHeroBloc.state.heroes[superHeroName];
        _meBloc.add(MyHeroMeEvent(hero));
      } else {
        _meBloc.add(PickingMeEvent(false));
        Scaffold.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("The superhero was taken by other user",
              style: TextStyle(color: Colors.white)),
          duration: Duration(microseconds: 400),
        ));
      }
    };

    _socketClient.onTaken = (superHeroName) {
      if (superHeroName != null) {}
      final tmp =
          _superHeroBloc.state.heroes[superHeroName].copyWith(available: false);
      _superHeroBloc.add(UpdateSuperheroesEvent(tmp));
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _meBlocSubscription.cancel();
    _socketClient.disconnect();
    _superHeroBloc.close();
    _meBloc.close();
    super.dispose();
  }

  Widget _heroList(Map<String, SuperHero> heroes) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Pick your Super Hero",
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "Choose one to enter to Super Hero Chat",
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              letterSpacing: 1,
              fontWeight: FontWeight.w300),
        ),
        Container(
          height: 1,
          width: 100,
          margin: EdgeInsets.symmetric(vertical: 20),
          color: Colors.white,
        ),
        Wrap(
          children: heroes.values.map((superHero) {
            return AbsorbPointer(
              absorbing: !superHero.available,
              child: Opacity(
                  opacity: superHero.available ? 1 : 0.2,
                  child: CupertinoButton(
                    onPressed: () {
                      if (superHero.available) {
                        _socketClient.pickSuperHero(superHero.name);
                        _meBloc.add(PickingMeEvent(true));
                      }
                    },
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: superHero.avatar,
                          width: 100,
                          height: 100,
                        )),
                  )),
            );
          }).toList(),
        )
      ],
    );
  }

  Widget _loading() => Center(
          child: CupertinoActivityIndicator(
        radius: 15,
      ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Me(
            pickHero: BlocBuilder<SuperheroesBloc, SuperheroesState>(
              builder: (_, state) {
                if (state.isLoading) {
                  return _loading();
                }
                return _heroList(state.heroes);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    _superHeroBloc = BlocProvider.of<SuperheroesBloc>(context);
    _meBloc = BlocProvider.of<MeBloc>(context);
  }
}

class Me extends StatelessWidget {
  final Widget pickHero;
  const Me({Key key, @required this.pickHero}) : super(key: key);

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
                    HeroAvatar(size: 100, imageUrl: meState.callTo.avatar)
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
                  meState.callTo.name,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1),
                ),
                SizedBox(height: 100),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FloatingActionButton(
                      onPressed: () {
                        meBloc.add(PickingMeEvent(false));
                      },
                      child: Icon(Icons.call_end),
                      backgroundColor: Colors.redAccent,
                    ),
                  ],
                )
              ]);
        } else {
          return HeroListToCall(
            meState: meState,
          );
        }
      },
    );
  }
}
