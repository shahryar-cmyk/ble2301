

import 'dart:async';

import 'package:ble2301/ble_sdk.dart';
import 'package:ble2301/utils/ble_const.dart';
import 'package:ble2301/utils/device_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/app_all_value.dart';
import '../util/event_bus.dart';

class PpgInfoPage extends StatefulWidget{
  const PpgInfoPage ({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PpgPageState();

}

class _PpgPageState extends State<PpgInfoPage>{

  AppAllValueController controller = Get.find();
  Timer? timer;
  int second = 0;
  int allSecond = 300;
  double baifen = 0.0;
  int banfenValue = 0;
  List<Map> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("血糖".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10,top: 10),
            child: Text('${'进度'.tr}：${banfenValue.toInt()}%',style: const TextStyle(fontSize: 25),),
          ),
          Container(
            margin: EdgeInsets.only(left: 10,right: 10,top: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(child: Expanded(child: ElevatedButton(
                  child: Text('开始测量'.tr),
                  onPressed: (){
                    start();
                  },
                )),margin: const EdgeInsets.only(right: 10),),
                Expanded(child: ElevatedButton(
                  child: Text('结束测量'.tr),
                  onPressed: (){
                    end();
                  },
                )),
              ],
            ),
          ),
          Expanded(child: list.isEmpty?Container(
            alignment: Alignment.center,
            child: Text('无数据'.tr),
          ):ListView.builder(
              padding: const EdgeInsets.only(top: 10),
              shrinkWrap: true,
              itemCount: list.length,
              itemBuilder: (context,index){
                return Container(
                  padding: const EdgeInsets.only(left: 10,right: 10,top: 10),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Text(list[index].toString()),
                      Container(
                        height: 1,
                        color: Colors.grey,
                      )
                    ],
                  ),
                );
              }
          ))
        ],
      ),
    );
  }

  ///开始测量
  void start(){
    controller.writeData(BleSDK.startBloodSugar());
  }

  void progress(int progress){
    controller.writeData(BleSDK.progressBloodSugar(progress));
  }

  ///结束测量
  void end(){
    controller.writeData(BleSDK.endBloodSugar());
  }

  void startCount(){
    if(timer != null){
      timer?.cancel();
      timer = null;
    }
    list.clear();
    second = 0;
    baifen = 0.0;
    banfenValue = 0;
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      second++;
      if(second > allSecond){
        second = 0;
        endCount();
        return;
      }
      baifen = second / allSecond * 100;
      if(baifen > 99){
        baifen = 100;
      }
      // print('banfenValue: ${baifen}');
      setState(() {
        banfenValue = baifen.toInt();
      });
      controller.writeData(BleSDK.progressBloodSugar(banfenValue));
    });
  }

  void endCount(){
    if(timer != null){
      timer?.cancel();
    }
    setState(() {
    });
  }


  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg)
    {
      Map map = arg;
      bool finish = map[DeviceKey.End];
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.BoolsugarStatus:
          Map data = map[DeviceKey.Data] as Map;
          int flag = data[DeviceKey.EcgStatus];
          switch(flag){
            case 1:
              startCount();
              break;
            case 2:break;
            case 3:
              endCount();
              break;
            case 4:break;
            case 5:break;
          }
          break;
        case BleConst.BoolsugarValue:
          list.insert(0, map[DeviceKey.Data] as Map);
          break;
      }
    });
  }
}