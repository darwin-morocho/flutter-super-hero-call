import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;
import 'package:super_hero_call/models/super_hero.dart';

enum Status { connecting, picking, connected, calling, incomming, inCalling }

class MeState extends Equatable {
  final Status status;
  final String requestId;
  final SuperHero me, him;

  MeState({@required this.status, this.requestId, this.me, this.him});

  @override
  List<Object> get props => [status, requestId, me, him];

  factory MeState.initialState() => MeState(status: Status.connecting);

  copyWith(
      {@required Status status,
      String requestId,
      SuperHero me,
      SuperHero him}) {
    return MeState(
        status: status,
        requestId: requestId ?? this.requestId,
        me: me ?? this.me,
        him: him ?? this.him);
  }
}
