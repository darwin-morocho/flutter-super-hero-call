import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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

  Map<String, SuperHero> _superHeroes = Map();

  @override
  void initState() {
    super.initState();
    _socketClient.connect();
    _socketClient.onConnected = (data) {
      print(data.length);
      setState(() {
        _superHeroes = data;
      });
    };
  }

  @override
  void dispose() {
    _socketClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        child: Column(
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
              children: _superHeroes.values.map((superHero) {
                return CupertinoButton(
                  onPressed: () {},
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: CachedNetworkImage(
                        imageUrl: superHero.avatar,
                        width: 100,
                        height: 100,
                      )),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
