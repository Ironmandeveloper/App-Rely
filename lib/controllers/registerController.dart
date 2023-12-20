 import 'package:flutter/material.dart';
import 'package:get/get.dart';

class registerController extends GetxController {
  
  RxBool hidePassword = true.obs;
  final usernameTextController = TextEditingController().obs;
  final editProductName = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  final phoneTextController = TextEditingController().obs;
  final  emailTextController = TextEditingController().obs;
}