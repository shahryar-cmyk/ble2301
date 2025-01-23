
import 'package:ble2301/ble_sdk.dart';
import 'package:ble2301/utils/ble_const.dart';
import 'package:ble2301/utils/device_key.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../util/app_all_value.dart';
import '../util/event_bus.dart';

class PPIDataPage extends StatefulWidget{
  const PPIDataPage ({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _PPIDataPageState();
}

class _PPIDataPageState extends State<PPIDataPage>{
  int modeRead= 0;
  AppAllValueController controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //导航栏
        title: Text("PPI数据".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('读取最近的PPI数据'.tr),
                  onPressed: (){
                    Future.delayed(Duration.zero,(){
                      controller.showLoadDialog('同步中'.tr);
                    });
                    list = [];
                    getDetailData(0);
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('获取上段数据'.tr),
                  onPressed: (){
                    Future.delayed(Duration.zero,(){
                      controller.showLoadDialog('同步中'.tr);
                    });
                    list = [];
                    getDetailData(2);
                  },
                ),
              ))
            ],
          ),
          // Container(
          //   margin: const EdgeInsets.only(left: 10,right: 10),
          //   child: ElevatedButton(
          //     child: Text('清空'.tr),
          //     onPressed: (){
          //       Future.delayed(Duration.zero,(){
          //         controller.showLoadDialog('同步中'.tr);
          //       });
          //       list = [];
          //       getDetailData(99);
          //     },
          //   ),
          // ),
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
  int dataCount = 0;
  List<Map> list = [];
  ///2：继续上次读的位置下一段数据
  int modeContinue=2;
  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg)
    {
      Map map = arg;
      bool finish = map[DeviceKey.End];
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.GetPPIData:
          list.addAll(map[DeviceKey.Data] as List<Map>);

          dataCount++;
          if(finish){
            controller.dismissDialog();
            setState(() {
            });
          }
          if(dataCount == 50){
            dataCount = 0;
            if(finish){
              controller.dismissDialog();
              setState(() {
              });
            }else{
              getDetailData(modeContinue);
            }
          }
          break;
      }
    });
  }

  ///获取数据
  void getDetailData(int status){
    controller.writeData(BleSDK.GetPPIDDataWithMode(status));
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }


}