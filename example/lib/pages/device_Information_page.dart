import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ble2301/ble2301_plugin.dart';

///设备信息页面
class DeviceInformationPage extends StatefulWidget {
  const DeviceInformationPage({Key? key}) : super(key: key);

  @override
  State<DeviceInformationPage> createState() => _DeviceInformationPageState();
}

class _DeviceInformationPageState extends State<DeviceInformationPage> {
  AppAllValueController controller = Get.find();

  @override
  void initState() {
    super.initState();
    EventBus().on('dataCallBack', (arg) {
      Map map = arg;
      switch (map[DeviceKey.DataType] as String) {
        case BleConst.GetDeviceBatteryLevel:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.CMD_MCUReset:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.GetDeviceMacAddress:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.GetDeviceVersion:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.GetDeviceInfo:
          controller.showContentDialog(map.toString());
          break;
        case BleConst.SetDeviceInfo:
          controller.showContentDialog(map.toString());
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("设备信息".tr),
        ),
        body: ListView(
          shrinkWrap: false,
          padding: const EdgeInsets.only(top: 0),
          children: [
            Row(
              children: [
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    child: Text('初始化'.tr),
                    onPressed: () {
                      controller.showContentDialogTitle(
                          '提示'.tr, '出厂重置将清除设备中的所有数据，请确认是否要重置？'.tr,
                          onConfirm: () {
                        controller.writeData(BleSDK.Reset());
                      });
                    },
                  ),
                )),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    child: Text('电量'.tr),
                    onPressed: () {
                      controller.writeData(BleSDK.GetDeviceBatteryLevel());
                    },
                  ),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    child: Text('蓝牙Mac地址'.tr),
                    onPressed: () {
                      controller.writeData(BleSDK.GetDeviceMacAddress());
                    },
                  ),
                )),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    child: Text('固件版本'.tr),
                    onPressed: () {
                      controller.writeData(BleSDK.GetDeviceVersion());
                    },
                  ),
                ))
              ],
            ),
            Row(
              children: [
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(left: 10, right: 10),
                  child: ElevatedButton(
                    child: Text('MCU重启'.tr),
                    onPressed: () {
                      controller.writeData(BleSDK.MCUReset());
                    },
                  ),
                )),
                Expanded(
                    child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: ElevatedButton(
                    child: Text('进入升级模式'.tr),
                    onPressed: () {
                      controller.writeData(BleSDK.enterOTA());
                    },
                  ),
                ))
              ],
            ),
          ],
        ));
  }

  @override
  void dispose() {
    super.dispose();
    EventBus().off('dataCallBack');
  }
}
