import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter_incall_manager/incall.dart';
import 'package:flutter_webrtc/webrtc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import 'package:super_hero_call/utils/signaling.dart';
import 'app_state_event.dart' as Event;
import 'app_state.dart';

class AppStateBloc extends Bloc<Event.AppStateEvent, AppState> {
  Signaling _signaling = Signaling();
  IncallManager _incall;

  final _localRenderer = new RTCVideoRenderer();
  final _remoteRenderer = new RTCVideoRenderer();
  RTCVideoRenderer get localRenderer => _localRenderer;
  RTCVideoRenderer get remoteRenderer => _remoteRenderer;

  AppStateBloc() {
    _initSocketClient();
  }

  _initSocketClient() async {
    print("connecting to ws");

    await _localRenderer.initialize();
    await _remoteRenderer.initialize();

    _signaling.init();
    _signaling.onConnected = (heroes) {
      if (_incall == null) {
        _incall = IncallManager();
        _incall.start();
      }

      print("connected");
      add(Event.Picker(heroes));
    };

    _signaling.onLocalStream = (MediaStream stream) {
      _localRenderer.srcObject = stream;
      _localRenderer.mirror = true;
    };

    _signaling.onRemoteStream = (MediaStream remoteStream) {
      _incall.stopRingback();
      _incall.stopRingtone();

      _remoteRenderer.srcObject = remoteStream;
      _remoteRenderer.mirror = true;

      _incall.setForceSpeakerphoneOn(flag: ForceSpeakerType.FORCE_ON);
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
      _localRenderer.srcObject = null;
      _remoteRenderer.srcObject = null;
      add(Event.UpdateHero(false, superHeroName));
    };

    // when i recive a call
    _signaling.onRequest = (dynamic requestData) {
      final superHeroName = requestData['superHeroName'];
      final requestId = requestData['requestId'];
      final hero = state.heroes[superHeroName];
      _incall.startRingback();
      _incall.startRingtone('DEFAULT', 'default', 10);
      add(Event.Incomming(requestId, hero));
    };

    // when the calleer cancel the request
    _signaling.onCancelRequest = () {
      _incall.stopRingback();
      _incall.stopRingtone();
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
      _remoteRenderer.srcObject = null;
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
    _incall?.stop();
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
      _incall.stopRingback();
      _incall.stopRingtone();
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
    } else if (event is Event.SwitchCamera) {
      await _signaling.switchCamera();
      yield state.copyWith(
          status: Status.inCalling, usefrontCamera: !state.usefrontCamera);
    } else if (event is Event.EnableDisableMicrophone) {
      final enabled = !state.microphoneEnabled;
      _signaling.microphoneEnabled(enabled);
      yield state.copyWith(
          status: Status.inCalling, microphoneEnabled: enabled);
    }
  }

  Stream<AppState> getConnected(SuperHero hero) async* {
    yield state.copyWith(
        status: Status.connected,
        heroes: state.heroes,
        him: null,
        me: hero,
        microphoneEnabled: true,
        usefrontCamera: true,
        requestId: null);
  }
}
