// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MQTTView extends StatefulWidget {
  const MQTTView({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _MQTTView();
}

class _MQTTView extends State<MQTTView> {
  String server = 'alesia-julianitow.ovh';
  String clientId = 'soulpot_app';
  String deviceId = 'ANALYZER_00';
  int port = 9443;
  late MqttClient mqttClient;
  List<String> payloads = [];

  void onConnected() {
    print('MQTT LOGGED');
  }

  void onDisconnected() {
    if (mqttClient.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('Client disconnect normally.');
    } else {
      print('Error when disconnecting');
    }
  }

  void onSubscribed() {
    print("MQTT SUBSCRIBED");
  }

  void initMqttClient() {
    mqttClient = MqttServerClient.withPort(server, clientId, port);
    mqttClient.logging(on: true);
    mqttClient.setProtocolV311();
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onConnected = onConnected;
  }

  Future<void> mqttConnect() async {
    try {
      await mqttClient.connect();
      return;
    } on NoConnectionException catch (e) {
      print('Client exception - $e');
      mqttClient.disconnect();
    } on Exception catch (e) {
      print('Socket exception $e');
      mqttClient.disconnect();
    }

    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT client connected');
    } else {
      /// Use status here rather than state if you also want the broker return code.
      print('MQTT connection failed -> status: ${mqttClient.connectionStatus}');
      mqttClient.disconnect();
    }
  }

  void subscribeToDevice(String deviceId) {
    final topic = 'events/$deviceId';
    mqttClient.subscribe(topic, MqttQos.atMostOnce);
    mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
      final recMess = c![0].payload as MqttPublishMessage;
      final payloadStr =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print('received payload $payloadStr -->');
      setState(() {
        if (payloads.length > 15) {
          payloads.clear();
        }
        payloads.add(payloadStr);
      });
    });
    mqttClient.published!.listen((MqttPublishMessage message) {
      print(
          'Published on topic: ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
    });
  }

  void publishsMsg(String msg, String deviceId) {
    final payloadBuilder = MqttClientPayloadBuilder();
    payloadBuilder.addString(msg);
    if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
      if (payloadBuilder.payload != null) {
        mqttClient.publishMessage('events/$deviceId/sprink',
            MqttQos.atLeastOnce, payloadBuilder.payload!);
      } else {
        throw ErrorDescription('Payload cannot be null');
      }
    } else {
      throw ErrorDescription('MQTT Client not connected');
    }
  }

  _MQTTView() {
    deviceId = 'ANALYZER_00';
    initMqttClient();
    mqttConnect().then((value) =>
        {subscribeToDevice(deviceId), subscribeToDevice('ANALYZER_01')});
  }

  bool firstLaunch = false;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                publishsMsg('sprink', deviceId);
              },
              child: const Text('Sent sprinkle cmd')),
          SizedBox(
              height: 560,
              child: ListView(
                children: [
                  for (var payload in payloads) Text('Payload: \n$payload')
                ],
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
              ))
        ],
      ),
    );
  }
}
