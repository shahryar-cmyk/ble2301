
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

///温度历史
class TempHistoryPage extends StatefulWidget {
  const TempHistoryPage({Key? key}) : super(key: key);

  @override
  State<TempHistoryPage> createState() => _TempHistoryPageState();
}

class _TempHistoryPageState extends State<TempHistoryPage> {

  ///1 主页面 2 测试页面
  int mode = 1;

  ///0:读最近的步数详细数据
  int modeStart=0;
  ///2：继续上次读的位置下一段数据
  int modeContinue=2;
  ///99: 删除步数详细数据
  int modeDelete=0x99;

  List<String> list = [];

  int dataCount = 0;

  AppAllValueController controller = Get.find();

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg){
      Map map = arg;
      bool finish = map[DeviceKey.End];
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.GetAxillaryTemperatureDataWithMode:
        case BleConst.Temperature_history:
          list.add(map.toString());
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
      }}
    );
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }


  ///获取数据
  void getDetailData(int status){
    controller.writeData(mode == 1?BleSDK.GetAxillaryTemperatureDataWithMode(status,""):BleSDK.GetTemperature_historyDataWithMode(status,""));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("温度历史".tr),
        ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10,left: 10),
                child: ElevatedButton(
                  child: Text('获取温度数据(测试页面)'.tr),
                  onPressed: (){
                    mode = 2;
                    Future.delayed(Duration.zero,(){
                      controller.showLoadDialog('同步中'.tr);
                    });
                    list = [];
                    getDetailData(modeStart);
                  },
                ),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10,left: 10),
                child: ElevatedButton(
                  child: Text('删除数据'.tr),
                  onPressed: (){
                    getDetailData(modeDelete);
                  },
                ),
              ))
            ],
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
}
