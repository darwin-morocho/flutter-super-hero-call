import 'dart:convert';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:super_hero_call/models/super_hero.dart';

typedef OnConnected(Map<String, SuperHero> data);

class SocketClient {
  final _manager = SocketIOManager();
  SocketIO _socket;
  OnConnected onConnected;

  Future<void> connect() async {
    final options =
        SocketOptions("http://192.168.1.35:5000", enableLogging: true);
    _socket = await _manager.createInstance(options);

    _socket.on('on-connected', (dynamic data) {
      try {
        final Map<String, SuperHero> mapData = Map();

        final tmp = new Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));

        tmp.forEach((key, value) {
          print("value $value");
          final superHero = SuperHero.fromJson(value);
          mapData[key] = superHero;
        });

        print("send data ${mapData.length}");
        if (onConnected != null) {
          onConnected(mapData);
        }
      } catch (e) {
        print(e);
      }
    });

    _socket.onConnectError((error) {
      print(error);
    });

    _socket.onError((error) {
      print(error);
    });

    _socket.connect();
  }

  void pickSuperHero(String superHeroName) {
    _socket?.emit('pick', [superHeroName]);
  }

  /**
   * 
   */
  Future<void> disconnect() async {
    if (_socket != null) {
      _manager.clearInstance(_socket);
    }
  }
}
