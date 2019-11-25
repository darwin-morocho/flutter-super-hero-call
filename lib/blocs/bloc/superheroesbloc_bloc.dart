import 'dart:async';
import 'package:bloc/bloc.dart';
import './bloc.dart';

class SuperheroesblocBloc extends Bloc<SuperheroesblocEvent, SuperheroesblocState> {
  @override
  SuperheroesblocState get initialState => InitialSuperheroesblocState();

  @override
  Stream<SuperheroesblocState> mapEventToState(
    SuperheroesblocEvent event,
  ) async* {
    // TODO: Add Logic
  }
}
