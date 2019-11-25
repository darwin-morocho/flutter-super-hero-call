import 'package:adhara_socket_io/adhara_socket_io.dart';

class SocketClient {
  final _manager = SocketIOManager();
  SocketIO _socket;

  Future<void> connect() async {
    final options =
        SocketOptions("http://192.168.1.35:5000", enableLogging: true);
    _socket = await _manager.createInstance(options);

    _socket.on('on-connected', (superHeroes) {
      print("heroes ${superHeroes.toString()}");
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
