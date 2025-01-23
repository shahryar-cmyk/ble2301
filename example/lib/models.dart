
import 'package:flutter/cupertino.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';

///蓝牙设备
///Bluetooth devices
class BlueInfo{
  String? name;
  int? rssi;
  String? mac;
  ScanResult? result;

  BlueInfo({@required this.name,@required this.rssi,@required this.mac,this.result});

}