
import 'dart:io';
import 'package:ble2301_example/main_page.dart';
import 'package:ble2301_example/models.dart';
import 'package:ble2301_example/util/app_all_value.dart';
import 'package:ble2301_example/util/shared_preferences_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

///搜索设备页面
class ScanPage extends StatefulWidget {
  const ScanPage({Key? key}) : super(key: key);

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage>{
  ///定位开关状态
  bool locationEnable = false;
  ///蓝牙开关状态
  bool bluetoothEnable = false;
  ///语言状态
  bool isCh = true;
  ///设备列表
  List<BlueInfo> blueinfos = [];
  ///全局变量
  AppAllValueController controller = Get.put(AppAllValueController());
  ///输入监听器
  TextEditingController textEditingController = TextEditingController();
  ///过滤
  String filler = "";

  @override
  void initState() {
    super.initState();
    SpUtils.init().then((value){
      initPermission();
    });
  }

  ///显示过滤弹窗
  void showFilterDialog(){
    textEditingController.text = SpUtils.getString("filler");
    showDialog(context: context,
        builder: (context){
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: GestureDetector(
          child: Container(
            alignment: Alignment.center,
            color: Colors.transparent,
            child: Container(
              width: 400,
              height: 200,
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: 40,
                    color: Colors.blue,
                    child: Text('Filler',style: TextStyle(color: Colors.white),),
                  ),
                  TextField(
                    controller: textEditingController,
                    textAlign: TextAlign.center,
                    onChanged: (text){
                      SpUtils.putString("filler", text);
                    },
                  )
                ],
              ),
            ),
          ),
          onTap: (){
            Get.back();
          },
        ),
      );
    });
  }

  ///初始化权限
  void initPermission() async {
    if(Platform.isAndroid){
      initLocationPermission();
    }else{//IOS权限
      FlutterBlueElves.instance.iosCheckBluetoothState().then((value) {
        print('iosCheckBluetoothState: ${value.toString()}');
        if(value==IosBluetoothState.unKnown){
          ///Bluetooth is not initialized
        }else if(value==IosBluetoothState.resetting){
          ///Bluetooth is resetting
        }else if(value==IosBluetoothState.unSupport){
          ///Bluetooth not support
        }else if(value==IosBluetoothState.unAuthorized){
          ///No give bluetooth permission
        }else if(value==IosBluetoothState.poweredOff){
          ///bluetooth powerOff
        }else{
          ///bluetooth is ok
          startScan();
        }
      });
    }
  }
  ///初始化定位权限
  void initLocationPermission(){
    //判断是否有定位权限
    FlutterBlueElves.instance.androidApplyLocationPermission((isOk) async {
      if(!isOk){
        PermissionStatus locationStatus = await Permission.location.status;
        if (locationStatus.isDenied) {
          if (await Permission.location.request().isGranted) {
            initBluetoothPermission();
          }
        }
      }else{
        initBluetoothPermission();
      }
    });

  }
  ///初始化蓝牙权限
  void initBluetoothPermission(){
    //判断是否有蓝牙权限
    FlutterBlueElves.instance.androidApplyBluetoothPermission((isOk) async {
      if(!isOk){
        PermissionStatus bluetoothStatus = await Permission.bluetooth.status;
        PermissionStatus bluetoothConnectStatus = await Permission.bluetoothConnect.status;
        PermissionStatus bluetoothScanStatus = await Permission.bluetoothScan.status;
        if (bluetoothStatus.isDenied) {
          await Permission.bluetooth.request();
        }
        if (bluetoothConnectStatus.isDenied) {
          await Permission.bluetoothConnect.request();
        }
        if (bluetoothScanStatus.isDenied) {
          await Permission.bluetoothScan.request();
        }
      }
      initBlueUtil();
    });
  }
  ///蓝牙工具权限判断
  void initBlueUtil(){
    FlutterBlueElves.instance.androidCheckBlueLackWhat().then((values) {
      if(values.contains(AndroidBluetoothLack.bluetoothPermission)){
        ///no bluetooth permission,if your target is android 12
        print("no bluetooth permission");
        return;
      }
      if(values.contains(AndroidBluetoothLack.locationPermission)){
        ///no location permission
        print("no location permission");
        return;
      }
      if(values.contains(AndroidBluetoothLack.locationFunction)){//定位开关
        ///location powerOff
        FlutterBlueElves.instance.androidOpenLocationService((isOk){
          if(isOk){
            locationEnable = true;
          }else{
            locationEnable = false;
          }
        });
      }else{
        locationEnable = true;
      }
      if(values.contains(AndroidBluetoothLack.bluetoothFunction)){//蓝牙开关
        ///bluetooth powerOff
        FlutterBlueElves.instance.androidOpenBluetoothService((isOk){
          if(isOk){
            bluetoothEnable = true;
          }else{
            bluetoothEnable = false;
          }
        });
      }else{
        bluetoothEnable = true;
      }
      startScan();
    });
  }

  ///开始搜索设备
  void startScan(){
    if(!controller.isScan){
      controller.setIsScan(true);
    }else{
      return;
    }
    setState(() {
      blueinfos = [];
    });
    filler = SpUtils.getString("filler");
    // print("搜索设备开始");
    FlutterBlueElves.instance.startScan(10000).listen((ScanResult scanItem) {
      // print("deviceMac: ${scanItem.macAddress}");
      addDevices(scanItem);
    },onDone: (){
      print("搜索设备内部结束");
      controller.setIsScan(false);
    },onError: (e){
      print("搜索设备内部异常");
      controller.setIsScan(false);
    },cancelOnError: false).onDone(() {
      print("搜索设备结束");
      controller.setIsScan(false);
    });
  }
  ///添加设备
  void addDevices(ScanResult item){
    String? name = Platform.isAndroid?item.name:item.localName;
    String? mac = Platform.isAndroid?item.macAddress:item.id;
    if(name == null){
      return;
    }
    // print('name:$name filler:$filler flag:${!name.contains(filler)}');
    if(filler.isNotEmpty){
      if(!name.contains(filler)){
        // print('name:${!name.contains(filler)}');
        return;
      }
    }
    bool flag = false;
    for(int i = 0; i < blueinfos.length; i++){
      if(blueinfos[i].mac == mac){
        flag = true;
        blueinfos[i].name = name;
        blueinfos[i].rssi = item.rssi;
        break;
      }
    }
    if(!flag){
      BlueInfo info = BlueInfo(name: name, rssi: item.rssi, mac: mac,result: item);
      blueinfos.add(info);
    }
    setState(() {
      blueinfos.sort(((a, b) => b.rssi!.compareTo(a.rssi!)));
    });
  }
  ///构建设备Item布局
  Widget buildDeviceItem(int index){
    return GestureDetector(
      child: Container(
        color: Colors.white,
        height: 60,
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.only(left: 10,top: 5),
              alignment: Alignment.topLeft,
              child: Text(blueinfos[index].name??"No Name",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),),
            ),
            Container(
              margin: const EdgeInsets.only(left: 10,bottom: 5),
              alignment: Alignment.bottomLeft,
              child: Text('mac: ${blueinfos[index].mac??"No Mac"}',style: TextStyle(fontSize: 14)),
            ),
            Container(
              margin: const EdgeInsets.only(right: 10,bottom: 5),
              alignment: Alignment.bottomRight,
              child: Text('rssi: ${blueinfos[index].rssi??"No Rssi"}',style: TextStyle(fontSize: 14)),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 1,
                color: Colors.grey,
              ),
            )
          ],
        ),
      ),
      onTap: (){
          FlutterBlueElves.instance.stopScan();
          controller.setSearchResult(blueinfos[index].result!);
          Get.to(MainPage(mac: blueinfos[index].mac,name: blueinfos[index].name,));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppAllValueController>(
        init: controller,
        builder: (controller){
          return Scaffold(
            appBar: AppBar(
              //导航栏
              title: Text("1939W测试Demo".tr),
              actions: <Widget>[
                Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 120,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [//isScan
                      controller.isScan?Container(
                        width: 25,
                        height: 25,
                        margin: EdgeInsets.only(right: 20),
                        child: CircularProgressIndicator(
                          strokeWidth: 3.0,
                          backgroundColor: Colors.blue,
                          valueColor:const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ):Container(
                        width: 25,
                        height: 25,
                        margin: EdgeInsets.only(right: 20),
                      ),
                      GestureDetector(
                        child: Container(
                          color: Colors.transparent,
                          height: 40,
                          alignment: Alignment.center,
                          child: Text(controller.isScan?'停止'.tr:'搜索'.tr,style: TextStyle(fontSize: 15,color: Colors.white),),
                        ),
                        onTap: (){
                          print("按键状态-isScan: ${controller.isScan}");
                          if(controller.isScan){
                            FlutterBlueElves.instance.stopScan();
                          }else{
                            startScan();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  child: Container(
                    margin: EdgeInsets.only(left: 10,right: 20),
                    color: Colors.transparent,
                    height: 40,
                    alignment: Alignment.center,
                    child: const Text('Filter',style: TextStyle(fontSize: 15,color: Colors.white),),
                  ),
                  onTap: (){
                    showFilterDialog();
                    // print("按键状态-isCh: ${isCh}");
                    // if(isCh){
                    //   var locale = Locale('en', 'US');
                    //   Get.updateLocale(locale);
                    //   isCh = false;
                    // }else{
                    //   var locale = Locale('zh', 'CN');
                    //   Get.updateLocale(locale);
                    //   isCh = true;
                    // }
                  },
                ),
              ],
            ),
            body: ListView.builder(
                padding: const EdgeInsets.only(top: 0),
                shrinkWrap: false,
                itemCount: blueinfos.length,
                itemBuilder: (context,index){
                  return buildDeviceItem(index);
                }),
          );
    });
  }

}
