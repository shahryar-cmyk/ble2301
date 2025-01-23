

import 'package:ble2301/ble_sdk.dart';
import 'package:ble2301/utils/ble_const.dart';
import 'package:ble2301/utils/device_key.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/app_all_value.dart';
import '../util/event_bus.dart';

class HrvTimeInfoPage extends StatefulWidget{
  const HrvTimeInfoPage ({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _hrvTimeInfoPageState();

}

class _hrvTimeInfoPageState extends State<HrvTimeInfoPage>{

  AppAllValueController controller = Get.find();
  var selectValue = "0";
  List<Map> list = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Hrv测量时长".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Center(child: Row(children: [
            Text("Unit(seconds)"),
            DropdownButton(
              value: selectValue,
              items: getMenuList().map((e) => DropdownMenuItem(child: Text(e),value: e,)).toList(), onChanged: (String? value) {
              if(value!=null){
                setState(() {
                  selectValue= value;
                });
              }

            },
            )
          ],),),
          ElevatedButton(
            child: Text('设置时长'.tr),
            onPressed: (){
              Future.delayed(Duration.zero,(){
                controller.showLoadDialog('同步中'.tr);
                setHrvTime(int.parse(selectValue));
              });
            },
          ),
          ElevatedButton(
            child: Text('读取'.tr),
            onPressed: (){
              Future.delayed(Duration.zero,(){
                controller.showLoadDialog('同步中'.tr);
              });
              getHrvTime();
            },
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

  ///获取数据
  void setHrvTime(int time){
    controller.writeData(BleSDK.SetHrvTestTime(time));
  }

  void getHrvTime(){
    controller.writeData(BleSDK.GetHrvTestTime());
  }



  List<String> getMenuList(){
    List<String> list = [];
    for (int i = 0; i < 256; i++) {
      list.add(i.toString());
    }
    return list;
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
        case BleConst.GetHrvTimeValue:
          list.clear();
          var valueMap=map[DeviceKey.Data] as Map<dynamic,dynamic>;
          list.add(valueMap);
          if(finish){
            controller.dismissDialog();
            setState(() {
            });
          }

          break;
      }
    });
  }
}