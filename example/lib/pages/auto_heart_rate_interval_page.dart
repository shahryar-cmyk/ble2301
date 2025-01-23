
import 'package:ble2301/ble2301_plugin.dart';
import 'dart:math';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

///自动心率区间页面
class AutoHeartRateIntervalPage extends StatefulWidget {
  const AutoHeartRateIntervalPage({Key? key}) : super(key: key);

  @override
  State<AutoHeartRateIntervalPage> createState() => _AutoHeartRateIntervalPageState();
}

class _AutoHeartRateIntervalPageState extends State<AutoHeartRateIntervalPage> {
  ///0 关闭  1 一直开启 2 间隔开启
  int mode = 0;

  int startHour = 0;
  int startMinute = 0;
  int endHour = 0;
  int endMinute = 0;
  ///1、设置心率 2、设置血氧 3、设置温度 4、HRV测量
  int type = 1;

  List<int> weeks = [0,0,0,0,0,0,0];

  var minuteController = TextEditingController();

  AppAllValueController controller = Get.find();


  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map map = arg;
      switch(map[DeviceKey.DataType] as String){
        case BleConst.SetAutomaticHRMonitoring:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.GetAutomaticHRMonitoring:
          Map data = map[DeviceKey.Data] as Map;
          int startHour = int.parse(data[DeviceKey.StartTime] as String);
          int startMin = int.parse(data[DeviceKey.KHeartStartMinter] as String);
          int endHour = int.parse(data[DeviceKey.EndTime] as String);
          int endMin = int.parse(data[DeviceKey.KHeartEndMinter] as String);
          String timeInterval = data[DeviceKey.IntervalTime] as String;
          String week = data[DeviceKey.Weeks] as String;
          List<String> weekStrings = week.split("-");
          for (int i = 0; i < 7; i++) {
            weeks[i] = int.parse(weekStrings[i]);
          }
          setState(() {
            mode = int.parse(data[DeviceKey.WorkMode] as String);
            this.startHour = startHour;
            startMinute = startMin;
            this.endHour = endHour;
            endMinute = endMin;
            minuteController.text = timeInterval;
          });
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
        title: Text("自动心率区间".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Radio(value: mode, groupValue: 0, onChanged: (value){
                setState(() {
                  mode = 0;
                });
              },),
              Text('关闭'.tr),
              Radio(value: mode, groupValue: 1, onChanged: (value){
                setState(() {
                  mode = 1;
                });
              }),
              Text('一直开启'.tr),
              Radio(value: mode, groupValue: 2, onChanged: (value){
                setState(() {
                  mode = 2;
                });
              }),
              Text('间隔开启'.tr),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Radio(value: type, groupValue: 1, onChanged: (value){
                setState(() {
                  type = 1;
                });
              },),
              Text('心率'.tr),
              Radio(value: type, groupValue: 2, onChanged: (value){
                setState(() {
                  type = 2;
                });
              }),
              Text('血氧'.tr),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Radio(value: type, groupValue: 3, onChanged: (value){
                setState(() {
                  type = 3;
                });
              }),
              Text('温度'.tr),
              Radio(value: type, groupValue: 4, onChanged: (value){
                setState(() {
                  type = 4;
                });
              }),
              Text('Hrv'.tr),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('开始时间'.tr),
                  onPressed: (){
                    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value){
                        if(value != null){
                         setState(() {
                           startHour = value.hour;
                           startMinute = value.minute;
                         });
                        }
                    });
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('结束时间'.tr),
                  onPressed: (){
                    showTimePicker(context: context, initialTime: TimeOfDay.now()).then((value){
                      if(value != null){
                        setState(() {
                          endHour = value.hour;
                          endMinute = value.minute;
                        });
                      }
                    });
                  },
                ),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('$startHour:$startMinute'),
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  onPressed:null,
                  child: Text('$endHour:$endMinute'),
                ),
              ))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10,bottom: 5),
            alignment: Alignment.center,
            child: Text('星期选择'.tr),
          ),
          GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 4/1),
              shrinkWrap: true,
              children: [
                buildWeekWidget(0,"周日".tr),
                buildWeekWidget(1,"周一".tr),
                buildWeekWidget(2,"周二".tr),
                buildWeekWidget(3,"周三".tr),
                buildWeekWidget(4,"周四".tr),
                buildWeekWidget(5,"周五".tr),
                buildWeekWidget(6,"周六".tr),
              ],
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Text('  ${'间隔时间'.tr} '),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: minuteController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.next,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                  ],
                ),
              ),
              Text('分钟'.tr),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('获取'.tr),
                  onPressed: (){
                    controller.writeData(BleSDK.GetAutomaticHRMonitoring(type));
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('设置'.tr),
                  onPressed: (){
                    if(minuteController.text.isEmpty) return;
                    int hourStart = startHour;
                    int minStart = startMinute;
                    int hourEnd = endHour;
                    int minEnd = endMinute;
                    int minInterval = int.parse(minuteController.text);
                    int week = 0;
                    for (int i = 0; i < 7; i++) {
                      if (weeks[i] == 1) {
                        week += pow(2, i).toInt();
                      }
                    }
                    var info = MyAutomaticHRMonitoring(
                        open: mode, //0 关闭  1 一直开启 2 间隔开启
                        startHour: hourStart,
                        startMinute: minStart,
                        endHour: hourEnd,
                        endMinute: minEnd,
                        week: week, time: minInterval,
                        type: type
                    );
                    controller.writeData(BleSDK.SetAutomaticHRMonitoring(info));
                  },
                ),
              ))
            ],
          ),
        ],
      ),
    );
  }



  Widget buildWeekWidget(int index,String text){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Checkbox(
          value: weeks[index] == 1,
          activeColor: Colors.blue, //选中时的颜色
          onChanged:(value){
            if(value != null){
              setState(() {
                weeks[index] = value?1:0;
              });
            }
          } ,
        ),
        Text(text)
      ],
    );
  }
}
