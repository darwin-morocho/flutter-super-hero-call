import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;
import 'package:super_hero_call/models/super_hero.dart';
import 'package:collection/collection.dart';

class SuperheroesState {
  final bool isLoading;
  final Map<String, SuperHero> heroes;

  SuperheroesState({this.isLoading = true, @required this.heroes});

  factory SuperheroesState.initialState() =>
      SuperheroesState(heroes: Map<String, SuperHero>());

  @override
  bool operator ==(Object other) =>
      (other as SuperheroesState).isLoading &&
      isLoading &&
      MapEquality().equals(heroes, (other as SuperheroesState).heroes);

  SuperheroesState copyWith({bool isLoading, Map<String, SuperHero> heroes}) {
    return SuperheroesState(
        heroes: heroes ?? this.heroes, isLoading: isLoading ?? this.isLoading);
  }

  SuperheroesState update(SuperHero hero) {
    print("updating");
    if (heroes.containsKey(hero.name)) {
      heroes[hero.name] = hero;
      return copyWith(heroes: this.heroes);
    }
    return null;
  }
}
