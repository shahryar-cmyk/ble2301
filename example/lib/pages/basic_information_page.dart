
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';


///基础信息页面
class BasicInformationPage extends StatefulWidget {
  const BasicInformationPage({Key? key}) : super(key: key);

  @override
  State<BasicInformationPage> createState() => _BasicInformationPageState();
}

class _BasicInformationPageState extends State<BasicInformationPage> {

  AppAllValueController controller = Get.find();

  TextEditingController ageController = TextEditingController();//年龄
  TextEditingController heightController = TextEditingController();//身高
  TextEditingController weightController = TextEditingController();//体重
  TextEditingController strideController = TextEditingController();//步长

  bool sex = false;

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map map = arg;
      switch(map[DeviceKey.DataType] as String){
        case BleConst.GetDeviceTime:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.SetDeviceTime:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.GetPersonalInfo:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.SetPersonalInfo:
          controller.showContentDialog(map.toString());
          break;

      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAllValueController>(
      init: controller,
        builder: (controller){
          return Scaffold(
            appBar: AppBar(
              title: Text("基础信息".tr),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(left: 10,right: 10),
                      child: ElevatedButton(
                        child: Text('设置手环时间'.tr),
                        onPressed: (){
                          DateTime dateTime = DateTime.now();
                          controller.writeData(BleSDK.SetDeviceTime(dateTime));
                        },
                      ),
                    )),
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        child: Text('获取手环时间'.tr),
                        onPressed: (){
                          controller.writeData(BleSDK.GetDeviceTime());
                        },
                      ),
                    ))
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 10,bottom: 10),
                  alignment: Alignment.center,
                  child: Text('基础信息设置'.tr),
                ),
                Row(
                  children: [
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(left: 10,right: 10),
                      child: ElevatedButton(
                        onPressed: null,
                        child: Text('性别'.tr),
                      ),
                    )),
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('男'.tr),
                          Switch(
                            value: sex,
                            onChanged: (flag){
                              setState(() {
                                sex = flag;
                              });
                            },
                          ),
                          Text('女'.tr),
                        ],
                      ),
                    ))
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text('年龄'.tr),
                        ),
                        TextField(
                          controller: ageController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                          ],
                        )
                      ],
                    )),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text('身高'.tr),
                        ),
                        TextField(
                          controller: heightController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                          ],
                        )
                      ],
                    )),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text('体重'.tr),
                        ),
                        TextField(
                          controller: weightController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                          ],
                        )
                      ],
                    )),
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: Text('步长'.tr),
                        ),
                        TextField(
                          controller: strideController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[0-9]')),//只允许输入数
                          ],
                        )
                      ],
                    ))
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(left: 10,right: 10),
                      child: ElevatedButton(
                        child: Text('设置个人信息'.tr,textAlign: TextAlign.center,),
                        onPressed: (){
                          if(ageController.text.isEmpty){
                            controller.showContentDialog('没有输入年龄'.tr);
                            return;
                          }
                          if(heightController.text.isEmpty){
                            controller.showContentDialog('没用输入身高'.tr);
                            return;
                          }
                          if(weightController.text.isEmpty){
                            controller.showContentDialog('没有输入体重'.tr);
                            return;
                          }
                          var info = MyPersonalInfo(sex: sex?0:1,
                              age: int.parse(ageController.text),
                              height: int.parse(heightController.text),
                              weight: int.parse(weightController.text));
                          if(strideController.text.isNotEmpty){
                            info.stepLength = int.parse(strideController.text);
                          }
                          controller.writeData(BleSDK.SetPersonalInfo(info));
                        },
                      ),
                    )),
                    Expanded(child: Container(
                      margin: const EdgeInsets.only(right: 10),
                      child: ElevatedButton(
                        child: Text('获取个人信息'.tr,textAlign: TextAlign.center,),
                        onPressed: (){
                          controller.writeData(BleSDK.GetPersonalInfo());
                        },
                      ),
                    ))
                  ],
                ),
              ],
            ),
          );
        }
    );
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }
}
