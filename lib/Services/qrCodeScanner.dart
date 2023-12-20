import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_mqtt/style/colors.dart';
import 'package:hive_mqtt/views/homePage.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:developer';
import 'firebaseServices.dart';

class QRViewExample extends StatefulWidget {
  const QRViewExample({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final firebaseServicesController fcontroller =
      Get.put(firebaseServicesController());

  @override
  Widget build(BuildContext context) {
  controller?.resumeCamera();

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    var scanArea = (MediaQuery.of(context).size.width < 550 ||
            MediaQuery.of(context).size.height < 550)
        ? 150.0
        : 300.0;

    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: colors().secondry,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  dynamic navigateToHome() async {
          dispose();

    Get.to(
      () => homePage(),
      arguments: result!.code.toString(),
    );
  }
  Future<void> _onQRViewCreated(QRViewController controller) async {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData)   {
      setState(() {
        result = scanData;
        if (result != null) {
          navigateToHome();
        }
      });
    });
  }
  Future<void> _onPermissionSet(
      BuildContext context, QRViewController ctrl, bool p) async {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
 
     controller?.dispose();
    super.dispose();
  }
}

 