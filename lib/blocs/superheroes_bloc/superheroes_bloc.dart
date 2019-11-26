import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import './bloc.dart';

class SuperheroesBloc extends Bloc<SuperheroesEvent, SuperheroesState> {
  @override
  SuperheroesState get initialState => SuperheroesState.initialState();

  @override
  Stream<SuperheroesState> mapEventToState(
    SuperheroesEvent event,
  ) async* {
    print("event $event");
    if (event is LoadedSuperheroesEvent) {
      yield* _mapLoaded(event);
    } else if (event is UpdateSuperheroesEvent) {
      yield* _mapUpdate(event);
    }
  }

  Stream<SuperheroesState> _mapLoaded(LoadedSuperheroesEvent event) async* {
    yield SuperheroesState(isLoading: false, heroes: event.heroes);
  }

  Stream<SuperheroesState> _mapUpdate(UpdateSuperheroesEvent event) async* {
    SuperheroesState newState = state.update(event.hero);
    if (newState != null) {
      yield newState;
    }
  }
}
