import 'package:after_layout/after_layout.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_event.dart' as MeEvent;
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';

import 'package:super_hero_call/utils/signaling.dart';
import 'package:super_hero_call/widgets/hero_picker.dart';
import 'package:super_hero_call/widgets/me.dart';
import '../utils/socket_client.dart';

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
    _meBloc.onMeEvent = (event) async {
      print("event ${event}");

      if (event is MeEvent.Calling) {
        //final data = await _signaling.sendMyOffer(); // get the offer data
        _socketClient.callTo(event.hero.name, 'data'); //emit a request call
      } else if (event is MeEvent.Connected && event.cancelRequest) {
        _socketClient.cancelCall(); // cancel the request call
      }
    };
  }

  @override
  void initState() {
    super.initState();

    _initSocketClient();

    //_signaling.init();
    //_localRenderer.initialize();

    // _signaling.onLocalStream = (MediaStream stream) {
    //   _localRenderer.srcObject = stream;
    //   _localRenderer.mirror = true;
    // };
  }

  _initSocketClient() {
    _socketClient.connect();
    _socketClient.onConnected = (data) {
      _superHeroBloc.add(LoadedSuperheroesEvent(data));
      _meBloc.add(MeEvent.Picking(false));
    };

    _socketClient.onAssigned = (superHeroName) {
      if (superHeroName != null) {
        final hero = _superHeroBloc.state.heroes[superHeroName];
        _meBloc.add(MeEvent.Connected(hero));
      } else {
        _meBloc.add(MeEvent.Picking(false));
        _showSnackBar("The superhero was taken by other user");
      }
    };

    // when a superhero was taken
    _socketClient.onTaken = (superHeroName) {
      _superHeroBloc.add(UpdateSuperheroesEvent(superHeroName, true));
    };

    // when a superhero was taken
    _socketClient.onDisconnected = (superHeroName) {
      print("disconnected $superHeroName");
      _superHeroBloc.add(UpdateSuperheroesEvent(superHeroName, false));
    };

    // when i recive a call
    _socketClient.onRequest = (dynamic requestData) {
      final superHeroName = requestData['superHeroName'];
      final requestId = requestData['requestId'];
      final hero = _superHeroBloc.state.heroes[superHeroName];
      _meBloc.add(MeEvent.Incomming(requestId, hero));
      _signaling.gotOffer(requestData['data']);
    };

    // when the calleer cancel the request
    _socketClient.onCancelRequest = () {
      print("onCancelRequest");
      _meBloc.add(MeEvent.Connected(_meBloc.state.me));
    };

    // if the call that I made was taken or not
    _socketClient.onResponse = (superHeroName, data) {
      if (data == null) {
        // the call was not taken
        _meBloc.add(MeEvent.Connected(_meBloc.state.me));
        _showSnackBar("$superHeroName is not available to take your call");
      } else {
        _meBloc.add(MeEvent.InCalling());
      }
    };

    // whe the other user finish the call
    _socketClient.onFinish = () {
      _meBloc.add(MeEvent.Connected(_meBloc.state.me));
    };
  }

  //when you accept or decline one incomming call
  void _acceptOrDeclineCall(bool accept) async {
    if (accept) {
      //final data = await _signaling.sendMyAnswer();
      _socketClient.acceptOrDeclineCall(_meBloc.state.requestId, 'data');
      _meBloc.add(MeEvent.InCalling());
    } else {
      _socketClient.acceptOrDeclineCall(_meBloc.state.requestId, null);
      _meBloc.add(MeEvent.Connected(_meBloc.state.me, cancelRequest: false));
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
                  _meBloc.add(MeEvent.Connected(_meBloc.state.me));
                  _socketClient.finishCall();
                },
                onAcceptOrDecline: (bool accept) {
                  _acceptOrDeclineCall(accept);
                },
                pickHero: BlocBuilder<SuperheroesBloc, SuperheroesState>(
                  builder: (_, state) {
                    if (state.isLoading) {
                      return _loading();
                    }
                    return HeroPicker(
                      heroes: state.heroes,
                      onPicked: (heroName) {
                        _socketClient.pickSuperHero(heroName);
                        _meBloc.add(MeEvent.Picking(true));
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
