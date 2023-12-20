import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/Services/firebaseServices.dart';
import 'package:hive_mqtt/Services/hiveMqttServices.dart';
import 'package:hive_mqtt/controllers/registerController.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/style/textStyle.dart';
import 'package:hive_mqtt/views/info.dart';
import 'package:hive_mqtt/views/productView.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../Services/qrCodeScanner.dart';
import '../main.dart';
import 'package:timezone/data/latest.dart' as tz;

bool internet_connection = false;
int devices = 1;
var testTimer = <String, int>{}.obs;
var testboolDict = <String, bool>{}.obs;
var alarm = <String, bool>{}.obs;

RxString serialKey = ''.obs;

RxBool nullCheckBool = false.obs;
RxBool visible = false.obs;

class homePage extends StatefulWidget {
  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> with WidgetsBindingObserver {
  bool _isInForeground = true;

  var data = Get.arguments;
  RxBool delLoader = false.obs;
  String sha256_string = '';
  String qr_code = '';
  int shaIndex = 0;
  int ind = 0;
  final registerController controller = Get.put(registerController());
  Future<int> configThreshold() async {
    var s = await FirebaseFirestore.instance
        .collection('configs')
        .doc('config1')
        .get();

    int i = int.parse(s.data()!['threshold_timer_in_secs']);
    return i;
  }

  final firebaseServicesController fcontroller =
      Get.put(firebaseServicesController());

  dynamic getDataToUpload() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('email');
    int lenght;
    lenght = await fcontroller.getDocsLenght();
    lenght++;
    print(lenght);
    final map = {
      'sha256': '$sha256_string',
      'qrcode': '$qr_code',
      'device': 'Device ${devices}',
      'count': '$lenght',
      'time': '${DateTime.now()}'
    };
    await fcontroller
        .saveDeviceInfoToFirebase(
          email,
          lenght,
          map,
        )
        .then((_) => {
              alarm['$lenght'] = false,
              testTimer['$lenght'] = 0,
              testboolDict['$lenght'] = false,
            });
  }

  _scale() {
    return Center(
      child: Container(
        margin: EdgeInsets.only(bottom: 100),
        child: DefaultTextStyle(
            style: textStyle().bodyC, child: LocaleText('nodevice')),
      ),
    );
  }

  Future getProductDetails() async {
    if (internet_connection == true && broker_conn.value == true) {
      var productModel = await fcontroller.fetchDataFromFirbase();
      fcontroller.getDataLocally();
      return productModel;
    }
  }

  subscribe_topic() async {
    final prefs = await SharedPreferences.getInstance();
    final lis;
    lis = await prefs.getStringList('sha256') ?? [];
    for (var i = 0; i < lis.length; i++) {
      await client.subscribe('${lis[i]}_Listen', MqttQos.atLeastOnce);
      await client.subscribe('${lis[i]}_Send', MqttQos.atLeastOnce);
    }
  }

  dynamic covertIntoSHA256() async {
    var bytes1 = utf8.encode(data); // data being hashed
    var digest1 = sha256.convert(bytes1);
    setState(() {
      sha256_string = digest1.toString();
      qr_code = data;
    });
  }

