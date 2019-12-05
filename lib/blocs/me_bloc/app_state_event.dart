import 'package:equatable/equatable.dart';
import 'package:super_hero_call/models/super_hero.dart';

class AppStateEvent extends Equatable {
  final List _props;

  AppStateEvent([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class Picker extends AppStateEvent {
  final Map<String, SuperHero> heroes;

  Picker(this.heroes) : super([heroes]);
}

class Pick extends AppStateEvent {
  final SuperHero hero;
  Pick(this.hero) : super([hero]);
}

class UpdateHero extends AppStateEvent {
  final bool isTaken;
  final String heroName;

  UpdateHero(this.isTaken, this.heroName) : super([isTaken, heroName]);
}

class Connected extends AppStateEvent {
  final SuperHero hero;
  final bool cancelRequest;
  Connected(this.hero, {this.cancelRequest = false})
      : super([hero, cancelRequest]);
}

class Calling extends AppStateEvent {
  final SuperHero hero;
  Calling(this.hero) : super([hero]);
}

class Incomming extends AppStateEvent {
  final String requestId;
  final SuperHero hero;
  Incomming(this.requestId, this.hero) : super([requestId, hero]);
}

class AcceptOrDecline extends AppStateEvent {
  final bool accept;

  AcceptOrDecline(this.accept) : super([accept]);
}

class InCalling extends AppStateEvent {}

class Loading extends AppStateEvent {}

class FinishCall extends AppStateEvent {}

class SwitchCamera extends AppStateEvent {
}

class EnableDisableMicrophone extends AppStateEvent {
}
