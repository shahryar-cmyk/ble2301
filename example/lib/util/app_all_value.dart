
import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:ble2301/ble2301_plugin.dart';
import 'package:ble2301_example/util/event_bus.dart';
import 'package:ble2301_example/util/model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_elves/flutter_blue_elves.dart';
import 'package:get/get.dart';
import 'constant.dart';

typedef void BlueUtilDeviceCallBack(ScanResult item);

///全局变量控制器
class AppAllValueController extends GetxController{

  bool _isScan = false;
  ///搜索状态
  bool get isScan => _isScan;
  bool _isConnected = false;
  ///设备连接状态
  bool get isConnected => _isConnected;
  ///蓝牙搜索结果
  ScanResult? result;
  ///设备
  Device? device;
  ///是否手动断开
  bool _manualDisconnection = false;
  ///自动重连次数 2
  int connectCount = 0;
  ///用于字节太长无法一次性发送完
  final linkedList = LinkedList<BlueOffData>();

  StreamSubscription<DeviceState>? deviceStateListener;
  StreamSubscription<BleService>? serviceStateListener;
  StreamSubscription<DeviceSignalResult>? deviceDataListener;


  ///设置是否在搜索中
  void setIsScan(bool flag){
    _isScan = flag;
    update();
  }
  ///设置搜索结果
  void setSearchResult(ScanResult item){
    result = item;
  }
  ///连接设备
  void connectDevice(){
    print("开始连接设备：");
    if(result != null){
      Future.delayed(Duration.zero,(){
        showLoadDialog("连接中".tr);
      });
      device = result!.connect(connectTimeout:10000);
      if(deviceStateListener != null){
        deviceStateListener!.cancel();
        deviceStateListener = null;
      }
      deviceStateListener = device!.stateStream.listen((state) {
        switch(state){
          case DeviceState.connected:
            print("连接设备成功: ");
            _isConnected = true;
            _manualDisconnection = false;
            update();
            connectService();
            break;
          case DeviceState.connecting:
            print("连接设备中");
            EventBus().emit(Constant.BLUEMETHODNAME,Constant.BLUECONNECTING);
            break;
          case DeviceState.connectTimeout:
            print("设备超时");
            break;
          case DeviceState.destroyed:
            break;
          case DeviceState.disConnecting:break;
          case DeviceState.disconnected://断开
          case DeviceState.initiativeDisConnected://手动断开
            print("设备断开");
            _isConnected = false;
            update();
            EventBus().emit(Constant.BLUEMETHODNAME,Constant.BLUEDISCONNECTED);
            Future.delayed(Duration.zero,(){
              dismissDialog();
            });
            if(!_manualDisconnection){//设备自己断开
              if(connectCount <= 2){//开始重连
                connectCount++;
                Future.delayed(const Duration(seconds: 1),(){
                  connectDevice();
                });
              }else{//自动重连3次，连接失败
                connectCount = 0;
                _manualDisconnection = true;
              }
            }else{//手动断开
              if(device != null){
                device == null;
                result == null;
              }
            }

            break;
        }
      });
    }
  }
  ///连接服务
  void connectService(){
    if(device != null){
      print("开始连接服务");
      if(serviceStateListener != null){
        serviceStateListener!.cancel();
        serviceStateListener = null;
      }
      if(serviceStateListener != null){
        serviceStateListener!.cancel();
        serviceStateListener = null;
      }
      serviceStateListener = serviceStateListener = device!.serviceDiscoveryStream.listen((serviceItem) {
        print("连接服务中：${serviceItem.serviceUuid}");
        if(serviceItem.serviceUuid.toLowerCase() == Constant.SERVICE_DATA.toLowerCase()){
          print("找到服务");
          if(serviceItem.characteristics.isNotEmpty){
            print("筛选服务");
            serviceItem.characteristics.forEach((element) {
              print("服务遍历中"+element.uuid);
              if(element.uuid.toLowerCase() == Constant.NOTIY_CHARACTERISTIC.toLowerCase()){
                print("找到特征: serviceUuid ${serviceItem.serviceUuid} characteristicUuid ${element.uuid}");
                device!.setNotify(serviceItem.serviceUuid, element.uuid, true).then((value){
                  print("订阅结果: $value");
                });
                Future.delayed(Duration.zero,(){
                  dismissDialog();
                });
                EventBus().emit(Constant.BLUEMETHODNAME,Constant.BLUECONNECTED);
                return;
              }
            });
          }
        }
      },onError: (e){
        //连接失败-未验证
        print("连接服务异常");
      },onDone: (){
        print("连接服务结束");
      });
      device!.discoveryService();
      ///返回数据
      if(deviceDataListener != null){
        deviceDataListener!.cancel();
        deviceDataListener = null;
      }
      deviceDataListener = device!.deviceSignalResultStream.listen((result) {
        print("返回数据-type:${result.type.toString()} data:${ResolveUtil.intList2String(result.data!.toList())}");
        if(result.type == DeviceSignalType.characteristicsWrite && result.data != null && result.data!.toList()[0] == 0){
          //发送长数据
          _nextQueue();
        }
        if(Platform.isAndroid){
          if(result.type == DeviceSignalType.characteristicsNotify){//收到数据
            if(result.data != null && result.data!.isNotEmpty){
              Map map = BleSDK.DataParsingWithData(result.data!.toList());
              print('dataCallBack: ${map.toString()}');
              EventBus().emit('dataCallBack',map);
              EventBus().emit('dataByteCallBack',result.data!);
            }
          }
        }else{
          if(result.type == DeviceSignalType.unKnown){//收到数据
            if(result.data != null){
              EventBus().emit('dataCallBack',BleSDK.DataParsingWithData(result.data!.toList()));
              EventBus().emit('dataByteCallBack',result.data!);
            }
          }
        }

      });
    }
  }