  dynamic incrimentDeviesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int devicesCount = 1;
    setState(() {
      devicesCount = prefs.getInt('count') ?? 0;
      devicesCount++;
      devices = devicesCount;
      prefs.setInt('count', devicesCount);
    });
  }

  dynamic decrimentDeviesCount() async {
    final prefs = await SharedPreferences.getInstance();
    int devicesCount = 0;
    setState(() {
      devicesCount = prefs.getInt('count') ?? 0;
      devicesCount--;
      print(devicesCount);
      devices = devicesCount;
      prefs.setInt('count', devicesCount);
    });
  }

  Future<void> _checkConnectivityState() async {
    final ConnectivityResult result = await Connectivity().checkConnectivity();
    if (result == ConnectivityResult.wifi) {
      setState(() {
        internet_connection = true;
      });
    } else if (result == ConnectivityResult.mobile) {
      setState(() {
        internet_connection = true;
      });
    } else {
      setState(() {
        internet_connection = false;
      });
    }
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      elevation: 0,
      shape: CircleBorder(),
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 140),
      content: Container(
        child: CircularProgressIndicator(
          color: colors().secondry,
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void loading() {
    showLoaderDialog(context);
    new Future.delayed(new Duration(milliseconds: 1000), () {
      Navigator.pop(context); //pop dialog
    });
  }

  gettinDeviceCheck() async {
    await Future.delayed(const Duration(milliseconds: 4000), () {
      visible.value = true;
    });
  }

  createDicts() async {
    List serialKeys = await fcontroller.getShaKeys();
    var l = await serialKeys
      ..sort();

    print(l);
    for (var i = 0; i < serialKeys.length; i++) {
      alarm[l[i]] = false;
      testboolDict[l[i]] = false;
      testTimer[l[i]] = 0;
    }
  }

  checkBoolState() async {
    List serialKeys = await fcontroller.getShaKeys();
    var l = serialKeys;

    if (serialKeys.length > 0) {
      for (var i = 0; i < testboolDict.values.toList().length; i++) {
        if (testboolDict[l[i]] == true && testTimer[l[i]]! > 0) {
          int currTime = DateTime.now().millisecondsSinceEpoch;
          int threshold = await configThreshold() * 1000;
          print(threshold);
          var d = testTimer[l[i]]! + threshold;
          if (currTime > d) {
            testboolDict[l[i]] = false;
          }
        }
      }
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    tz.initializeTimeZones();
    gettinDeviceCheck();
    if (data == null) {
      createDicts();
    }
    Timer.periodic(Duration(seconds: 3), (timer) {
      if (internet_connection == true) {
        checkBoolState();
      }
      _checkConnectivityState();
    });

    if (data != null) {
      incrimentDeviesCount();
      getDataToUpload();
      covertIntoSHA256();
      gettinDeviceCheck();
    }
    // TODO: implement initState
    super.initState();
  }

  Widget konnect(context) {
    services.connection();
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: SizedBox(
          height: 25,
          width: 25,
          child: CircularProgressIndicator(color: colors().secondry)),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isInForeground = state == AppLifecycleState.resumed;
    if (state == AppLifecycleState.resumed) {
      if (internet_connection == true && broker_conn.value == false) {
        services.connection();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
       Get.to(() => info());
              },
              icon: Icon(
                Icons.info_sharp,
                color: colors().secondry,
                size: 30,
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: IconButton(
                onPressed: () async {
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
                                onPressed: () async {
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
          color: colors().backGround,
          child: Column(
            children: [
              SizedBox(
                height: 10,
              ),
              SizedBox(
                height: 30,
              ),
           
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: LocaleText(
                      'g',
                      style: textStyle().bodyB,
                    ),
                  ),
                  internet_connection == true && broker_conn.value == false
                      ? konnect(context)
                      : Container(
                          margin: EdgeInsets.only(right: 30),
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              color: broker_conn.value == true &&
                                      internet_connection == true
                                  ? Colors.green
                                  : broker_conn.value == false &&
                                          internet_connection == false
                                      ? Colors.red.shade700
                                      : Colors.red.shade700,
                              shape: BoxShape.circle),
                        ),
                ],
              ),
              SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: LocaleText(
                      'products',
                      style: textStyle().h2,
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      Get.to(() => QRViewExample());
                      visible.value = false;
                    },
                    child: Align(
                      alignment: Alignment.topRight,
                      child: new Container(
                        height: 45.0,
                        width: 62,
                        color: Colors.transparent,
                        child: new Container(
                          decoration: new BoxDecoration(
                              color: colors().secondry,
                              borderRadius: new BorderRadius.only(
                                bottomLeft: const Radius.circular(700.0),
                                topLeft: const Radius.circular(700.0),
                              )),
                          child: Icon(
                            Icons.camera_alt,
                            color: colors().grey,
                            size: 35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
              ),
              internet_connection == true && broker_conn.value == false
                  ? Padding(
                      padding: EdgeInsets.only(top: 200),
                      child: Text(
                        'Broker Connection Failed',
                        style: textStyle().bodyB,
                      ))
                  : internet_connection == false && broker_conn.value == false
                      ? Padding(
                          padding: EdgeInsets.only(top: 200),
                          child: Text(
                            'Internet Connection Failed',
                            style: textStyle().bodyB,
                          ))
                      : Expanded(
                          child: Container(
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: colors().backGround,
                              ),
                              child: FutureBuilder(
                                future: getProductDetails(),
                                builder: (BuildContext context,
                                    AsyncSnapshot snapshot) {
                                  if (!snapshot.hasData) {
                                    return Center(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 100),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  } else if (snapshot.hasData &&
                                      snapshot.data.length == 0 &&
                                      visible.value == true) {
                                    return _scale();
                                  } else if (snapshot.hasData &&
                                      snapshot.data.length != 0 &&
                                      delLoader == false) {
                                    return ListView.builder(
                                        itemCount: snapshot.data.length,
                                        itemBuilder: (context, index) {
                                          return Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    SizedBox(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .only(
                                                          left: 20,
                                                          top: 15,
                                                          bottom: 5,
                                                          right: 20,
                                                        ),
                                                        child: Row(
                                                          children: [
                                                            Row(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Container(
                                                                  width: 110,
                                                                  padding: const EdgeInsets
                                                                          .only(
                                                                      top: 10,
                                                                      bottom:
                                                                          10),
                                                                  child: Row(
                                                                    children: [
                                                                      Flexible(
                                                                        child:
                                                                            RichText(
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          strutStyle:
                                                                              StrutStyle(fontSize: 12.0),
                                                                          text:
                                                                              TextSpan(
                                                                            style:
                                                                                textStyle().h1W,
                                                                            text:
                                                                                '${snapshot.data[index]['device']}',
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                                SizedBox(),
                                                              ],
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 0,
                                                                      right: 0),
                                                              child: IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.defaultDialog(
                                                                      backgroundColor:
                                                                          colors()
                                                                              .backGround,
                                                                      title: 'edit'
                                                                          .localize(
                                                                              context),
                                                                      middleText:
                                                                          'editd'
                                                                              .localize(context),
                                                                      middleTextStyle:
                                                                          TextStyle(
                                                                              color: colors().primary),
                                                                      titleStyle:
                                                                          textStyle()
                                                                              .bodyS,
                                                                      actions: [
                                                                        Padding(
                                                                          padding: const EdgeInsets.only(
                                                                              left: 30,
                                                                              right: 30),
                                                                          child:
                                                                              TextField(
                                                                            style:
                                                                                TextStyle(
                                                                              color: colors().primary,
                                                                              fontSize: 20,
                                                                            ),
                                                                            controller:
                                                                                controller.editProductName.value,
                                                                            decoration:
                                                                                InputDecoration(
                                                                              enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white70)),
                                                                              focusedBorder: UnderlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                color: colors().secondry,
                                                                              )),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        Align(
                                                                          alignment:
                                                                              Alignment.center,
                                                                          child:
                                                                              InkWell(
                                                                            onTap:
                                                                                () async {
                                                                              if (controller.editProductName.value.text != '') {
                                                                                final docId = await snapshot.data[index]['count'];
                                                                                print(docId);
                                                                                await fcontroller.updateProductNameFromFireBase('$docId', controller.editProductName.value.text);
                                                                                controller.editProductName.value.text = '';
                                                                                Get.back();
                                                                              }
                                                                            },
                                                                            child: Container(
                                                                                margin: EdgeInsets.only(bottom: 7, top: 15),
                                                                                height: 50,
                                                                                width: 50,
                                                                                decoration: BoxDecoration(color: colors().secondry, shape: BoxShape.circle),
                                                                                child: Icon(
                                                                                  Icons.check,
                                                                                  size: 35,
                                                                                  color: colors().backGround,
                                                                                )),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  },
                                                                  icon: Icon(
                                                                    Icons.edit,
                                                                    color: colors()
                                                                        .secondry,
                                                                  )),
                                                            ),
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      left: 10,
                                                                      right:
                                                                          10),
                                                              child: IconButton(
                                                                  onPressed:
                                                                      () {
                                                                    Get.to(
                                                                        () =>
                                                                            productView(),
                                                                        arguments: [
                                                                          '${snapshot.data[index]['device']}',
                                                                          '${snapshot.data[index]['qrcode']}',
                                                                          '${snapshot.data[index]['sha256']}',
                                                                          '$index'  
                                                                        ]);
                                                                    print(
                                                                        index);
                                                                  },
                                                                  icon: Icon(
                                                                    Icons
                                                                        .arrow_forward_ios,
                                                                    color: colors()
                                                                        .primary,
                                                                  )),
                                                            ),
                                                            IconButton(
                                                                onPressed:
                                                                    () async {
                                                                  Get.defaultDialog(
                                                                    title: 'deletel'
                                                                        .localize(
                                                                            context),
                                                                    middleText:
                                                                        '',
                                                                    titleStyle:
                                                                        TextStyle(
                                                                      color: colors()
                                                                          .primary,
                                                                    ),
                                                                    backgroundColor:
                                                                        colors()
                                                                            .backGround,
                                                                    actions: [
                                                                      Card(
                                                                        elevation:
                                                                            0,
                                                                        color: colors()
                                                                            .backGround,
                                                                        child:
                                                                            Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceAround,
                                                                          children: [
                                                                            TextButton(
                                                                                onPressed: () async {
                                                                                  delLoader.value = true;

                                                                                  final prefs = await SharedPreferences.getInstance();
                                                                                  final docId = await snapshot.data[index]['count'];
                                                                                  await fcontroller.deleteProductFromFireBase('$docId').then((_) => {
                                                                                        alarm.remove('$docId'),
                                                                                        testboolDict.remove('$docId'),
                                                                                        testTimer.remove('$docId'),
                                                                                        prefs.remove('$docId'),
                                                                                      });
                                                                                  Get.back();

                                                                                  await Future.delayed(Duration(seconds: 1));
                                                                                  delLoader.value = false;
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
                                                                  Icons.delete,
                                                                  color: colors()
                                                                      .secondry,
                                                                )),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          right: 30, top: 12),
                                                      height: 12,
                                                      width: 12,
                                                      decoration: BoxDecoration(
                                                        color: internet_connection == true &&
                                                                broker_conn
                                                                        .value ==
                                                                    true &&
                                                                testboolDict.values
                                                                            .toList()[
                                                                        index] ==
                                                                    true &&
                                                                testboolDict[
                                                                        serialKey
                                                                            .value] ==
                                                                    true
                                                            ? Colors.green
                                                            : Colors.red,
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 10, right: 10),
                                                  child: Divider(
                                                    height: 2,
                                                    thickness: 1,
                                                    color: colors().grey,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        });
                                  } else {
                                    return Center(
                                      child: Container(
                                        margin: EdgeInsets.only(bottom: 100),
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              )),
                        ),
            ],
          ),
        ),
      ),
    );
  }
}
// else if (snapshot.connectionState ==
//                           ConnectionState.waiting) {
//                         return Center(
//                             child: CircularProgressIndicator(
//                           color: Colors.white,
//                         ));
//                       }  else if (snapshot.requireData == true){
//                         return showLoaderDialog(context);
//                       }
