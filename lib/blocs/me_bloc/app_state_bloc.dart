import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/utils/signaling.dart';
import 'package:super_hero_call/utils/socket_client.dart';
import 'app_state_event.dart' as Event;
import 'app_state.dart';

class AppStateBloc extends Bloc<Event.AppStateEvent, AppState> {
  SocketClient _socketClient = SocketClient();
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
    _socketClient.connect();
    _socketClient.onConnected = (heroes) {
      print("connected");

      _signaling.init();

      add(Event.Picker(heroes));
    };

    _signaling.onLocalStream = (stream) {
      _localRenderer.srcObject = stream;
    };

    _signaling.onRemoteStream = (stream) {
      _remoteRenderer.srcObject = stream;
    };

    _signaling.onIceCandidate = (iceCandidate) {
      _socketClient.sendCandidate(state.requestId, iceCandidate);
    };

    _socketClient.onAssigned = (superHeroName) {
      if (superHeroName != null) {
        final hero = state.heroes[superHeroName];
        add(Event.Connected(hero));
      } else {
        add(Event.Picker(state.heroes));
        // _showSnackBar("The superhero was taken by other user");
      }
    };

    // when a superhero was taken
    _socketClient.onTaken = (superHeroName) {
      add(Event.UpdateHero(true, superHeroName));
    };

    // when a superhero was taken
    _socketClient.onDisconnected = (superHeroName) {
      print("disconnected $superHeroName");
      add(Event.UpdateHero(false, superHeroName));
    };

    // when i recive a call
    _socketClient.onRequest = (dynamic requestData) {
      final superHeroName = requestData['superHeroName'];
      final requestId = requestData['requestId'];
      final hero = state.heroes[superHeroName];
      _signaling.offer(requestData['data']);
      add(Event.Incomming(requestId, hero));
    };

    // when the calleer cancel the request
    _socketClient.onCancelRequest = () {
      add(Event.Connected(state.me));
    };

    // if the call that I made was taken or not
    _socketClient.onResponse = (superHeroName, data) async {
      if (data == null) {
        // the call was not taken
        add(Event.Connected(state.me));
        //_showSnackBar("$superHeroName is not available to take your call");
      } else {
        await _signaling.answer(data);
        add(Event.InCalling());
      }
    };

    // whe the other user finish the call
    _socketClient.onFinish = () {
      add(Event.Connected(state.me));
    };

    _socketClient.onCandidate = (candidate) {
      _signaling.addCandidate(candidate);
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
    _socketClient.disconnect();
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
      _socketClient.pickSuperHero(event.hero.name);
      yield state.copyWith(status: Status.loading);
    } else if (event is Event.UpdateHero) {
      yield state.updateHero(event.isTaken, event.heroName);
    } else if (event is Event.Connected) {
      if (event.cancelRequest) {
        _socketClient.cancelCall(); // cancel the request call
      }
      yield* getConnected(event.hero);
    } else if (event is Event.Calling) {
      final myOffer = await _signaling.call(); // get the offer data
      print("myOffer: ${myOffer.toString()}");
      _socketClient.callTo(event.hero.name, myOffer);
      yield state.copyWith(status: Status.calling, him: event.hero);
    } else if (event is Event.Incomming) {
      yield state.copyWith(
          status: Status.incomming,
          him: event.hero,
          requestId: event.requestId);
    } else if (event is Event.AcceptOrDecline) {
      //when you accept or decline one incomming call
      if (event.accept) {
        final myAnswer = _signaling.myAnswer;
        _socketClient.acceptOrDeclineCall(state.requestId, myAnswer);
        yield state.copyWith(status: Status.inCalling);
      } else {
        _socketClient.acceptOrDeclineCall(state.requestId, null);
        add(Event.Connected(state.me, cancelRequest: false));
      }
    } else if (event is Event.InCalling) {
      yield state.copyWith(status: Status.inCalling);
    } else if (event is Event.FinishCall) {
      _socketClient.finishCall();
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
