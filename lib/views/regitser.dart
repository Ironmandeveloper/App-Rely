import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/firebaseServices.dart';
import 'package:hive_mqtt/controllers/registerController.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/style/textStyle.dart';
import 'package:hive_mqtt/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

class register extends StatelessWidget {
  final registerController controller = Get.put(registerController());
  final firebaseServicesController fcontroller =
      Get.put(firebaseServicesController());

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Container(
          color: colors().backGround,
          child: ListView(
            children: [
              Stack(
                children: [
                  Container(
                    height: Get.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: new Container(
                            height: 400.0,
                            width: Get.width,
                            color: Colors.transparent,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: colors().grey,
                                  borderRadius: new BorderRadius.only(
                                    bottomRight: const Radius.circular(500.0),
                                  )),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: new Container(
                            height: 250.0,
                            width: 300,
                            color: Colors.transparent,
                            child: new Container(
                              decoration: new BoxDecoration(
                                  color: colors().grey,
                                  borderRadius: new BorderRadius.only(
                                    topLeft: const Radius.circular(500.0),
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 30,
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: LocaleText(
                            'register',
                            style: textStyle().h1,
                          ),
                        ),
                        SizedBox(
                          height: 100,
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
                                  suffixIcon: IconButton(
                                    color: colors().secondry,
                                    icon: Icon(
                                      Icons.person,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LocaleText(
                                'email',
                                style: textStyle().body,
                              ),
                            ),
                            Obx(
                              () => TextFormField(
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                controller:
                                    controller.emailTextController.value,
                                style: TextStyle(
                                  color: colors().secondry,
                                ),
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: colors().secondry,
                                  )),
                                  errorText:
                                      fcontroller.isrExceptionEmail.value ==
                                              true
                                          ? 'Enter a valid email'
                                          : null,
                                  suffixIcon: IconButton(
                                    color: colors().secondry,
                                    icon: Icon(
                                      Icons.email,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: LocaleText(
                                'phone',
                                style: textStyle().body,
                              ),
                            ),
                            Obx(
                              () => TextField(
                                style: TextStyle(
                                  color: colors().secondry,
                                ),
                                controller:
                                    controller.phoneTextController.value,
                                decoration: InputDecoration(
                                  enabledBorder: UnderlineInputBorder(
                                      borderSide:
                                          BorderSide(color: Colors.white70)),
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                    color: colors().secondry,
                                  )),
                                  suffixIcon: IconButton(
                                    color: colors().secondry,
                                    icon: Icon(
                                      Icons.phone,
                                    ),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
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
                                  errorText:
                                      fcontroller.isrExceptionPass.value == true
                                          ? 'Enter a valid password'
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
                                  fcontroller.rloading.value = true;
                                  if (fcontroller.rloading.value == true) {
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
                                              .emailTextController
                                              .value
                                              .text) ==
                                          false
                                      ? fcontroller.isrExceptionEmail.value =
                                          true
                                      : false;
                                  controller.passwordTextController.value.text
                                              .length <
                                          6
                                      ? fcontroller.isrExceptionPass.value =
                                          true
                                      : false;

                                  if (fcontroller.isrExceptionEmail.value ==
                                          false &&
                                      fcontroller.isrExceptionPass.value ==
                                          false) {
                                    // final prefs =
                                    //     await SharedPreferences.getInstance();
                                    // prefs.setString(
                                    //     'email',
                                    //     controller
                                    //         .emailTextController.value.text);
                                    fcontroller.signUp(
                                        controller
                                            .emailTextController.value.text,
                                        controller
                                            .passwordTextController.value.text);
                                    // await fcontroller.fetchDataFromFirbase();
                                  } else {
                                    Get.back();
                                  }

                                  Timer(
                                      const Duration(seconds: 3),
                                      () => {
                                            fcontroller.isrExceptionEmail
                                                .value = false,
                                            fcontroller.isrExceptionPass.value =
                                                false,
                                          });
                                },
                                child: LocaleText(
                                  'register',
                                  style: textStyle().bodyW,
                                ))),
                        SizedBox(
                          height: 30,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            LocaleText(
                              'alreadyhaveanaccount',
                              style: textStyle().small,
                            ),
                            TextButton(
                                onPressed: () {
                                  controller.usernameTextController.value.text =
                                      '';
                                  controller.passwordTextController.value.text =
                                      '';
                                  controller.phoneTextController.value.text =
                                      '';
                                  controller.emailTextController.value.text =
                                      '';

                                  Get.to(() => login());
                                },
                                child: LocaleText(
                                  'login',
                                  style: textStyle().small_under,
                                )),
                          ],
                        ),
                        SizedBox(),
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
