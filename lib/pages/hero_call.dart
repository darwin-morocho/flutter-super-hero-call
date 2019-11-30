import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/app_state_bloc.dart';
import 'package:super_hero_call/widgets/my_status.dart';

class HeroCall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      builder: (_) => AppStateBloc(),
      child: Scaffold(
        backgroundColor: Color(0xff263238),
        body: Container(
          width: double.infinity,
          child: SafeArea(
            child: MyStatus(),
          ),
        ),
      ),
    );
  }
}
