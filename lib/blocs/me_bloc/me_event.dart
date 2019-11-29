import 'package:equatable/equatable.dart';
import 'package:super_hero_call/models/super_hero.dart';

class MeEvent extends Equatable {
  final List _props;

  MeEvent([this._props = const []]);

  @override
  List<Object> get props => _props;
}

class Picking extends MeEvent {
  final bool isPicking;

  Picking(this.isPicking) : super([isPicking]);
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

class InCalling extends MeEvent {}
