
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///详细历史数据
class DetailHistoryDataPage extends StatefulWidget {
  const DetailHistoryDataPage({Key? key}) : super(key: key);

  @override
  State<DetailHistoryDataPage> createState() => _DetailHistoryDataPageState();
}

class _DetailHistoryDataPageState extends State<DetailHistoryDataPage> {
  /// 1 步数 2 睡眠
  int mode = 1;

  ///0:读最近的步数详细数据
  int modeStart=0;
  ///2：继续上次读的位置下一段数据
  int modeContinue=2;
  ///99: 删除步数详细数据
  int modeDelete=0x99;

  List<Map> list = [];

  int dataCount = 0;

  TextEditingController dateController = TextEditingController();

  String time = "";

  AppAllValueController controller = Get.find();

  @override
  void initState() {
    super.initState();
    dateController.text = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2,'0')}-${DateTime.now().day.toString().padLeft(2,'0')} ${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}:${DateTime.now().second.toString().padLeft(2,'0')}';
    EventBus().on('dataCallBack', (arg){
      Map map = arg;
      bool finish = map[DeviceKey.End];
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.GetDetailActivityData:
        case BleConst.GetDetailSleepData:
        print('map:${map.toString()}');
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
              getDetailData(modeContinue,time);
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
  void getDetailData(int status,String time){
    controller.writeData((mode == 1)?BleSDK.GetDetailActivityDataWithModeForTime(status,time):BleSDK.GetDetailSleepDataWithModeForTime(status,time));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("详细历史数据".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Radio(value: mode, groupValue: 1, onChanged: (value){
                setState(() {
                  mode = 1;
                });
              },),
              Text('步数'.tr),
              Radio(value: mode, groupValue: 2, onChanged: (value){
                setState(() {
                  mode = 2;
                });
              }),
              Text('睡眠'.tr),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('读取所有数据'.tr),
                  onPressed: (){
                    Future.delayed(Duration.zero,(){
                      controller.showLoadDialog('同步中'.tr);
                    });
                    list = [];
                    time = "";
                    getDetailData(modeStart,time);
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('删除'.tr),
                  onPressed: (){
                    getDetailData(modeDelete,time);
                  },
                ),
              ))
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('  ${'日期'.tr} '),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: dateController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  // inputFormatters: [
                  //   FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  // ],
                ),
              ),
            ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10,left: 10),
                child: ElevatedButton(
                  child: Text('根据时间获取数据'.tr),
                  onPressed: (){
                    if(dateController.text.isNotEmpty && dateController.text.length == 19){
                      Future.delayed(Duration.zero,(){
                        controller.showLoadDialog('同步中'.tr);
                      });
                      list = [];
                      time = "";
                      time = dateController.text;
                      getDetailData(modeStart,time);
                    }
                  },
                ),
              )),
              // Expanded(child: Container(
              //   margin: const EdgeInsets.only(right: 10),
              //   child: ElevatedButton(
              //     child: Text('清空'.tr),
              //     onPressed: (){
              //     },
              //   ),
              // ))
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
