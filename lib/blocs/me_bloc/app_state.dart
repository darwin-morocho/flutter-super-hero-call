import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;
import 'package:super_hero_call/models/super_hero.dart';

enum Status { loading, picking, connected, calling, incomming, inCalling }

class AppState extends Equatable {
  final Status status;
  final String requestId;
  final SuperHero me, him;
  final Map<String, SuperHero> heroes;
  final bool usefrontCamera, microphoneEnabled;

  AppState(
      {@required this.status,
      this.requestId,
      this.me,
      this.him,
      this.heroes,
      this.usefrontCamera = true,
      this.microphoneEnabled = true});

  @override
  List<Object> get props =>
      [status, requestId, me, him, heroes, usefrontCamera, microphoneEnabled];

  factory AppState.initialState() => AppState(status: Status.loading);

  copyWith(
      {@required Status status,
      String requestId,
      SuperHero me,
      Map<String, SuperHero> heroes,
      SuperHero him,
      bool usefrontCamera,
      bool microphoneEnabled}) {
    return AppState(
        status: status,
        requestId: requestId ?? this.requestId,
        me: me ?? this.me,
        heroes: heroes ?? this.heroes,
        him: him ?? this.him,
        usefrontCamera: usefrontCamera ?? this.usefrontCamera,
        microphoneEnabled: microphoneEnabled ?? this.microphoneEnabled);
  }

  updateHero(bool isTaken, String heroName) {
    final tmp = Map<String, SuperHero>();
    tmp.addAll(heroes);
    tmp[heroName] = tmp[heroName].copyWith(isTaken: isTaken);

    return copyWith(status: this.status, heroes: tmp);
  }
}
