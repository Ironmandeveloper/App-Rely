
import 'dart:convert';

List<Devices> welcomeFromJson(String str) => List<Devices>.from(json.decode(str).map((x) => Devices.fromJson(x)));

String welcomeToJson(List<Devices> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Devices {
    Devices({
        required this.sha256,
      required  this.qrcode,
      required  this.count,
      required  this.device,
    });

    String sha256;
    String qrcode;
    String count;
    String device;

    factory Devices.fromJson(Map<String, dynamic> json) => Devices(
        sha256: json["sha256"],
        qrcode: json["qrcode"],
        count: json["count"],
        device: json["device"],
    );

    Map<String, dynamic> toJson() => {
        "sha256": sha256,
        "qrcode": qrcode,
        "count": count,
        "device": device,
    };
}
