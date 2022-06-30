// ignore_for_file: file_names

import 'package:bluetooth_soulpot/BLE/Setup.dart';
import 'package:bluetooth_soulpot/mqtt.dart';
import 'package:flutter/cupertino.dart';

class App extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _App();
}

class _App extends State<App> {
  bool firstLaunch = true;
  @override
  Widget build(BuildContext context) {
    if (firstLaunch) {
      return const Setup();
    } else {
      return const MQTTView();
    }
  }
}
