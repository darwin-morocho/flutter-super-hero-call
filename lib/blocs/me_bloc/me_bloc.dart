import 'dart:async';
import 'package:bloc/bloc.dart';
import 'me_event.dart' as Event;
import 'me_state.dart';

typedef OnMeEvent = void Function(Event.MeEvent event);

class MeBloc extends Bloc<Event.MeEvent, MeState> {
  OnMeEvent onMeEvent;

  @override
  MeState get initialState => MeState.initialState();

  @override
  void onEvent(Event.MeEvent event) {
    super.onEvent(event);
    if (onMeEvent != null) {
      onMeEvent(event);
    }
  }

  @override
  Future<void> close() {
    return super.close();
  }

  @override
  Stream<MeState> mapEventToState(
    Event.MeEvent event,
  ) async* {
    if (event is Event.Picking) {
      yield MeState(status: Status.picking);
    } else if (event is Event.Connected) {
      yield MeState(
          me: event.hero, status: Status.connected, him: null, requestId: null);
    } else if (event is Event.Calling) {
      yield state.copyWith(status: Status.calling, him: event.hero);
    } else if (event is Event.Incomming) {
      yield state.copyWith(
          status: Status.incomming,
          him: event.hero,
          requestId: event.requestId);
    } else if (event is Event.InCalling) {
      yield state.copyWith(status: Status.inCalling);
    }
  }
}
