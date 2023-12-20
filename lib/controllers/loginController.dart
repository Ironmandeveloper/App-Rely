import 'package:flutter/material.dart';
import 'package:get/get.dart';

class loginController extends GetxController {
  
  RxBool hidePassword = true.obs;
  final usernameTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  final resetEmailTextController = TextEditingController().obs;

}