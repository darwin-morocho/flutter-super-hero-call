import 'package:equatable/equatable.dart';

abstract class SuperheroesblocState extends Equatable {
  const SuperheroesblocState();
}

class InitialSuperheroesblocState extends SuperheroesblocState {
  @override
  List<Object> get props => [];
}
