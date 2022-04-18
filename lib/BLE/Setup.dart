// ignore_for_file: file_names, avoid_print, unused_local_variable

import 'dart:async';
import 'dart:convert';

import 'package:bluetooth_soulpot/BLE/WifiSetup.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:loading_animations/loading_animations.dart';

class Setup extends StatefulWidget {
  const Setup({Key? key}) : super(key: key);

  @override
  State<Setup> createState() => _Setup();
}

class _Setup extends State<Setup> {
  static String deviceName = "SOULPOT_ESP32_";
  static String characteristicUuid = "96c44fd5-c309-4553-a11e-b8457810b94c";

  bool paired = false;
  bool showLoading = false;
  bool wifiSetup = false;

  BluetoothDevice? analyzer;
  BluetoothCharacteristic? wifiCharacteristic;
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
    if (analyzer != null && !paired) {
      await analyzer?.connect();
      return;
    }
  }

  void scanCharacteristics() async {
    List<BluetoothService>? services = await analyzer?.discoverServices();
    services?.forEach((service) {
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic char in characteristics) {
        // 80b7f088-0084-43e1-a687-8457bcb2dbc8
        print("CHAR UUID ${char.uuid.toString()}");
        if (char.uuid.toString() == characteristicUuid) {
          print("DESCRIPTOR SOUL POT${char.descriptors}");
          wifiCharacteristic = char;
        }
      }
    });
  }

  void sendWifiCredentials(List<String> credentials) {
    if (wifiCharacteristic != null) {
      String credentialsStr = "${credentials[0]},${credentials[1]}";
      wifiCharacteristic?.write(utf8.encode(credentialsStr));
    }
  }

  @override
  Widget build(BuildContext context) {
    // scanBLEDevices();
    return Padding(
      padding: const EdgeInsets.all(0),
      child: Row(children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            showLoading
                ? LoadingBouncingGrid.square()
                : Text(analyzer?.name ?? "No analyzer found"),
            paired == false
                ? TextButton(
                    child: const Text("Launch scan !"),
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
                  )
                : wifiSetup == false
                    ? TextButton(
                        child: const Text("Suivant"),
                        onPressed: (() {
                          wifiSetup = true;
                        }),
                      )
                    : WifiSetup((credentials) {
                        sendWifiCredentials(credentials);
                      }),
          ],
        ),
      ]),
    );
  }
}
