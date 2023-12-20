import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/NotificationService.dart';
import 'package:hive_mqtt/Services/firebaseServices.dart';
import 'package:hive_mqtt/main.dart';
import 'package:hive_mqtt/views/homePage.dart';
import 'package:hive_mqtt/views/productView.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_beep/flutter_beep.dart';

RxBool broker_conn = false.obs;
final firebaseServicesController fcontroller =
    Get.put(firebaseServicesController());

final client = MqttServerClient('broker.mqttdashboard.com', 'clientId_0099');

class MqttServices {
  var pongCount = 0;
  int index = 0;
  void connection() async {
    client.logging(on: false);
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;

    client.port = 1883;
    client.pongCallback = pong;
    client.onSubscribed = onSubscribed;

    final connMess = MqttConnectMessage()
        .withClientIdentifier('clientId_0099')
        .withWillTopic('willtopic')
        .withWillMessage('My Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    print('hivemqtt client connecting....');
    client.connectionMessage = connMess;
    try {
      await client.connect();
    } on NoConnectionException catch (e) {
      print('client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      print('socket exception - $e');
      client.disconnect();
    }
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      print('hivemqtt client connected');
    } else {
      print(
          'ERROR hivemqtt client connection failed - disconnecting, status is ${client.connectionStatus}');
      client.disconnect();
    }

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) async {
      final prefs = await SharedPreferences.getInstance();

      final recMess = c![0].payload as MqttPublishMessage;
      final pt =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
      print(
          'Change notification:: topic is <${c[0].topic}>, payload is <-- $pt-->');
      var l = await fcontroller.getShaList();
      for (var i = 0; i < l.length; i++) {
        if (c[0].topic == '${l[i]}') {
          serialKey.value = await fcontroller.getSpecificShaList(c[0].topic);
          if (pt == 'ALM_FIRE') {
            alarm[serialKey.value] = true;
            FlutterBeep.playSysSound(AndroidSoundIDs.TONE_CDMA_ABBR_ALERT);
            String deviceName =
                await fcontroller.getDeviceName(serialKey.toString());
                           String deviceQrcode =
                await fcontroller.getDeviceQrcode( serialKey.value);
            int inde = await fcontroller.fetchKeyFromFirbase(serialKey.value);    
            int deviceId = int.parse(serialKey.value);  
            NotificationService().showNotification(
              deviceId,
              "$deviceName Alarm Fired!",
              "",
              4,
              [deviceName ,deviceQrcode, c[0].topic, inde].toString(),
            );
            print(serialKey);
          }
          if (pt == 'ALM_RESET') {
            alarm[serialKey.value] = false;
          }
          if (pt == "LOC_CON_STS") {
            testTimer[serialKey.value] = DateTime.now().millisecondsSinceEpoch;
            testboolDict[serialKey.value] = true;
          }
        }
      }
    });
  }
 
  void onSubscribed(String topic) {
    print('Succeffully Sercribed');
  }

  publish_message(MqttServerClient c) {
    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello from mqtt_client');
    c.publishMessage('topic/sha256', MqttQos.atLeastOnce, builder.payload!);
  }

  Future<void> onDisconnected() async {
    broker_conn.value = false;

    print('OnDisconnected client callback - Client disconnection');
    if (client.connectionStatus!.disconnectionOrigin ==
        MqttDisconnectionOrigin.solicited) {
      print('OnDisconnected callback is solicited, this is correct');
    } else {
      print(
          'OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
      return null;
    }
    if (pongCount == 3) {
      print('Pong count is correct');
    } else {
      print('Pong count is incorrect, expected 3. actual $pongCount');
    }
  }

  void pong() {
    print(' Ping response client callback invoked');
    pongCount++;
  }

  void onConnected() {
    broker_conn.value = true;
    print('OnConnected client callback - Client connection was successful');
  }
}
