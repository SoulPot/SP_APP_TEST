// ignore_for_file: file_names
import 'package:flutter/material.dart';

typedef Callback = void Function(List<String>);

class WifiSetup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WifiSetup();
  final Callback callback;
  const WifiSetup(this.callback, {Key? key}) : super(key: key);
}

class _WifiSetup extends State<WifiSetup> {
  List<String> credentials = ["SSID", "PASSWORD"];
  late TextEditingController _ssidController;
  late TextEditingController _passController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _ssidController = TextEditingController();
    _passController = TextEditingController();
  }

  @override
  void dispose() {
    _ssidController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              child: Column(
                children: [
                  TextFormField(
                    controller: _ssidController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter some text';
                      }
                      credentials[0] = value;
                      return null;
                    },
                    decoration: const InputDecoration(hintText: "SSID"),
                  ),
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
      ],
    );
  }
}
