import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/firebaseServices.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/views/homePage.dart';
import 'package:icons_plus/icons_plus.dart';
import '../style/textStyle.dart';

class info extends StatelessWidget {
  final firebaseServicesController fcontroller =
      Get.put(firebaseServicesController());

      
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colors().backGround,
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
              Get.to(() => homePage());
            },
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: colors().secondry,
              size: 30,
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              onPressed: () {
                Get.defaultDialog(
                  title: 'areyousuretologout'.localize(context),
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
                Icons.input_rounded,
                color: colors().secondry,
                size: 33,
              ),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 30,
            ),
            Center(
              child: LocaleText(
                'name',
                style: textStyle().h2,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: Text(
                'App Rely',
                style: textStyle().bodyB,
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: LocaleText(
                'version',
                style: textStyle().h2,
              ),
            ),
            SizedBox(
              height: 25,
            ),
            Center(
              child: Text(
                'App version 1.9',
                style: textStyle().bodyB,
              ),
            ),
            SizedBox(
              height: 60,
            ),
            Center(
              child: LocaleText(
                'contact',
                style: textStyle().h2,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.center,
              child: Text(
                'info@automation-boards.it',
                style: textStyle().bodyB,
              ),
            ),
            SizedBox(
              height: 95,
            ),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  LocaleText(
                    'byme',
                    style: textStyle().h2,
                  ),
                  Icon(
                    Icons.coffee_rounded,
                    color: colors().secondry,
                    size: 40,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            LocaleText(
              'byusing',
              style: textStyle().bodyB,
            ),
            SizedBox(
              height: 35,
            ),
            IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Card(
                    elevation: 5,
                    shape: CircleBorder(),
                    color: Colors.blue,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesome.paypal,
                        color: Colors.blue.shade800,
                        size: 70,
                      ),
                    ),
                  ),
                  VerticalDivider(
                    color: Colors.white,
                    thickness: 2,
                  ),
                  Card(
                    elevation: 5,
                    shape: CircleBorder(),
                    color: colors().secondry,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        FontAwesome.btc,
                        color: Colors.amber.shade800,
                        size: 70,
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
