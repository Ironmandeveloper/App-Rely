import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/NotificationService.dart';
import 'package:hive_mqtt/Services/hiveMqttServices.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:hive_mqtt/views/splashScreen.dart';
MqttServices services = MqttServices();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotificationService().initNotification();
  await Firebase.initializeApp();
   ErrorWidget.builder = (FlutterErrorDetails details) => Container();
   services.connection();                                              
   await Locales.init(['en', 'it']);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return LocaleBuilder(builder: (context) {
      return GetMaterialApp(
          locale: context,
          localizationsDelegates: Locales.delegates,
          supportedLocales: Locales.supportedLocales,
          debugShowCheckedModeBanner: false,
          home: splashScreen());
    });
  }
}
