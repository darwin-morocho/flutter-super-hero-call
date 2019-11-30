import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionPage extends StatefulWidget {
  const PermissionPage({Key key}) : super(key: key);

  @override
  _PermissionPageState createState() => _PermissionPageState();
}

class _PermissionPageState extends State<PermissionPage>
    with WidgetsBindingObserver {
  bool _wasOpenSetting = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _wasOpenSetting) {
      _wasOpenSetting = false;
      _requestPermissions(openSettings: false);
    }
  }

  _requestPermissions({bool openSettings = true}) async {
    final ph = PermissionHandler();

    final Map<PermissionGroup, PermissionStatus> results = await ph
        .requestPermissions(
            [PermissionGroup.camera, PermissionGroup.microphone]);

    final bool cameraOk =
        results[PermissionGroup.camera] == PermissionStatus.granted;

    final bool microOk =
        results[PermissionGroup.microphone] == PermissionStatus.granted;

    if (microOk && cameraOk) {
      Navigator.pushReplacementNamed(context, 'hero-call');
    } else if (openSettings) {
      _wasOpenSetting = true;
      ph.openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff263238),
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/podcast.svg',
              color: Colors.white,
              width: 150,
            ),
            SizedBox(height: 20),
            Text(
                "To use video chat we need access to your camera and microphone",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w300)),
            SizedBox(height: 40),
            CupertinoButton(
              onPressed: _requestPermissions,
              color: Color(0xff2979FF),
              borderRadius: BorderRadius.circular(30),
              child: Text("ALLOW", style: TextStyle(letterSpacing: 1)),
            )
          ],
        ),
      ),
    );
  }
}
