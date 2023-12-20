import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/views/homePage.dart';
import 'package:hive_mqtt/views/login.dart';
import 'package:shared_preferences/shared_preferences.dart';


class  splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => _splashScreenState();
}
class _splashScreenState extends State<splashScreen> {
 dynamic setionChecking() async {
    final prefs = await SharedPreferences.getInstance();
  var log =   prefs.getBool('Login',);
  print(log);
  if(log == true){
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>   homePage()),
  );
  }
  else{
    Navigator.push(
    context,
    MaterialPageRoute(builder: (context) =>   login()),
  );
   }
  }
  
  @override
  void initState() {
 
     Timer(Duration(seconds: 2),
          ()=> setionChecking()
                                       
         );
    // TODO: implement initState
    super.initState();

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: Get.height,
        
        child:  Image.asset('assets/Rely farfalla.png',
        fit: BoxFit.fitHeight,
        ),
      ),
    );
  }
}