import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SuperheroesBloc extends Bloc<SuperheroesEvent, SuperheroesState> {
  @override
  SuperheroesState get initialState => SuperheroesState.initialState();

  @override
  Stream<SuperheroesState> mapEventToState(
    SuperheroesEvent event,
  ) async* {
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
    final hero = state.heroes[event.heroName].copyWith(isTaken: event.istaken);

    SuperheroesState newState = state.update(hero);
    if (newState != null) {
      yield newState;
    }
  }
}
