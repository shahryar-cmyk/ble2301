
import 'dart:async';

import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


///健康测量控制
class HealthMeasurementPage extends StatefulWidget {
  const HealthMeasurementPage({Key? key}) : super(key: key);

  @override
  State<HealthMeasurementPage> createState() => _HealthMeasurementPageState();
}

class _HealthMeasurementPageState extends State<HealthMeasurementPage> {

  int mode = 1;
  bool enable = false;

  AppAllValueController controller = Get.find();

  String text = '';

  late int _currentSeconds;
  //The manual detection command will only execute for 30 seconds.
  // If you want to continue executing, you need to use a timer to
  // continue sending the command
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map map = arg;
      switch(map[DeviceKey.DataType] as String){
        case BleConst.MeasurementHrvCallback:
        case BleConst.MeasurementHeartCallback:
        case BleConst.MeasurementOxygenCallback:
        case BleConst.MeasurementTempCallback:
        case BleConst.StopMeasurementHrvCallback:
        case BleConst.StopMeasurementHeartCallback:
        case BleConst.StopMeasurementOxygenCallback:
        case BleConst.StopMeasurementTempCallback:
          setState(() {
            text = map.toString();
          });
          break;
        case BleConst.RealTimeStep:
          Map maps = {};
          maps.addAll({DeviceKey.HeartRate:map[DeviceKey.Data][DeviceKey.HeartRate]});
          maps.addAll({DeviceKey.Blood_oxygen:map[DeviceKey.Data][DeviceKey.Blood_oxygen]});
          setState(() {
            text = maps.toString();
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

  ///start countdown
  void startTimer(){
    _currentSeconds = 29;
    if(_timer == null){
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _currentSeconds--;
        if(_currentSeconds <= 0){
          _currentSeconds = 29;
          controller.writeData(BleSDK.HealthMeasurementWithDataType(mode,enable));
        }
      });
    }else{
      _timer!.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        _currentSeconds--;
        if(_currentSeconds <= 0){
          _currentSeconds = 29;
          controller.writeData(BleSDK.HealthMeasurementWithDataType(mode,enable));
        }
      });
    }
  }
  ///End Countdown
  void stopTimer(){
    if(_timer != null){
      _currentSeconds = 0;
      _timer!.cancel();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("健康测量控制".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Radio(value: mode, groupValue: 2, onChanged: (value){
                setState(() {
                  mode = 2;
                });
              }),
              Text('心率'.tr),
              Radio(value: mode, groupValue: 3, onChanged: (value){
                setState(() {
                  mode = 3;
                });
              }),
              Text('血氧'.tr),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('开关'.tr),
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: Switch(
                  value: enable,
                  onChanged: (flag){
                    setState(() {
                      enable = flag;
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
                  child: Text('开启实时计步'.tr),
                  onPressed: (){
                    controller.writeData(BleSDK.RealTimeStep(true,false));
                  },
                ),
              )),
            ],
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('发送'.tr),
                  onPressed: (){
                    controller.writeData(BleSDK.HealthMeasurementWithDataType(mode,enable));
                    if(enable){
                      startTimer();
                    }else{
                      stopTimer();
                    }
                  },
                ),
              )),
            ],
          ),
          Container(
            margin: const EdgeInsets.only(left: 10,right: 10),
            child: Text(text),
          )
        ],
      ),
    );
  }
}
