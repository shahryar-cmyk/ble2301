import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/pages/all_history_data_page.dart';
import 'package:ble2301_example/pages/auto_heart_rate_interval_page.dart';
import 'package:ble2301_example/pages/basic_information_page.dart';
import 'package:ble2301_example/pages/blood_oxygen_data_page.dart';
import 'package:ble2301_example/pages/blue_devices_setting_page.dart';
import 'package:ble2301_example/pages/detail_history_data_page.dart';
import 'package:ble2301_example/pages/device_Information_page.dart';
import 'package:ble2301_example/pages/health_measurement_page.dart';
import 'package:ble2301_example/pages/heart_rate_history_data_page.dart';
import 'package:ble2301_example/pages/hrv_data_page.dart';
import 'package:ble2301_example/pages/hrv_time_info_page.dart';
import 'package:ble2301_example/pages/motion_data_page.dart';
import 'package:ble2301_example/pages/ppi_data_page.dart';
import 'package:ble2301_example/pages/set_goals_page.dart';
import 'package:ble2301_example/pages/temp_history_page.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'pages/ppg_page.dart';
import 'pages/sport_mode_page.dart';


class MainPage extends StatefulWidget {
  ///连接设备的mac值
  String? mac;
  String? name;

  MainPage({Key? key,this.mac,this.name}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with AutomaticKeepAliveClientMixin{

  AppAllValueController controller = Get.find();

  List<String> menus = ['基础信息','设备信息','详细历史数据','总历史数据','心率历史数据',
    '自动心率区间','锻炼数据','Hrv数据','设置目标','血氧数据','温度历史',
    '健康测量控制','运动模式','PPI','Hrv测量时长','关闭蓝牙','血糖'];//

  ///是否开始运动
  bool isStartReal = false;
  ///运动温度开关
  bool isTemp = false;


  String step = '0';
  String calories = '0';
  String distance = '0';
  String time = '0';
  String activityTime = '0';
  String heart = '0';
  String temp = '0';

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map maps = arg;
      switch(maps[DeviceKey.DataType] as String){
        case BleConst.EnterQrCode:
        case BleConst.QrCodeBandBack:
        case BleConst.ExitQrCode:
        case BleConst.GetEcgPpgStatus:
          controller.showContentDialog(maps.toString());
          break;
        case BleConst.EnterActivityMode:
          break;
        case BleConst.EnterPhotoMode:
          controller.showContentDialog(maps.toString());
          break;
        case BleConst.RealTimeStep:
          Map data = maps[DeviceKey.Data];
          setState(() {
            step = data[DeviceKey.Step];
            calories = data[DeviceKey.Calories];
            distance = data[DeviceKey.Distance];
            time = double.parse(data[DeviceKey.ExerciseMinutes]).toStringAsFixed(2);
            activityTime = double.parse(data[DeviceKey.ActiveMinutes]).toStringAsFixed(2);
            heart = data[DeviceKey.HeartRate];
            calories = data[DeviceKey.Calories];
            temp = (double.parse(data[DeviceKey.TempData]) / 10).toStringAsFixed(1);
          });
          break;
        case BleConst.DeviceSendDataToAPP:
          controller.showContentDialog(maps.toString());
          break;
        case BleConst.GetOffCheckStatus:
          controller.showContentDialog(maps.toString());
          break;
      }

    });
    controller.connectDevice();
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
    controller.disConnectDevice();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return GetBuilder<AppAllValueController>(
      init: controller,
        builder: (controller){
          return Scaffold(
            appBar: AppBar(
              //导航栏
              title: Text(widget.name??"No Name"),
              // actions: <Widget>[
              // ],
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Row(
                  children: [
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(right: 5,left: 5),
                      child: ElevatedButton(
                        onPressed: controller.isConnected?null:(){
                          controller.connectDevice();
                        },
                        child: Text('连接设备'.tr),
                      ),
                    ))
                  ],
                ),
                Container(
                  height: 120,
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(left: 5),
                        width: 120,
                        height: 120,
                        child:  ElevatedButton(
                          child: Text(!isStartReal?'开始运动'.tr:'停止'.tr),
                          onPressed: (){
                            setState(() {
                              isStartReal = !isStartReal;
                            });
                            controller.writeData(BleSDK.RealTimeStep(isStartReal,!isStartReal?false:isTemp));
                          },
                        ),
                      ),
                      // Container(
                      //   width: 100,
                      //   child: Column(
                      //     children: [
                      //       Text('温度开关'.tr),
                      //       Switch(value: isTemp, onChanged: (value){
                      //         setState(() {
                      //           isTemp = value;
                      //         });
                      //       })
                      //     ],
                      //   ),
                      // ),
                      Expanded(child: Container(
                        margin: const EdgeInsets.only(left: 10),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Step:  $step step'),
                            Text('Calories:  $calories Kcal'),
                            Text('Distance:  $distance Km'),
                            Text('Time:  $time min'),
                            Text('ActivityTime:  $activityTime min'),
                            Text('Heart Rate:  $heart bpm'),
                            Text('Temp:  $temp ℃'),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
                Expanded(child: GridView.builder(
                    shrinkWrap: true,
                    itemCount: menus.length,
                    padding: const EdgeInsets.only(top: 10,left: 5,right: 5,bottom: 40),
                    gridDelegate:const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2,
                        childAspectRatio: 5/1,crossAxisSpacing: 5,mainAxisSpacing: 5),
                    itemBuilder: (context,index){
                      return ElevatedButton(
                        style:const ButtonStyle(
                            alignment: Alignment.center
                        ),
                        child: Text(menus[index].tr,style: const TextStyle(),textAlign: TextAlign.center,),
                        onPressed: () async {
                          switch(menus[index]){
                            case '基础信息':
                              Get.to(const BasicInformationPage());
                              break;
                            case '设备信息':
                              Get.to(const DeviceInformationPage());
                              break;
                            case '详细历史数据':
                              Get.to(const DetailHistoryDataPage());
                              break;
                            case '总历史数据':
                              Get.to(const AllHistoryDataPage());
                              break;
                            case '心率历史数据':
                              Get.to(const HeartRateHistoryDataPage());
                              break;
                            case '自动心率区间':
                              Get.to(const AutoHeartRateIntervalPage());
                              break;
                            case '锻炼数据':
                              Get.to(const MotionDataPage());
                              break;
                            case 'Hrv数据':
                              Get.to(const HrvDataPage());
                              break;
                            case '设置目标':
                              Get.to(const SetGoalsPage());
                              break;
                            case '血氧数据':
                              Get.to(const BloodOxygenDataPage());
                              break;
                            case '温度历史':
                              Get.to(const TempHistoryPage());
                              break;
                            case '健康测量控制':
                              Get.to(const HealthMeasurementPage());
                              break;
                            case '运动模式':
                              Get.to(const SportModePage());
                              break;
                            case 'PPI':
                              Get.to(const PPIDataPage());
                              break;
                            case 'Hrv测量时长':
                              Get.to(const HrvTimeInfoPage());
                              break;
                            case '关闭蓝牙':
                              Get.to(const BlueDevicesSettingPage());
                              break;
                            case '解密':
                              break;
                            case '血糖':
                              Get.to(const PpgInfoPage());
                          }
                        },
                      );
                    }))
              ],
            ),
          );
        }
    );

  }

  @override
  bool get wantKeepAlive => true;

}
