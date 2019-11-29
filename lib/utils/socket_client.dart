import 'dart:convert';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:super_hero_call/models/super_hero.dart';

typedef OnConnected(Map<String, SuperHero> data);
typedef OnAssigned = void Function(String superHeroName);
typedef OnTaken = void Function(String superHeroName);
typedef OnResponse = void Function(String superHeroName, dynamic data);
typedef OnRequest = void Function(dynamic data);
typedef OnCancelRequest = void Function();
typedef OnDisconnected = void Function(String superHeroName);
typedef OnFinish = void Function();

class SocketClient {
  IO.Socket _socket;
  OnConnected onConnected;
  OnAssigned onAssigned;
  OnAssigned onTaken;
  OnResponse onResponse;
  OnRequest onRequest;
  OnCancelRequest onCancelRequest;
  OnDisconnected onDisconnected;
  OnFinish onFinish;

  Future<void> connect() async {
    // const uri = "http://192.168.100.19:5000";
    const uri = "https://super-hero-call.herokuapp.com";
    _socket = IO.io(uri, <String, dynamic>{
      'transports': ['websocket'],
    });

    _socket.on('on-connected', (dynamic data) {
      try {
        final Map<String, SuperHero> mapData = Map();

        final tmp = new Map<String, dynamic>.from(jsonDecode(jsonEncode(data)));

        tmp.forEach((key, value) {
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

    _socket.on('on-assigned', (data) {
      if (onAssigned != null) {
        onAssigned(data);
      }
    });
    _socket.on('on-taken', (data) {
      if (onTaken != null) {
        onTaken(data);
      }
    });

    _socket.on('on-request', (data) {
      print("on-request");
      if (onRequest != null) {
        onRequest(data);
      }
    });

    _socket.on('on-cancel-request', (_) {
      if (onCancelRequest != null) {
        onCancelRequest();
      }
    });

    _socket.on('on-response', (data) {
      if (onResponse != null) {
        onResponse(data['superHeroName'], data['data']);
      }
    });

    _socket.on('on-disconnected', (data) {
      if (onDisconnected != null) {
        onDisconnected(data);
      }
    });

    _socket.on('on-finish-call', (_) {
      if (onFinish != null) {
        onFinish();
      }
    });
  }

  void pickSuperHero(String superHeroName) {
    _socket?.emit('pick', superHeroName);
  }

  void callTo(String superHeroName, dynamic data) {
    _socket?.emit('request', {"superHeroName": superHeroName, "data": data});
  }

  void cancelCall() {
    _socket?.emit('cancel-request');
  }

  void finishCall() {
    _socket?.emit('finish-call');
  }

  void acceptOrDeclineCall(String requestId, dynamic data) {
    _socket?.emit('response', {"requestId": requestId, "data": data});
  }

  disconnect() async {
    if (_socket != null) {
      _socket.disconnect();
      _socket.close();
      _socket = null;
    }
  }
}