  ///开始写入超过200字节数据（无法一次性发完）
  void offerData() {
    writeData(Uint8List.fromList([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]));
  }

  ///设置长数据的值
  void offerValue(List<int> value) {
    linkedList.first.insertAfter(BlueOffData(value));
  }

  ///循环发送
  void _nextQueue(){
    if(linkedList.isEmpty)return;
    writeData(Uint8List.fromList(linkedList.first.data));
    linkedList.first.unlink();
  }


  ///写入数据
  void writeData(Uint8List data){
    print("写入数据-device:$device isConnected:$_isConnected data:${ResolveUtil.intList2String(data.toList())}");
    if(device != null && _isConnected){
      device!.writeData(Constant.SERVICE_DATA, Constant.DATA_CHARACTERISTIC, true, data);
    }else{
      showContentDialogTitle('提示'.tr, '设备未连接'.tr);
    }
  }





  ///断开设备
  void disConnectDevice(){
    if(device != null) {
      _manualDisconnection = true;
      device!.disConnect();
    }
  }


  ///显示loading
  void showLoadDialog(String text){
    if(Get.isDialogOpen ?? false){
      Get.back();
    }
    Get.dialog(Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          height: 100,
          margin: const EdgeInsets.only(left: 20,right: 20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(text,style: const TextStyle(fontSize: 20),),
              Container(
                width: 25,
                height: 25,
                margin: const EdgeInsets.only(right: 20,left: 10),
                child: const CircularProgressIndicator(
                  strokeWidth: 3.0,
                  backgroundColor: Colors.blue,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    ));
    Future.delayed(Duration(seconds: 10),(){
      dismissDialog();
    });
  }
  
  ///显示内容Dialog
  void showContentDialog(String text){
    if(Get.isDialogOpen ?? false){
      Get.back();
    }
    Get.defaultDialog(
        title: '提示'.tr,
        content: Text('$text'),
        barrierDismissible: true,
        onConfirm: (){
          dismissDialog();
        }
    );
  }

  ///显示内容Dialog
  void showContentDialogTitle(String title,String text,{Function? onConfirm}){
    if(Get.isDialogOpen ?? false){
      Get.back();
    }
    Get.defaultDialog(
        title: title,
        content: Text('$text'),
        barrierDismissible: true,
        onConfirm: (){
          if(onConfirm != null){
            onConfirm();
          }
          dismissDialog();
        },
      onCancel: (){
      }
    );
  }

  ///关闭loading
  void dismissDialog(){
    if(Get.isDialogOpen ?? false){
      Get.back();
    }
  }

  @override
  void onInit() {
    // TODO: 生命周期：初始化
    super.onInit();
    print('生命周期：初始化');
  }

  @override
  void onReady() {
    // TODO: 生命周期：加载完成
    super.onReady();
    print('生命周期：加载完成');
  }

  @override
  void onClose() {
    // TODO: 生命周期：控制器被释放
    super.onClose();
    print('生命周期：控制器被释放');
  }

}