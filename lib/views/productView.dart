import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/hiveMqttServices.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/style/textStyle.dart';
import 'package:hive_mqtt/views/homePage.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:intl/intl.dart';
import '../main.dart';
import 'info.dart';

 

class productView extends StatefulWidget {
  @override
  State<productView> createState() => _productViewState();
}

class _productViewState extends State<productView> with WidgetsBindingObserver {
  int fixedIndex = 0; 
  bool _isInForeground = true;
  final distanceTextController = TextEditingController().obs;
  var data = Get.arguments;
  @override
  void initState() {
    super.initState();
    fixedIndex = int.parse(data[3]);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    if (internet_connection == true && broker_conn.value == false) {
      services.connection();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'App Rely V1.9',
          style: textStyle().h2,
        ),
        elevation: 2,
        automaticallyImplyLeading: false,
        backgroundColor: colors().grey,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(
              Icons.arrow_back_ios,
              color: colors().secondry,
              size: 35,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'Are you sure to logout?',
                  middleText: '',
                  titleStyle: TextStyle(
                    color: colors().primary,
                  ),
                  backgroundColor: colors().backGround,
                  actions: [
                    Card(
                      elevation: 0,
                      color: colors().backGround,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          TextButton(
                              onPressed: () async {
                                fcontroller.logout();
                              },
                              child: LocaleText(
                                'yes',
                                style: textStyle().body,
                              )),
                          TextButton(
                              onPressed: () {
                                Get.back();
                              },
                              child: LocaleText(
                                'no',
                                style: textStyle().body,
                              ))
                        ],
                      ),
                    )
                  ],
                );
              },
              icon: Icon(
                Icons.logout,
                color: colors().secondry,
                size: 35,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: colors().backGround,
      body: Container(
        padding: EdgeInsets.all(20),
        child: ListView(
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: Text(
                '${data[0]}',
                style: textStyle().h1,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Center(
              child: QrImage(
                foregroundColor: Colors.black,
                backgroundColor: Colors.white,
                data: data[1],
                version: QrVersions.auto,
                size: 150.0,
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LocaleText(
                  'connnsts',
                  style: textStyle().h1W,
                ),
                Obx(() => Container(
                      margin: EdgeInsets.only(right: 30),
                      height: 20,
                      width: 20,
                      decoration: BoxDecoration(
                        color: broker_conn.value == true &&
                                internet_connection == true &&
                                testboolDict.values.toList()[fixedIndex] == true &&
                                testboolDict[serialKey.value] == true
                            ? Colors.green
                            : Colors.red.shade700,
                        shape: BoxShape.circle,
                      ),
                    )),
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                LocaleText(
                  'almsts',
                  style: textStyle().h1W,
                ),
                Container(
                  height: 50,
                  width: 50,
                  child: Obx(() => Container(
                        height: 50,
                        width: 50,
                        child: Container(
                          margin: EdgeInsets.only(right: 30),
                          height: 20,
                          width: 20,
                          decoration: BoxDecoration(
                              color: 
                            alarm.values.toList()[fixedIndex] ==
                                          true
                                       ?
                                       Colors.red.shade700 :Colors.white,
                              shape: BoxShape.circle),
                        ),
                      )),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                LocaleText(
                  'setd',
                  style: textStyle().h1W,
                ),
                Obx(
                  () => Container(
                    height: 50,
                    width: 90,
                    child: TextField(
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            height: 1, color: Colors.white, fontSize: 19),
                        controller: distanceTextController.value,
                        decoration: InputDecoration(
                          counterText: '',
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: colors().secondry,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(
                              color: Colors.white,
                              width: 2.0,
                            ),
                          ),
                        )),
                  ),
                ),
              ],
            ),
            //Im not doing anything write
            SizedBox(
              height: 70,
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: InkWell(
                onTap: () async {
                  if (distanceTextController.value.text != '') {
                    final builder = MqttClientPayloadBuilder();
                    int myInteger =
                        await int.parse(distanceTextController.value.text);

                    NumberFormat formatter = new NumberFormat("0000");
                    var p = formatter.format(myInteger);
                    var distPayload = "SET_DIST0x20$p";
                    builder.addString(distPayload);

                    client.publishMessage('${data[2]}_Send',
                        MqttQos.atLeastOnce, builder.payload!);
                    client.published!.listen((MqttPublishMessage message) {});
                  }
                },
                child: Card(
                  elevation: 5,
                  shape: CircleBorder(),
                  color: colors().secondry,
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.arrow_forward,
                      color: colors().grey,
                      size: 40,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
