import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:super_hero_call/models/super_hero.dart';

class HeroPicker extends StatelessWidget {
  final Map<String, SuperHero> heroes;
  final Function(SuperHero heroPicked) onPicked;
  const HeroPicker({Key key, @required this.heroes, this.onPicked})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Text(
          "Pick your Super Hero",
          style: TextStyle(
              fontSize: 20,
              color: Colors.white,
              letterSpacing: 1,
              fontWeight: FontWeight.bold),
        ),
        Text(
          "Choose one to enter the Super Hero Chat",
          style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              letterSpacing: 1,
              fontWeight: FontWeight.w300),
        ),
        Container(
          height: 1,
          width: 100,
          margin: EdgeInsets.symmetric(vertical: 20),
          color: Colors.white,
        ),
        Wrap(
          children: heroes.values.map((superHero) {
            return AbsorbPointer(
              absorbing: superHero.isTaken,
              child: Opacity(
                  opacity: superHero.isTaken ? 0.2 : 1,
                  child: CupertinoButton(
                    onPressed: () {
                      if (superHero.isTaken == false) {
                        onPicked(superHero);
                      }
                    },
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: CachedNetworkImage(
                          imageUrl: superHero.avatar,
                          width: 100,
                          height: 100,
                        )),
                  )),
            );
          }).toList(),
        )
      ],
    );
  }
}
