import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/utils/signaling.dart';
import 'app_state_event.dart' as Event;
import 'app_state.dart';

class AppStateBloc extends Bloc<Event.AppStateEvent, AppState> {
  Signaling _signaling = Signaling();

  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  AppStateBloc() {
    print("initialized");
    _initSocketClient();

    _localRenderer.initialize();
    _remoteRenderer.initialize();
  }

  _initSocketClient() {
    print("connecting to ws");
    _signaling.connect();
    _signaling.onConnected = (heroes) {
      print("connected");
      _signaling.getUserMedia();
      add(Event.Picker(heroes));
    };

    _signaling.onLocalStream = (stream) {
      _localRenderer.srcObject = stream;
      _localRenderer.mirror = true;
    };

    _signaling.onRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
      _remoteRenderer.mirror = true;
    };

    _signaling.onAssigned = (superHeroName) {
      if (superHeroName != null) {
        final hero = state.heroes[superHeroName];
        add(Event.Connected(hero));
      } else {
        add(Event.Picker(state.heroes));
        // _showSnackBar("The superhero was taken by other user");
      }
    };

    // when a superhero was taken
    _signaling.onTaken = (superHeroName) {
      add(Event.UpdateHero(true, superHeroName));
    };

    // when a superhero was taken
    _signaling.onDisconnected = (superHeroName) {
      print("disconnected $superHeroName");
      add(Event.UpdateHero(false, superHeroName));
    };

    // when i recive a call
    _signaling.onRequest = (dynamic requestData) {
      final superHeroName = requestData['superHeroName'];
      final requestId = requestData['requestId'];
      final hero = state.heroes[superHeroName];
      add(Event.Incomming(requestId, hero));
    };

    // when the calleer cancel the request
    _signaling.onCancelRequest = () {
      add(Event.Connected(state.me));
    };

    // if the call that I made was taken or not
    _signaling.onResponse = (answer) async {
      if (answer == null) {
        // the call was not taken
        add(Event.Connected(state.me));
        //_showSnackBar("$superHeroName is not available to take your call");
      } else {
        add(Event.InCalling());
      }
    };

    // whe the other user finish the call
    _signaling.onFinish = () {
      add(Event.Connected(state.me));
    };
  }

  @override
  AppState get initialState => AppState.initialState();

  @override
  void onEvent(Event.AppStateEvent event) {
    super.onEvent(event);
  }

  @override
  Future<void> close() {
    _signaling?.dispose();
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    _signaling.dispose();
    return super.close();
  }

  @override
  Stream<AppState> mapEventToState(
    Event.AppStateEvent event,
  ) async* {
    if (event is Event.Loading) {
      yield state.copyWith(status: Status.loading);
    } else if (event is Event.Picker) {
      yield state.copyWith(status: Status.picking, heroes: event.heroes);
    } else if (event is Event.Pick) {
      _signaling.pickSuperHero(event.hero.name);
      yield state.copyWith(status: Status.loading);
    } else if (event is Event.UpdateHero) {
      yield state.updateHero(event.isTaken, event.heroName);
    } else if (event is Event.Connected) {
      if (event.cancelRequest) {
        _signaling.cancelCall(); // cancel the request call
      }
      yield* getConnected(event.hero);
    } else if (event is Event.Calling) {
      _signaling.callTo(event.hero.name);
      yield state.copyWith(status: Status.calling, him: event.hero);
    } else if (event is Event.Incomming) {
      yield state.copyWith(
          status: Status.incomming,
          him: event.hero,
          requestId: event.requestId);
    } else if (event is Event.AcceptOrDecline) {
      _signaling.acceptOrDeclineCall(state.requestId, event.accept);

      //when you accept or decline one incomming call
      if (event.accept) {
        yield state.copyWith(status: Status.inCalling);
      } else {
        add(Event.Connected(state.me, cancelRequest: false));
      }
    } else if (event is Event.InCalling) {
      yield state.copyWith(status: Status.inCalling);
    } else if (event is Event.FinishCall) {
      _signaling.finishCall();
      _remoteRenderer.srcObject = null;
      yield* getConnected(state.me);
    }
  }

  Stream<AppState> getConnected(SuperHero hero) async* {
    yield state.copyWith(
        status: Status.connected,
        heroes: state.heroes,
        him: null,
        me: hero,
        requestId: null);
  }
}
