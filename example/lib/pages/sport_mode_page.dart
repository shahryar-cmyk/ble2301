
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../util/app_all_value.dart';
import '../util/event_bus.dart';
import 'package:ble2301/ble2301_plugin.dart';

///运动模式页面
class SportModePage extends StatefulWidget {
  const SportModePage({Key? key}) : super(key: key);

  @override
  State<SportModePage> createState() => _SportModePageState();
}

class _SportModePageState extends State<SportModePage> {

  int mode = 0;


  static const int Status_START=1;
  static const int Status_PAUSE=2;
  static const int Status_CONTUINE=3;
  static const int Status_FINISH=4;


  List<String> sportTitle = [
    '跑步','骑车','羽毛球','足球','网球','瑜伽'
    ,'呼吸','舞蹈','篮球','郊游野游','锻炼','板球'
    ,'徒步旅行','有氧运动','乒乓球','跳绳','仰卧起坐','排球'
  ];
  AppAllValueController controller = Get.find();

  Timer? timer;
  int second = 0;
  //默认 0
  int status = 0;

  String content = "";


  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map maps = arg;
      switch(maps[DeviceKey.DataType] as String){
        case BleConst.EnterActivityMode:
          Map data = maps[DeviceKey.Data];
          if(data.isNotEmpty){
            int heart = int.parse(data[DeviceKey.HeartRate]);
            //运动停止
            if(heart == 255){
              endSport();
            }
          }
          setState(() {
            content = maps.toString();
          });
          break;
      }

    });

  }

  void startSport(){
    if(status == 0 || status == 4){
      second = 0;
      controller.writeData(BleSDK.EnterActivityMode(mode,Status_START));
      timer = Timer.periodic(const Duration(seconds: 1),(timer){
        // print('value-second:${second}');
        second++;
        if(second >= 1){
          controller.writeData(BleSDK.sendHeartPackage(0, second, 2));
        }
      });
      status = 1;

    }
  }

  void pauseSport(){
    if(status == 1 || status == 3){
      controller.writeData(BleSDK.EnterActivityMode(mode,Status_PAUSE));
      if(timer != null){
        timer!.cancel();
        timer = null;
      }
      status = 2;

    }
  }

  void continueSport(){
    if(status == 2){
      controller.writeData(BleSDK.EnterActivityMode(mode,Status_CONTUINE));
      timer = Timer.periodic(const Duration(seconds: 1),(timer){
        second++;
        if(second >= 1){
          controller.writeData(BleSDK.sendHeartPackage(0, second, 2));
        }
      });
      status = 3;
    }
  }

  void endSport(){
    if(status == 1 || status == 3){
      controller.writeData(BleSDK.EnterActivityMode(mode,Status_FINISH));
      if(timer != null){
        timer!.cancel();
        timer = null;
        second = 0;
      }
      status = 4;
    }

  }


  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
    endSport();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("运动模式".tr),
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3,childAspectRatio: 4/1),
            shrinkWrap: true,
            itemBuilder: (context,index){
              return buildRadioWidget(index,sportTitle[index]);
            },
            itemCount: sportTitle.length,
          ),
          Row(
            children: [
              Expanded(child: Container(
                margin: const EdgeInsets.only(left: 10,right: 10),
                child: ElevatedButton(
                  child: Text('开始'.tr),
                  onPressed: (){
                    startSport();
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('停止'.tr),
                  onPressed: (){
                    endSport();
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
                  child: Text('暂停'.tr),
                  onPressed: (){
                    pauseSport();
                  },
                ),
              )),
              Expanded(child: Container(
                margin: const EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  child: Text('继续'.tr),
                  onPressed: (){
                    continueSport();
                  },
                ),
              ))
            ],
          ),
          Container(
            margin: const EdgeInsets.only(top: 10,left: 10,right: 10),
            child: Text('$content'),
          )
        ],
      ),
    );
  }


  Widget buildRadioWidget(int index,String text){
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Radio(
          value: mode,
          activeColor: Colors.blue, //选中时的颜色
          onChanged:(value){
            if(value != null){
              setState(() {
                mode = index;
              });
            }
          }, groupValue: index ,
        ),
        Text(text.tr)
      ],
    );
  }
}
