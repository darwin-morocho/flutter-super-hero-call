import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:super_hero_call/blocs/superheroes_bloc/bloc.dart';
import 'package:super_hero_call/models/super_hero.dart';
import '../utils/socket_client.dart';
import 'package:cached_network_image/cached_network_image.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketClient _socketClient = new SocketClient();

  SuperheroesBloc _superHeroBloc;

  @override
  void initState() {
    super.initState();
    _socketClient.connect();
    _socketClient.onConnected = (data) {
      _superHeroBloc.add(LoadedSuperheroesEvent(data));
    };

    _socketClient.onAssigned = (superHeroName) {
      print("assigend $superHeroName");

      final tmp =
          _superHeroBloc.state.heroes[superHeroName].copyWith(available: false);
      _superHeroBloc.add(UpdateSuperheroesEvent(tmp));
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _socketClient.disconnect();
    _superHeroBloc.close();
    super.dispose();
  }

  Widget _heroList(Map<String, SuperHero> heroes) {
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
          "Choose one to enter to Super Hero Chat",
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
            return Opacity(
                opacity: superHero.available ? 1 : 0.4,
                child: CupertinoButton(
                  onPressed: () {
                    _socketClient.pickSuperHero(superHero.name);
                  },
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: superHero.avatar,
                        width: 100,
                        height: 100,
                      )),
                ));
          }).toList(),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    _superHeroBloc = BlocProvider.of<SuperheroesBloc>(context);
    return Scaffold(
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: BlocBuilder<SuperheroesBloc, SuperheroesState>(
          builder: (conetx, state) {
            print("lalaal");
            if (state.isLoading) {
              return Center(
                  child: CupertinoActivityIndicator(
                radius: 15,
              ));
            }
            return _heroList(state.heroes);
          },
        ),
      ),
    );
  }
}
