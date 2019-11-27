import 'package:equatable/equatable.dart';
import 'package:super_hero_call/models/super_hero.dart';

class MeEvent extends Equatable {
  final List _props;

  MeEvent([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class PickingMeEvent extends MeEvent {
  final bool isPicking;

  PickingMeEvent(this.isPicking) : super([isPicking]);
}

class LeaveMeEvent extends MeEvent {}

class MyHeroMeEvent extends MeEvent {
  final SuperHero hero;
  MyHeroMeEvent(this.hero) : super([hero]);
}

class CallToMeEvent extends MeEvent {
  final SuperHero hero;

  CallToMeEvent(this.hero) : super([hero]);
}

class CallFromMeEvent extends MeEvent {
  final SuperHero hero;

  CallFromMeEvent(this.hero) : super([hero]);
}
