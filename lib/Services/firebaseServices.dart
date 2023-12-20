import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase/firebase_io.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/hiveMqttServices.dart';
import 'package:hive_mqtt/controllers/loginController.dart';
import 'package:hive_mqtt/controllers/registerController.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/views/productView.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timer_count_down/timer_controller.dart';

import '../views/homePage.dart';
import '../views/login.dart';

class firebaseServicesController extends GetxController {
  final auth = FirebaseAuth.instance;
  final registerController controller = Get.put(registerController());
  final loginController logincontroller = Get.put(loginController());
  RxBool isExceptionEmail = false.obs;
  RxBool isExceptionPass = false.obs;
  RxBool isrExceptionEmail = false.obs;
  RxBool isrExceptionPass = false.obs;
  RxBool lloading = false.obs;
  RxBool rloading = false.obs;
  RxBool regLoading = false.obs;
  RxBool updatenameLoading = false.obs;

  Future<void> signIn(String email, String password) async {
    try {
      await auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((_) async {
        logincontroller.usernameTextController.value.text = '';
        logincontroller.passwordTextController.value.text = '';
        logincontroller.resetEmailTextController.value.text = '';

        saveEmailLocally(email);
        LoggedIn();

        Get.to(homePage());
      });
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar(
        '',
        '',
        titleText: Text(
          'Error ',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
        messageText: Text(
          e.message.toString(),
          style: TextStyle(
              color: Color.fromARGB(255, 242, 225, 223),
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
      );
    }
  }

  dynamic saveDeviceInfoToFirebase(
    email,
    count,
    deviceData,
  ) async {
    try {
      final instance = await FirebaseFirestore.instance;
      var d = await instance.collection('$email').get();

      if (d.docs.isEmpty == true) {
        await FirebaseFirestore.instance
            .collection('configs')
            .doc('config1')
            .set({'threshold_timer_in_secs': '3600'});

        await instance.collection('$email').doc('$count').set(deviceData);
      } else {
        await instance.collection('$email').doc('$count').set(deviceData);
      }
    } on FirebaseClientException catch (e) {
      print(e.message);
    }
  }

  fetchDataFromFirbase() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('$email').get();
      final allData =
          await querySnapshot.docs.map((doc) => doc.data()).toList();

      if (allData.length == 0) {
        delShaKeys();
      }
      //  getDataLocally();
      return allData;
    } on FirebaseException catch (e) {
      print(e.message);
    }
  }
  Future<int> fetchKeyFromFirbase(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection('$email').get();
      final allData =
          await querySnapshot.docs.map((doc) => doc.id).toList();
          int index = allData.indexWhere((element) =>  element == doc );
 
      return index;
    }     catch (e) {
     return 0;
    }
  }

 Future<String> getDeviceName(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("$email")
          .doc('$doc')
          .get();

      return querySnapshot['device'];
    } catch (e) {
      return '';
    }
  }

 Future<String> getDeviceQrcode(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("$email")
          .doc('$doc')
          .get();

      return querySnapshot['qrcode'];
    } catch (e) {
      return '';
    }
  }

 Future<dynamic> getDeviceObject(String doc) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("$email")
          .doc('$doc')
          .get();

      return querySnapshot;
    } catch (e) {
      return '';
    }
  }
