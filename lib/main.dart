import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pages/hero_call.dart';

void main() async {
  final ph = PermissionHandler();

  final cameraStatus = await ph.checkPermissionStatus(PermissionGroup.camera);
  final microStatus = await ph.checkPermissionStatus(PermissionGroup.camera);

  final permissionsOk = cameraStatus == PermissionStatus.granted &&
      microStatus == PermissionStatus.granted;

  print("permission status $permissionsOk");

  runApp(
      // if the camera and microphone permissions are granted we go to HeroCall page
      MyApp(permissionsOk: permissionsOk)
      //
      );
}

class MyApp extends StatelessWidget {
  final bool permissionsOk;

  const MyApp({Key key, @required this.permissionsOk})
      : assert(permissionsOk != null),
        super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: HeroCall(),
      debugShowCheckedModeBanner: false,
    );
  }
}
