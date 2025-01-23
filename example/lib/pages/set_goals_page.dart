
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

///设置目标
class SetGoalsPage extends StatefulWidget {
  const SetGoalsPage({Key? key}) : super(key: key);

  @override
  State<SetGoalsPage> createState() => _SetGoalsPageState();
}

class _SetGoalsPageState extends State<SetGoalsPage> {

  var stepController = TextEditingController();
  var stepTimeController = TextEditingController();
  var distanceController = TextEditingController();
  var calorieController = TextEditingController();
  var sleepHourController = TextEditingController();
  var sleepMinuteController = TextEditingController();

  AppAllValueController controller = Get.find();

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map maps = arg;
      Map data = maps[DeviceKey.Data];
      switch(maps[DeviceKey.DataType] as String){
        case BleConst.SetStepGoal:
          controller.showContentDialog(maps.toString());
          break;
        case BleConst.GetStepGoal:
          String goal = data[DeviceKey.StepGoal];
          stepController.text = goal;
          String distance = data[DeviceKey.DistanceGoal];
          distanceController.text = distance;
          String calorie = data[DeviceKey.CalorieGoal];
          calorieController.text = calorie;
          String sleepTime = data[DeviceKey.SleepTimeGoal];
          int time = int.parse(sleepTime);
          sleepHourController.text = (time ~/ 60).toString();
          sleepMinuteController.text = (time % 60).toString();
          break;
      }
    });
  }


  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("设置目标".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('目标步数(步)'.tr),
                Expanded(child: TextField(
                  controller: stepController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '2000-50000'
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                ))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('目标距离(千米)'.tr),
                Expanded(child: TextField(
                  controller: distanceController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: '1-200'
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                ))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('卡路里(千卡)'.tr),
                Expanded(child: TextField(
                  controller: calorieController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: '100-10000'
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                ))
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('睡眠目标'.tr),
                Expanded(child: TextField(
                  controller: sleepHourController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: '小时'.tr
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                )),
                Expanded(child: TextField(
                  controller: sleepMinuteController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                      hintText: '分钟'.tr
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                ))
              ],
            ),
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('设置'.tr),
                  onPressed: (){
                    if(stepController.text.isEmpty)return;
                    if(distanceController.text.isEmpty)return;
                    if(calorieController.text.isEmpty)return;
                    if(sleepHourController.text.isEmpty)return;
                    if(sleepMinuteController.text.isEmpty)return;
                    int step = int.parse(stepController.text);
                    int dayMinute = 3600;
                    int distance = int.parse(distanceController.text);
                    int calorie = int.parse(calorieController.text);
                    int sleepHour = int.parse(sleepHourController.text);
                    int sleepMinute = int.parse(sleepMinuteController.text);
                    int allTime = sleepHour * 60 + sleepMinute;
                    controller.writeData(BleSDK.SetStepGoal(step,dayMinute,distance,calorie,allTime));
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('获取'.tr),
                  onPressed: (){
                    controller.writeData(BleSDK.GetStepGoal());
                  },
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }
}