Future docIndexFirebase() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
      try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("$email")
          .get();
              final allData =
          await querySnapshot.docs.map((doc) => doc.id ).toList();
          print(allData);
           
    
    } catch (e) {
      return '';
    }
}

  dynamic getDataLocally() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("$email").get();
      final allDatakeys =
          await querySnapshot.docs.map((doc) => doc.id).toList();

      final allData =
          await querySnapshot.docs.map((doc) => doc.data()).toList();

      for (var i = 0; i < allDatakeys.length; i++) {
        await prefs.setString(
            '${allDatakeys[i]}', '${allData[i]['sha256']}_Listen');
        if (broker_conn.value == true) {
          client.subscribe(
              '${allData[i]['sha256']}_Listen', MqttQos.atLeastOnce);
          client.subscribe('${allData[i]['sha256']}_Send', MqttQos.atLeastOnce);
        }
      }
    } catch (e) {}
  }

  getDocsLenght() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("$email").get();
      final allDatakeys =
          await querySnapshot.docs.map((doc) => doc.id).toList();
      int dataKey = 0;
      if (allDatakeys.length != 0) {
        dataKey = int.parse(allDatakeys.last);
      }
      print('LENGHT OF DOCS IN FOREBASE===============');

      return dataKey;
    } catch (e) {}
  }

  dynamic getShaList() async {
    await getDataLocally();
    List sha256List = [];
    final prefs = await SharedPreferences.getInstance();
    List keys = prefs.getKeys().toList();
    print(keys);
    for (var i = 0; i < keys.length; i++) {
      if (keys[i]! == 'Login' ||
          keys[i]! == 'count' ||
          keys[i]! == 'qrcode' ||
          keys[i]! == 'sha256' ||
          keys[i]! == 'email') {
        continue;
      } else {
        sha256List.add(prefs.getString(keys[i]));
      }
    }
    return sha256List;
  }

  dynamic getSpecificShaList(String shakey) async {
    String serialKey = '';
    var dict = <String, String>{};
    final prefs = await SharedPreferences.getInstance();
    List keys = prefs.getKeys().toList();
    print(keys);
    for (var i = 0; i < keys.length; i++) {
      if (keys[i]! == 'Login' ||
          keys[i]! == 'count' ||
          keys[i]! == 'qrcode' ||
          keys[i]! == 'sha256' ||
          keys[i]! == 'email') {
        continue;
      } else {
        dict[keys[i]] = prefs.getString(keys[i]).toString();
      }
    }
    print(dict);
    dict.forEach((key, value) {
      if (value == shakey) {
        serialKey = key;
      }
    });

    return serialKey;
  }

  dynamic getShaKeys() async {
    await getDataLocally();
    List sha256KeysList = [];
    final prefs = await SharedPreferences.getInstance();
    List keys = prefs.getKeys().toList();

    for (var i = 0; i < keys.length; i++) {
      if (keys[i]! == 'Login' ||
          keys[i]! == 'count' ||
          keys[i]! == 'qrcode' ||
          keys[i]! == 'sha256' ||
          keys[i]! == 'email') {
        continue;
      } else {
        sha256KeysList.add(keys[i]);
      }
    }
    print(sha256KeysList);

    return sha256KeysList;
  }

  void delShaKeys() async {
    final prefs = await SharedPreferences.getInstance();
    List keys = prefs.getKeys().toList();

    for (var i = 0; i < keys.length; i++) {
      if (keys[i]! == 'Login' ||
          keys[i]! == 'count' ||
          keys[i]! == 'qrcode' ||
          keys[i]! == 'sha256' ||
          keys[i]! == 'email') {
        continue;
      } else {
        prefs.remove(keys[i]);
      }
    }
  }

  Future deleteProductFromFireBase(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      await FirebaseFirestore.instance
          .collection('$email')
          .doc('$key')
          .delete();

      return true;
    } catch (e) {}
  }

  Future updateProductNameFromFireBase(String key, String name) async {
    updatenameLoading.value = true;
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      await FirebaseFirestore.instance
          .collection('$email')
          .doc('$key')
          .update({'device': '$name'}).then((value) => {});
    } catch (e) {}
  }

  getDataAndSaveItlocally() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');
    try {
      final querySnapshot =
          await FirebaseFirestore.instance.collection("$email").get();
      final allData =
          await querySnapshot.docs.map((doc) => doc.data()).toList();
      final listShakeys = <String>[];
      final listQrcodes = <String>[];

      for (var i = 0; i < allData.length; i++) {
        listShakeys.add(allData[i]['sha256']);
        if (broker_conn.value == true) {
          client.subscribe(
              '${allData[i]['sha256']}_Listen', MqttQos.atLeastOnce);
          client.subscribe('${allData[i]['sha256']}_Send', MqttQos.atLeastOnce);
        }
        listQrcodes.add(allData[i]['qrcode']);
      }

      await prefs.setStringList('sha256', listShakeys);
      await prefs.setStringList('qrcode', listQrcodes);
    } catch (e) {}
    ;
  }

  dynamic saveEmailLocally(String email) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('email', email);
  }

  dynamic LoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('Login', true);
  }

  dynamic checkNullCollection() async {
    final prefs = await SharedPreferences.getInstance();
    final email = await prefs.getString('email');

    final snaps = await FirebaseFirestore.instance.collection('$email').get();
    if (await snaps.size == 0) {
      nullCheckBool.value = true;
    } else {
      nullCheckBool.value = false;
    }
  }

  Future<bool> checkCollection() async {
    if (checkNullCollection() == true) {
      return true;
    } else {
      return false;
    }
  }

  dynamic signUp(
    String email,
    String password,
  ) async {
    try {
      await auth
          .createUserWithEmailAndPassword(email: email, password: password)
          .then((_) {
        controller.emailTextController.value.text = '';
        controller.passwordTextController.value.text = '';
        controller.usernameTextController.value.text = '';
        controller.phoneTextController.value.text = '';
        saveEmailLocally(email);
        LoggedIn();
        Get.to(() => homePage());
      });
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar(
        '',
        '',
        titleText: Text(
          'Error',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
        messageText: Text(
          e.message.toString(),
          style: TextStyle(
              color: Color.fromARGB(255, 242, 225, 223),
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
      );
    }
  }

  dynamic logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.clear();
    testboolDict.clear();
    testTimer.clear();
    alarm.clear();

    Get.to(() => login());
  }

  dynamic forgetPassword(email) async {
    try {
      await auth.sendPasswordResetEmail(email: email.toString().trim());
      Get.back();
    } on FirebaseException catch (e) {
      Get.snackbar(
        '',
        '',
        titleText: Text(
          'Error ',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 19),
        ),
        margin: EdgeInsets.only(bottom: 20, left: 10, right: 10),
        snackPosition: SnackPosition.BOTTOM,
        colorText: Colors.red,
        messageText: Text(
          e.message.toString(),
          style: TextStyle(
              color: Color.fromARGB(255, 242, 225, 223),
              fontWeight: FontWeight.bold,
              fontSize: 17),
        ),
      );
    }
  }
}
