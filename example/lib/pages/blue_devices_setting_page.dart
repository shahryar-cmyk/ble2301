
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301/ble_sdk.dart';
import 'package:ble2301/utils/ble_const.dart';
import 'package:ble2301/utils/ble_const.dart';
import 'package:ble2301/utils/device_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/app_all_value.dart';
import '../util/event_bus.dart';

//关闭蓝牙
class BlueDevicesSettingPage extends StatefulWidget{
  const BlueDevicesSettingPage ({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() =>_blueDevicesSettingState();
}

class _blueDevicesSettingState extends State<BlueDevicesSettingPage>{
  AppAllValueController controller = Get.find();
  var resultData="";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("蓝牙设置"),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          ElevatedButton(
            child: Text('关闭蓝牙'),
            onPressed: (){
              Future.delayed(Duration.zero,(){
                controller.showLoadDialog('同步中'.tr);
                closeDevices();
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            alignment: Alignment.center,
            child: Text(resultData.tr),
          )
        ],
      ),
    );
  }

  ///关闭设备
  void closeDevices(){
    controller.writeData(BleSDK.CloseBlueDevice());
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }

  List<Map> list = [];

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg)
    {
      Map map = arg;
      bool finish = map[DeviceKey.End];
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.CloseDevices:
          var valueMap=map[DeviceKey.Data] as Map<dynamic,dynamic>;
          if(finish){
            controller.dismissDialog();
          }
          setState(() {
            resultData=valueMap.toString();
          });

          break;
      }
    });
  }
}