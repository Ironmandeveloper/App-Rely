import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_mqtt/Services/firebaseServices.dart';
import 'package:hive_mqtt/controllers/loginController.dart';
import 'package:hive_mqtt/main.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/style/textStyle.dart';
import 'package:hive_mqtt/views/productView.dart';
import 'package:hive_mqtt/views/regitser.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../Services/hiveMqttServices.dart';
import 'homePage.dart';

class login extends StatefulWidget {
  @override
  State<login> createState() => _loginState();
}

class _loginState extends State<login> {
  final loginController controller = Get.put(loginController());

  final firebaseServicesController fcontroller =
      Get.put(firebaseServicesController());
  dynamic payload_login() async {
    final prefs = await SharedPreferences.getInstance();
    var list = prefs.getStringList('sha256') ?? [];
    final builder = MqttClientPayloadBuilder();
    var data = builder.addString('LGIN_ACK');
    for (var i = 0; i < list.length; i++) {
      await client.subscribe('${list[i]}_Send', MqttQos.atLeastOnce);
      await client.publishMessage(
          '${list[i]}_Send', MqttQos.atLeastOnce, data.payload!);

     
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          height: Get.height,
          color: colors().backGround,
          child: ListView(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: Get.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topRight,
                          child: new Container(
                            height: 400.0,
                            width: 500,
                            color: Colors.transparent,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: colors().grey,
                                  borderRadius: new BorderRadius.only(
                                    bottomLeft: const Radius.circular(900.0),
                                  )),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: new Container(
                            height: 250.0,
                            width: 300,
                            color: Colors.transparent,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: colors().grey,
                                  borderRadius: new BorderRadius.only(
                                    topRight: const Radius.circular(500.0),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        LocaleText(
                          'signin',
                          style: textStyle().h1,
                        ),
                        SizedBox(
                          height: 130,
                        ),
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Username',
                                style: textStyle().body,
                              ),
                            ),
                            Obx(
                              () => TextField(
                                  style: TextStyle(
                                    color: colors().secondry,
                                  ),
                                  controller:
                                      controller.usernameTextController.value,
                                  decoration: InputDecoration(
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.white70)),
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(
                                      color: colors().secondry,
                                    )),
                                    errorText:
                                        fcontroller.isExceptionEmail.value ==
                                                true
                                            ? 'Enter a valid Username'
                                            : null,
                                    suffixIcon: IconButton(
                                      color: colors().secondry,
                                      icon: Icon(
                                        Icons.person,
                                      ),
                                      onPressed: () {},
                                    ),
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LocaleText(
                                'password',
                                style: textStyle().body,
                              ),
                            ),
                            Obx(
                              () => TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: TextStyle(
                                  color: colors().secondry,
                                ),
                                controller:
                                    controller.passwordTextController.value,
                                obscureText: controller.hidePassword.value,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: colors().secondry,
                                  )),
                                  errorText: fcontroller.isExceptionPass == true
                                      ? 'Password is empty!'
                                      : null,
                                  suffixIcon: IconButton(
                                    color: colors().secondry,
                                    icon: controller.hidePassword.value
                                        ? Icon(Icons.visibility_off)
                                        : Icon(Icons.visibility),
                                    onPressed: () {
                                      controller.hidePassword.value =
                                          !controller.hidePassword.value;
                                    },
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.defaultDialog(
                                  contentPadding:
                                      EdgeInsets.only(left: 20, right: 20),
                                  titlePadding: EdgeInsets.only(top: 20),
                                  backgroundColor: colors().grey,
                                  title: 'resetpassword'.localize(context),
                                  titleStyle: GoogleFonts.ubuntu(
                                      textStyle: TextStyle(
                                    color: colors().secondry,
                                    fontSize: 17,
                                  )),
                                  middleText: '',
                                  actions: [
                                    Obx(
                                      () => TextField(
                                          style: TextStyle(
                                            color: colors().secondry,
                                          ),
                                          controller: controller
                                              .resetEmailTextController.value,
                                          decoration: InputDecoration(
                                            hintText: ' Email',
                                            hintStyle: TextStyle(
                                                color: colors().secondry),
                                            enabledBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                                    color: Colors.white70)),
                                            focusedBorder: UnderlineInputBorder(
                                                borderSide: BorderSide(
                                              color: colors().secondry,
                                            )),
                                          )),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.send,
                                        color: colors().secondry,
                                      ),
                                      onPressed: () async {
                                        fcontroller.forgetPassword(controller
                                            .resetEmailTextController
                                            .value
                                            .text);
                                      },
                                    ),
                                  ],
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: LocaleText(
                                  "forgotpassword",
                                  style: textStyle().small_under,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                            width: Get.width - 70,
                            padding: EdgeInsets.only(left: 20, right: 20),
                            decoration: BoxDecoration(
                                color: colors().secondry,
                                borderRadius: BorderRadius.circular(10)),
                            child: TextButton(
                                onPressed: () async {
                                  fcontroller.lloading.value = true;
                                  if (fcontroller.lloading.value == true) {
                                    Get.defaultDialog(
                                        title: '',
                                        middleText: '',
                                        backgroundColor: Colors.transparent,
                                        actions: [
                                          CircularProgressIndicator(
                                            color: colors().secondry,
                                          )
                                        ]);
                                  }

                                  GetUtils.isEmail(controller
                                              .usernameTextController
                                              .value
                                              .text) ==
                                          false
                                      ? fcontroller.isExceptionEmail.value =
                                          true
                                      : false;
                                  controller.passwordTextController.value.text
                                              .length <
                                          1
                                      ? fcontroller.isExceptionPass.value = true
                                      : false;

                                  if (fcontroller.isExceptionEmail.value ==
                                          false &&
                                      fcontroller.isExceptionPass.value ==
                                          false) {
                                    fcontroller.signIn(
                                        controller
                                            .usernameTextController.value.text,
                                        controller
                                            .passwordTextController.value.text);
                                  } else {
                                    Get.back();
                                  }

                                  Timer(
                                      const Duration(seconds: 3),
                                      () => {
                                            fcontroller.isExceptionEmail.value =
                                                false,
                                            fcontroller.isExceptionPass.value =
                                                false,
                                          });

                                  await fcontroller.getDataLocally();
                                  await payload_login();
         },
                                child: LocaleText(
                                  'login',
                                  style: textStyle().bodyW,
                                ))),
                        SizedBox(
                          height: 50,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Get.updateLocale(Locale('en'));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 45,
                                    width: 80,
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset('icons/flags/png/gb.png',
                                        package: 'country_icons'),
                                  ),
                                  Text(
                                    'ENG',
                                    style: textStyle().small,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.updateLocale(Locale('it'));
                              },
                              child: Column(
                                children: [
                                  Container(
                                    height: 50,
                                    width: 90,
                                    padding: EdgeInsets.all(10),
                                    child: Image.asset('icons/flags/png/it.png',
                                        package: 'country_icons'),
                                  ),
                                  Text(
                                    'ITA',
                                    style: textStyle().small,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LocaleText(
                              'donthaveanaccount',
                              style: textStyle().small,
                            ),
                            TextButton(
                                onPressed: () {
                                  controller.usernameTextController.value.text =
                                      '';
                                  controller.passwordTextController.value.text =
                                      '';
                                  controller
                                      .resetEmailTextController.value.text = '';
                                  Get.to(() => register());
                                },
                                child: LocaleText(
                                  'register',
                                  style: textStyle().small_under,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
