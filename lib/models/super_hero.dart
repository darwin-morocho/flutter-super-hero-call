import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart' show required;

class SuperHero extends Equatable {
  final String name, avatar;
  final bool available, inCall;
  SuperHero(
      {@required this.name,
      @required this.avatar,
      @required this.available,
      @required this.inCall});

  @override
  List<Object> get props =>
      [this.name, this.avatar, this.available, this.inCall];

  factory SuperHero.fromJson(Map<String, dynamic> json) => new SuperHero(
      name: json['name'],
      avatar: json['avatar'],
      available: json['available'],
      inCall: json['inCall']);
}
