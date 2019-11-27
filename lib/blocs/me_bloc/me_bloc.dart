import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class MeBloc extends Bloc<MeEvent, MeState> {
  @override
  MeState get initialState => MeState.initialState();

  @override
  Stream<MeState> mapEventToState(
    MeEvent event,
  ) async* {
    if (event is PickingMeEvent) {
      yield MeState(isPicking: event.isPicking, myHero: state.myHero);
    } else if (event is MyHeroMeEvent) {
      yield state.copyWith(isPicking: false, myHero: event.hero);
    } else if (event is CallToMeEvent) {
      yield state.copyWith(callTo: event.hero);
    } else if (event is CallFromMeEvent) {
      yield state.copyWith(callFrom: event.hero);
    } else if (event is LeaveMeEvent) {
      yield MeState.initialState();
    }
  }
}
