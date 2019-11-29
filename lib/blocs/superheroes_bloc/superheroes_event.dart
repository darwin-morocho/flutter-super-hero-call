import 'package:equatable/equatable.dart';
import 'package:super_hero_call/models/super_hero.dart';

abstract class SuperheroesEvent extends Equatable {
  final List _props;
  const SuperheroesEvent([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class LoadedSuperheroesEvent extends SuperheroesEvent {
  final Map<String, SuperHero> heroes;
  LoadedSuperheroesEvent(this.heroes) : super([heroes]);
}

class UpdateSuperheroesEvent extends SuperheroesEvent {
  final String heroName;
  final bool istaken;
  UpdateSuperheroesEvent(this.heroName, this.istaken)
      : super([heroName, istaken]);
}
