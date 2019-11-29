import 'package:equatable/equatable.dart';
import 'package:super_hero_call/models/super_hero.dart';

class MeEvent extends Equatable {
  final List _props;

  MeEvent([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class Picker extends MeEvent {
  final Map<String, SuperHero> heroes;

  Picker(this.heroes) : super([heroes]);
}

class Pick extends MeEvent {
  final SuperHero hero;
  Pick(this.hero) : super([hero]);
}

class UpdateHero extends MeEvent {
  final bool isTaken;
  final String heroName;

  UpdateHero(this.isTaken, this.heroName) : super([isTaken, heroName]);
}

class Connected extends MeEvent {
  final SuperHero hero;
  final bool cancelRequest;
  Connected(this.hero, {this.cancelRequest = false})
      : super([hero, cancelRequest]);
}

class Calling extends MeEvent {
  final SuperHero hero;
  Calling(this.hero) : super([hero]);
}

class Incomming extends MeEvent {
  final String requestId;
  final SuperHero hero;
  Incomming(this.requestId, this.hero) : super([requestId, hero]);
}

class AcceptOrDecline extends MeEvent {
  final bool accept;

  AcceptOrDecline(this.accept) : super([accept]);
}

class InCalling extends MeEvent {}

class FinishCall extends MeEvent {}
