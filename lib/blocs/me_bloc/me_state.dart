import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;
import 'package:super_hero_call/models/super_hero.dart';

class MeState extends Equatable {
  final bool isPicking;
  final String requestId;
  final SuperHero myHero, callTo, callFrom;

  MeState(
      {@required this.isPicking,
      this.myHero,
      this.callTo,
      this.callFrom,
      this.requestId});

  @override
  List<Object> get props => [isPicking, myHero, callTo, callFrom, requestId];

  factory MeState.initialState() => MeState(isPicking: false);

  MeState copyWith(
      {bool isPicking,
      SuperHero myHero,
      SuperHero callTo,
      SuperHero callFrom}) {
    return MeState(
        isPicking: isPicking ?? this.isPicking,
        myHero: myHero ?? this.myHero,
        callTo: callTo ?? this.callTo,
        callFrom: callFrom ?? this.callFrom);
  }
}
