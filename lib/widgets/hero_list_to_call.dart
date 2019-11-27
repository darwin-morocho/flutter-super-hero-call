import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/bloc.dart';
import 'package:super_hero_call/blocs/me_bloc/me_state.dart';
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';

import 'hero_avatar.dart';

class HeroListToCall extends StatelessWidget {
  final MeState meState;

  const HeroListToCall({Key key, @required this.meState})
      : assert(meState != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final meBloc = BlocProvider.of<MeBloc>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            children: <Widget>[
              HeroAvatar(imageUrl: meState.myHero.avatar),
              SizedBox(height: 10),
              Text(
                meState.myHero.name,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          BlocBuilder<SuperheroesBloc, SuperheroesState>(
            builder: (_, superHeroresState) {
              return Column(
                children: superHeroresState.heroes.values
                    .where((hero) => hero.name != meState.myHero.name)
                    .map((SuperHero item) => Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(
                                  width: 1, color: Color(0xff455A64))),
                          margin:
                              EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Row(children: <Widget>[
                                HeroAvatar(
                                  imageUrl: item.avatar,
                                  size: 50,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  item.name,
                                  style: TextStyle(color: Colors.white),
                                ),
                              ]),
                              FloatingActionButton(
                                heroTag: item.name,
                                onPressed: () {
                                  meBloc.add(CallToMeEvent(item));
                                },
                                child: Icon(Icons.call),
                                mini: true,
                              )
                            ],
                          ),
                        ))
                    .toList(),
              );
            },
          ),
          CupertinoButton(
            onPressed: () {},
            padding: EdgeInsets.zero,
            child: Container(
              width: 70,
              height: 70,
              child: Icon(
                Icons.power_settings_new,
                color: Colors.white,
                size: 50,
              ),
              decoration: BoxDecoration(
                  shape: BoxShape.circle, color: Colors.redAccent),
            ),
          )
        ],
      ),
    );
    ;
  }
}
