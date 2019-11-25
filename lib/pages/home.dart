import 'package:flutter/material.dart';
import '../utils/socket_client.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  SocketClient _socketClient = new SocketClient();

  @override
  void initState() {
    super.initState();
    _socketClient.connect();
  }

  @override
  void dispose() {
    _socketClient.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
