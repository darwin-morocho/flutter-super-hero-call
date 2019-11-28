import 'dart:async';

import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/blocs/me_bloc/bloc.dart';
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/utils/signaling.dart';
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
  Signaling _signaling = Signaling();
  final _localRenderer = new RTCVideoRenderer();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final SocketClient _socketClient = new SocketClient();

  SuperheroesBloc _superHeroBloc;
  MeBloc _meBloc;

  @override
  void afterFirstLayout(BuildContext context) {
    _superHeroBloc = BlocProvider.of<SuperheroesBloc>(context);
    _meBloc = BlocProvider.of<MeBloc>(context);
    _meBloc.onMeEvent = (evet) async {
      if (evet is CallToMeEvent) {
        // if I am calling
        final data = _signaling.sendMyOffer(); // get the offer data
        _socketClient.callTo(evet.hero.name, data); //emit a request call
      } else if (evet is CancelCallMeEvent) {
        _socketClient.cancelCall(); // cancel the request call
      }
    };
  }

  @override
  void initState() {
    super.initState();

    _initSocketClient();

    // _signaling.init();
    // _localRenderer.initialize();

    //
    // _signaling.onLocalStream = (MediaStream stream) {
    //   _localRenderer.srcObject = stream;
    //   _localRenderer.mirror = true;
    // };
  }

  _initSocketClient() {
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
        _showSnackBar("The superhero was taken by other user");
      }
    };

    // when a superhero was taken
    _socketClient.onTaken = (superHeroName) {
      _superHeroBloc.add(UpdateSuperheroesEvent(superHeroName));
    };

    // when i recive a call
    _socketClient.onRequest = (superHeroName, data) {
      _signaling.gotOffer(data);
    };

    // if the call that I made was taken or not
    _socketClient.onResponse = (superHeroName, data) {
      if (data == null) {
        // the call was not taken
        _meBloc.add(PickingMeEvent(false));
        _showSnackBar("$superHeroName is not available to take your call");
      }
    };
  }

  //when you accept or decline one incomming call
  void _acceptOrDeclineCall(bool accept) async {
    if (accept) {
      final data = await _signaling.sendMyAnswer();
      _socketClient.acceptOrDeclineCall(_meBloc.state.requestId, data);
    } else {
      _socketClient.acceptOrDeclineCall(_meBloc.state.requestId, null);
    }
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
    _signaling.dispose();
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
              absorbing: superHero.isTaken,
              child: Opacity(
                  opacity: superHero.isTaken ? 0.2 : 1,
                  child: CupertinoButton(
                    onPressed: () {
                      if (superHero.isTaken == false) {
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
      key: _scaffoldKey,
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: SafeArea(
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Me(
                pickHero: BlocBuilder<SuperheroesBloc, SuperheroesState>(
                  builder: (_, state) {
                    if (state.isLoading) {
                      return _loading();
                    }
                    return _heroList(state.heroes);
                  },
                ),
              ),
              // Positioned(
              //     left: 10,
              //     bottom: 20,
              //     width: 200,
              //     height: 300,
              //     child: RTCVideoView(this._localRenderer))
            ],
          ),
        ),
      ),
    );
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
                        meBloc.add(CancelCallMeEvent());
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
