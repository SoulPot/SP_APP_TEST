// ignore_for_file: file_names
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';

typedef Callback = void Function(List<String>);

class WifiSetup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WifiSetup();
  final Callback callback;
  const WifiSetup(this.callback, {Key? key}) : super(key: key);
}

class _WifiSetup extends State<WifiSetup> {
  List<String> credentials = ["SSID", "PASSWORD"];
  List<String> ssids = ["Scanning wifi networks please wait..."];
  late TextEditingController _passController;

  final _formKey = GlobalKey<FormState>();

  void scanSSIDS() async {
    WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
    List<String> _ssids = [];
    try {
      wiFiHunterResult = (await WiFiHunter.huntWiFiNetworks)!;
    } on PlatformException catch (exception) {
      print(exception.toString());
    }

    for (int i = 0; i < wiFiHunterResult.results.length; i++) {
      _ssids.add(wiFiHunterResult.results[i].SSID);
    }
    setState(() {
      ssids = _ssids;
    });
  }

  @override
  void initState() {
    super.initState();
    _passController = TextEditingController();
    scanSSIDS();
  }

  @override
  void dispose() {
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(ssids);
    return Column(
      children: [
        const Text("Wifi Setup"),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            width: MediaQuery.of(context).size.width - 20,
            child: Form(
              key: _formKey,
              child: Expanded(
                child: Column(
                  children: [
                    DropdownButtonFormField(
                        items: ssids.map((String ssid) {
                          return DropdownMenuItem(
                              value: ssid, child: Text(ssid));
                        }).toList(),
                        onChanged: (value) async {
                          print(value);
                        },
                        hint: const Text("Select ssid from list ->"),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select ssid';
                          }
                          credentials[0] = value.toString();
                          return null;
                        }),
                    TextFormField(
                      controller: _passController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter some text';
                        }
                        credentials[1] = value;
                        return null;
                      },
                      decoration: const InputDecoration(hintText: "Password"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              widget.callback(credentials);
                            }
                          },
                          child: const Text("Send crendetials")),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
