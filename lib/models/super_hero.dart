import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;

class SuperHero extends Equatable {
  final String name, avatar;
  final bool isTaken, inCall;
  SuperHero(
      {@required this.name,
      @required this.avatar,
      @required this.isTaken,
      @required this.inCall});

  @override
  List<Object> get props =>
      [this.name, this.avatar, this.isTaken, this.inCall];

  SuperHero copyWith(
      {String name, String avatar, bool isTaken, bool inCall}) {
    return SuperHero(
        name: name ?? this.name,
        avatar: avatar ?? this.avatar,
        isTaken: isTaken ?? this.isTaken,
        inCall: inCall ?? this.inCall);
  }

  factory SuperHero.fromJson(Map<String, dynamic> json) => new SuperHero(
      name: json['name'],
      avatar: json['avatar'],
      isTaken: json['isTaken'],
      inCall: json['inCall']);
}
