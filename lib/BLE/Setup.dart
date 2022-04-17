// ignore_for_file: file_names, avoid_print, unused_local_variable

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:loading_animations/loading_animations.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  State<Setup> createState() => _Setup();
}

class _Setup extends State<Setup> {
  BluetoothDevice? analyzer;
  static String deviceName = "SOULPOT_ESP32_";
  bool showLoading = false;
  bool paired = false;
  FlutterBlue flutterBlue = FlutterBlue.instance;

  void scanBLEDevices() {
    flutterBlue.startScan(timeout: const Duration(seconds: 10));
    BluetoothDevice? analyzer;
    var subscription = flutterBlue.scanResults.listen((results) {
      for (ScanResult result in results) {
        if (result.device.name.contains(deviceName) == true) {
          this.analyzer = result.device;
          flutterBlue.stopScan();
          connectAnalyzer().then((value) {
            setState(() {
              showLoading = false;
            });
            scanCharacteristics();
          });
        }
      }
    });
  }

  Future<void> connectAnalyzer() async {
    analyzer?.state.forEach((s) {
      if (s == BluetoothDeviceState.connected) {
        setState(() {
          paired = true;
        });
      }
    });
    if (analyzer != null) {
      await analyzer?.connect();
      return;
    }
  }

  void scanCharacteristics() async {
    List<BluetoothService>? services = await analyzer?.discoverServices();
    services?.forEach((service) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic char in characteristics) {
        print("DESCRIPTOR ${char.descriptors}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // scanBLEDevices();
    return Column(
      children: [
        showLoading
            ? LoadingBouncingGrid.square()
            : Text(analyzer?.name ?? "No analyzer found"),
        paired == false
            ? TextButton(
                onPressed: () {
                  setState(() {
                    showLoading = true;
                  });
                  scanBLEDevices();
                  Timer timer = Timer(const Duration(seconds: 10), () {
                    setState(() {
                      showLoading = false;
                    });
                  });
                },
                child: const Text("Launch scan !"),
              )
            : TextButton(
                onPressed: (() {
                  print("Suivant");
                }),
                child: const Text("Suivant"),
              )
      ],
    );
  }
}
