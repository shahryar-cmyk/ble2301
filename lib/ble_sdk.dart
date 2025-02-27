import 'dart:convert';
import 'dart:core';
import 'dart:ffi';
import 'dart:math';
import 'dart:typed_data';
import 'bean/models.dart';
import 'utils/ble_const.dart';
import 'utils/device_cmd.dart';
import 'utils/resolve_util.dart';

class BleSDK {
  static const int DATA_READ_START = 0;
  static const int DATA_READ_CONTINUE = 2;
  static const int DATA_DELETE = 99;
  static const int DistanceMode_MILE = 0x81;
  static const int DistanceMode_KM = 0x80;
  static const int TimeMode_12h = 0x81;
  static const int TimeMode_24h = 0x80;
  static const int WristOn_Enable = 0x81;
  static const int WristOn_DisEnable = 0x80;
  static const int TempUnit_C = 0x80;
  static const int TempUnit_F = 0x81;
  static const String TAG = "BleSDK";
  static bool isRuning = false;

  static List<int> _generateValue(int size) {
    final List<int> data = List<int>.generate(size, (int index) {
      return 0;
    });
    return data;
  }

  static int _hexByte2Int(int b, int count) {
    return (b & 0xff) * pow(256, count) as int;
  }

  /// 初始化要发送的数据，16个字节，没有设置的位置都默认为0
  /// Initialize the data to be sent, 16 bytes, and default to 0 for positions that are not set
  static List<int> _generateInitValue() {
    return _generateValue(16);
  }

  /// copying array of data
  static void arrayCopy(
      List<int> source, int srcPos, List<int> dest, int destPos, int length) {
    for (int i = 0; i < length; i++) {
      dest[destPos + i] = source[srcPos + i];
    }
  }

  /// message content needed to be sent is converted to List<int>
  static List<int> _getInfoValue(String info, int maxLength) {
    if (info.isEmpty) return [];
    final List<int> nameBytes = utf8.encode(info);
    if (nameBytes.length >= maxLength) {
      /// two commands in total 32 bytes, with only 24 bytes of content.
      /// （32-2*（1cmd+1 Message type + 1 length + 1 validation））
      final List<int> real = List<int>.generate(maxLength, (int index) {
        return 0;
      });
      final List<int> chars = info.codeUnits;
      int length = 0;
      for (int i = 0; i < chars.length; i++) {
        final String s = chars[i].toString();
        final List<int> nameB = utf8.encode(s);
        if (length + nameB.length == maxLength) {
          arrayCopy(nameBytes, 0, real, 0, real.length);
          return real;
        } else if (length + nameB.length > maxLength) {
          /// >24 will result in a byte not being sent to the lower machine causing garbled code
          arrayCopy(nameBytes, 0, real, 0, length);
          return real;
        }
        length += nameB.length;
      }
    }
    return nameBytes;
  }

  /// crc验证
  /// crc validation
  static void _crcValue(List<int> list) {
    int crcValue = 0;
    for (final int value in list) {
      crcValue += value;
    }
    list[15] = crcValue & 0xff;
  }

  /// 十进制转bcd码（23 -> 0x23）
  /// Decimal to bcd code (23 ->0x23)
  static int _getBcdValue(int value) {
    String data = value.toString();
    if (data.length > 2) data = data.substring(2);
    return int.parse(data, radix: 16);
  }

  static Map DataParsingWithData(List<int> value) {
    switch (value[0]) {
      case DeviceConst.CMD_Set_Goal:
        return ResolveUtil.setMethodSuccessful(BleConst.SetStepGoal);
      case DeviceConst.CMD_Set_UseInfo:
        return ResolveUtil.setMethodSuccessful(BleConst.SetPersonalInfo);
      case DeviceConst.CMD_Set_Name:
        break;
      case DeviceConst.CMD_Set_MOT_SIGN:
        return ResolveUtil.setMethodSuccessful(
            BleConst.SetMotorVibrationWithTimes);
      case DeviceConst.CMD_Set_DeviceInfo:
        return ResolveUtil.setMethodSuccessful(BleConst.SetDeviceInfo);
      case DeviceConst.CMD_Set_AutoHeart:
        return ResolveUtil.setMethodSuccessful(
            BleConst.SetAutomaticHRMonitoring);
      case DeviceConst.CMD_Set_ActivityAlarm:
        return ResolveUtil.setMethodSuccessful(BleConst.SetSedentaryReminder);
      case DeviceConst.CMD_Set_DeviceID:
        return ResolveUtil.setMacSuccessful();
      case DeviceConst.CMD_Start_EXERCISE:
        return ResolveUtil.setMethodSuccessful(BleConst.EnterActivityMode);
      case DeviceConst.CMD_Set_TemperatureCorrection:
        if (value[2] != 0 && value[3] != 0) {
          return ResolveUtil.GetTemperatureCorrectionValue(value);
        } else {
          return ResolveUtil.setMethodSuccessful(
              BleConst.CMD_Set_TemperatureCorrection);
        }
      case DeviceConst.CMD_HeartPackageFromDevice:
        return ResolveUtil.getActivityExerciseData(value);
      case DeviceConst.CMD_SET_TIME:
        return ResolveUtil.setTimeSuccessful(value);
      case DeviceConst.CMD_Get_SPORTData:
        return ResolveUtil.getExerciseData(value);
      case DeviceConst.CMD_GET_TIME:
        return ResolveUtil.getDeviceTime(value);
      case DeviceConst.CMD_GET_USERINFO:
        return ResolveUtil.getUserInfo(value);
      case DeviceConst.CMD_Get_DeviceInfo:
        return ResolveUtil.getDeviceInfo(value);
      case DeviceConst.CMD_Enable_Activity:
        return ResolveUtil.getActivityData(value);
      case DeviceConst.CMD_Get_Goal:
        return ResolveUtil.getGoal(value);
      case DeviceConst.CMD_Get_BatteryLevel:
        return ResolveUtil.getDeviceBattery(value);
      case DeviceConst.CMD_Get_Address:
        return ResolveUtil.getDeviceAddress(value);
      case DeviceConst.CMD_Get_Version:
        return ResolveUtil.getDeviceVersion(value);
      case DeviceConst.CMD_Get_Name:
        return ResolveUtil.getDeviceName(value);
      case DeviceConst.CMD_Get_AutoHeart:
        return ResolveUtil.getAutoHeart(value);
      case DeviceConst.CMD_Reset:
        return ResolveUtil.Reset();
      case DeviceConst.CMD_Mcu_Reset:
        return ResolveUtil.MCUReset();
      case DeviceConst.CMD_Notify:
        return ResolveUtil.Notify();
      case DeviceConst.CMD_Get_ActivityAlarm:
        return ResolveUtil.getActivityAlarm(value);
      case DeviceConst.CMD_Get_TotalData:
        return ResolveUtil.getTotalStepData(value);
      case DeviceConst.CMD_Get_DetailData:
        return ResolveUtil.getDetailData(value);
      case DeviceConst.CMD_Get_SleepData:
        return ResolveUtil.getSleepData(value);
      case DeviceConst.CMD_Get_HeartData:
        return ResolveUtil.getHeartData(value);
      case DeviceConst.CMD_Get_OnceHeartData:
        return ResolveUtil.getOnceHeartData(value);
      case DeviceConst.CMD_Get_HrvTestData:
        return ResolveUtil.getHrvTestData(value);
      case DeviceConst.CMD_Get_Clock:
        return ResolveUtil.getClockData(value);
      case DeviceConst.CMD_Set_Clock:
        return ResolveUtil.updateClockSuccessful(value);
      case DeviceConst.CMD_Set_NewDeviceInfo:
        return ResolveUtil.setNewDeviceInfo(value);
      case DeviceConst.CMD_Get_NewDeviceInfo:
        return ResolveUtil.getNewDeviceInfo(value);
      case DeviceConst.Enter_photo_modeback:
        return ResolveUtil.enterPhotoModeback(value);
      case DeviceConst.Enter_photo_mode:
        return ResolveUtil.setMethodSuccessful(BleConst.EnterPhotoMode);
      case DeviceConst.Exit_photo_mode:
        return ResolveUtil.setMethodSuccessful(BleConst.BackHomeView);
      case DeviceConst.CMD_ECGQuality:
        return ResolveUtil.eCGQuality(value);
      case DeviceConst.CMD_ECGDATA:
      case DeviceConst.CMD_PPGGDATA:
        break;
      case DeviceConst.Weather:
        return ResolveUtil.setMethodSuccessful(BleConst.Weather);
      case DeviceConst.Braceletdial:
        return ResolveUtil.braceletdial(isRuning, value);
      case DeviceConst.SportMode:
        return ResolveUtil.setMethodSuccessful(BleConst.SportMode);
      case DeviceConst.GetSportMode:
        return ResolveUtil.getSportMode(value);
      case DeviceConst.MeasurementWithType:
        return ResolveUtil.measurementWithType(
            StartDeviceMeasurementWithType, value);
      case DeviceConst.GPSControlCommand:
        return ResolveUtil.gPSControlCommand(value);
      case DeviceConst.CMD_Get_GPSDATA:
        return ResolveUtil.getHistoryGpsData(value);
      case DeviceConst.Clear_Bracelet_data:
        return ResolveUtil.setMethodSuccessful(BleConst.Clear_Bracelet_data);
      case DeviceConst.CMD_Get_Auto_Blood_oxygen:
        return ResolveUtil.getAutoBloodOxygen(value);
      case DeviceConst.CMD_Get_Blood_oxygen:
        return ResolveUtil.getBloodoxygen(value);
      case DeviceConst.CMD_SET_SOCIAL:
        if (isSettingSocial) {
          return ResolveUtil.setMethodSuccessful(
              BleConst.SocialdistanceSetting);
        } else {
          return ResolveUtil.setSocial(value);
        }
      case DeviceConst.Sos:
        return ResolveUtil.setMethodSuccessful(BleConst.Sos);
      case DeviceConst.Temperature_history:
        return ResolveUtil.getTempData(value);
      case DeviceConst.GetAxillaryTemperatureDataWithMode:
        return ResolveUtil.getTempDataer(value);
      case DeviceConst.CMD_QrCode:
        return ResolveUtil.getQrCode(value, false);
      case DeviceConst.CMD_GET_BLOODSUGAR:
        return ResolveUtil.setBoolSugarStatus(value);
      case DeviceConst.CMD_GET_BLOODSUGAR_DATA:
        return ResolveUtil.setBoolSugarValue(value);
      case DeviceConst.GetEcgPpgStatus:
        return ResolveUtil.ECGResult(value);
      case DeviceConst.PregnancyCycle:
        if (pregnancyCycleRead) {
          //读取
          return ResolveUtil.readPregnancyCycle(value);
        } else {
          //设置
          return ResolveUtil.setMethodSuccessful(BleConst.SetPregnancyCycle);
        }
      case DeviceConst.GetEcgSaveData:
        if (read) {
          return ResolveUtil.getEcgHistoryData(value);
        } else {
          return ResolveUtil.setMethodSuccessful(BleConst.DeleteECGdata);
        }
      case DeviceConst.Openecg:
        if (ecgopen) {
          if (16 <= value.length) {
            return ResolveUtil.ecgData(value);
          }
        } else {
          return ResolveUtil.setMethodSuccessful(BleConst.ECG);
        }
        break;
      case DeviceConst.WomenHealth:
        if (value[1] == 0) {
          //设置
          return ResolveUtil.setMethodSuccessful(BleConst.SetWomenHealth);
        } else {
          //读取
          return ResolveUtil.readWomenHealth(value);
        }
      case DeviceConst.Closeecg:
        return ResolveUtil.setMethodSuccessful(BleConst.CloseECG);
      case DeviceConst.BloodsugarWithMode:
        int ppi = _hexByte2Int(value[1], 0);
        int ppi2 = _hexByte2Int(value[2], 0);
        if (0 == ppi) {
          switch (ppi2) {
            case 1:
              return ResolveUtil.setMethodSuccessful(BleConst.ppgStartSucessed);
            case 2:
              return ResolveUtil.setMethodSuccessful(BleConst.ppgResult);
            case 3:
              return ResolveUtil.setMethodSuccessful(BleConst.ppgStop);
            case 4:
              return ResolveUtil.setMethodSuccessful(
                  BleConst.ppgMeasurementProgress);
            case 5:
              return ResolveUtil.setMethodSuccessful(BleConst.ppgQuit);
          }
        } else {
          return ResolveUtil.setMethodSuccessful(BleConst.ppgStartFailed);
        }
        break;
      case DeviceConst.CMD_Get_PPITestData:
        return ResolveUtil.getPPITestData(value);
      case DeviceConst.CMD_SETTING_HRV_TIME:
        return ResolveUtil.getHrvTimeData(value);
      case DeviceConst.CMD_CLOSE_DEVICE:
        return ResolveUtil.CloseDevices(value);
      case DeviceConst.CMD_AUTO_CHECK_STATUS:
        return ResolveUtil.GetOffCheckStatus(value);
    }
    return ResolveUtil.setMethodError(_getBcdValue(value[0]).toString());
  }

  ///血糖
  static Uint8List BloodsugarWithMode(int ppgMode, int ppgStatus) {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.BloodsugarWithMode;
    value[1] = ppgMode;
    if (2 == ppgMode || 4 == ppgMode) {
      value[2] = ppgStatus;
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static bool ecgopen = false;
  static Uint8List OpenECGPPG(int level, int time) {
    ecgopen = 0 != level;
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.Openecg;
    value[1] = level;
    value[3] = ((time) & 0xff);
    value[4] = ((time >> 8) & 0xff);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static Uint8List stopEcgPPg() {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.Closeecg;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static bool read = false;

  ///获得睡眠详细数据
  ///mode : 0-读最近的睡眠详细数据 2-继续上次读的位置下一段数据 99-删除睡眠数据
  ///Obtain detailed sleep data
  ///mode : 0-Read the latest sleep detailed data 2-Continue with the next data segment at the last read location 99-Delete sleep data
  static Uint8List GetDetailSleepDataWithMode(int mode) {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_SleepData;
    if (99 == mode) {
      value[1] = 0x99;
    } else {
      value[1] = mode;
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得睡眠详细数据
  ///mode : 0-读最近的睡眠详细数据 2-继续上次读的位置下一段数据 99-删除睡眠数据 time: yyyy-MM-dd HH:mm:ss
  ///Obtain detailed sleep data
  ///mode : 0-Read the latest sleep detailed data 2-Continue with the next data segment at the last read location 99-Delete sleep data time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetDetailSleepDataWithModeForTime(int mode, String time) {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_SleepData;
    if (99 == mode) {
      value[1] = 0x99;
    } else {
      value[1] = mode;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///开始实时计步
  ///Start real time step
  static Uint8List RealTimeStep(bool enable, bool tempEnable) {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Enable_Activity;
    value[1] = (enable ? 1 : 0);
    value[2] = (tempEnable ? 1 : 0);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///停止实时计步
  ///Stop real-time step counting
  static Uint8List stopGo() {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Enable_Activity;
    value[1] = 0;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///设置个人信息
  ///Set user profile
  static Uint8List SetPersonalInfo(MyPersonalInfo info) {
    List<int> value = _generateInitValue();
    int male = info.sex;
    int age = info.age;
    int height = info.height;
    int weight = info.weight;
    int stepLength = info.stepLength;
    value[0] = DeviceConst.CMD_Set_UseInfo;
    value[1] = male;
    value[2] = age;
    value[3] = height;
    value[4] = weight;
    value[5] = stepLength;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取个人信息
  ///Get user's personal information
  static Uint8List GetPersonalInfo() {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_GET_USERINFO;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///设置设备时间
  ///Set Device Time
  static Uint8List SetDeviceTime(DateTime dateTime) {
    final List<int> value = _generateInitValue();
    final int year = dateTime.year;
    final int month = dateTime.month;
    final int day = dateTime.day;
    final int hour = dateTime.hour;
    final int minute = dateTime.minute;
    final int second = dateTime.second;
    value[0] = DeviceConst.CMD_SET_TIME;
    value[1] = _getBcdValue(year);
    value[2] = _getBcdValue(month);
    value[3] = _getBcdValue(day);
    value[4] = _getBcdValue(hour);
    value[5] = _getBcdValue(minute);
    value[6] = _getBcdValue(second);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取设备时间
  ///Get device time
  static Uint8List GetDeviceTime() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_GET_TIME;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得步数详细数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据
  ///Obtain detailed step count data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data
  static Uint8List GetDetailActivityDataWithMode(int mode) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_DetailData;
    if (99 == mode) {
      value[1] = 0x99;
    } else {
      value[1] = mode;
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得步数详细数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time : yyyy-MM-dd HH:mm:ss
  ///Obtain detailed step count data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time : yyyy-MM-dd HH:mm:ss
  static Uint8List GetDetailActivityDataWithModeForTime(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_DetailData;
    if (99 == mode) {
      value[1] = 0x99;
    } else {
      value[1] = mode;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///自动测试温度数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time : yyyy-MM-dd HH:mm:ss
  ///Automatic testing of temperature data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time : yyyy-MM-dd HH:mm:ss
  static Uint8List GetTemperature_historyDataWithMode(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.Temperature_history;
    if (99 == mode) {
      value[1] = 0x99;
    } else {
      value[1] = mode;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///手动测试温度数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time: yyyy-MM-dd HH:mm:ss
  ///Manual testing of temperature data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data  time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetAxillaryTemperatureDataWithMode(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.GetAxillaryTemperatureDataWithMode;
    if (99 == mode) {
      value[1] = 0x99;
    } else if (0 == mode) {
      value[1] = 0x00;
    } else if (1 == mode) {
      value[1] = 0x01;
    } else {
      value[1] = 0x02;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///运动模式开关
  ///Sport mode switch
  static Uint8List EnterActivityMode(int activityMode, int WorkMode) {
    List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Start_EXERCISE;
    value[1] = WorkMode;
    value[2] = activityMode;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///发送运动模式心跳包(配合"EnterActivityMode"使用)
  ///当手环是通过APP进入多运动模式后，APP必须每隔1秒发送一个数据给手环，否则手环会退出多运动模式
  ///Send a sports mode heartbeat packet (used in conjunction with 'EnterActivityMode')
  ///When the bracelet enters multi sport mode through the APP, the APP must send data to the bracelet every 1 second, otherwise the bracelet will exit multi sport mode
  static Uint8List sendHeartPackage(double distance, int space, int rssi) {
    List<int> value = _generateInitValue();
    final bData = ByteData(8);
    int min = space ~/ 60;
    int second = space % 60;
    bData.setFloat32(0, distance, Endian.little);
    final List<int> distanceValue = bData.buffer.asUint8List(0, 4);
    value[0] = DeviceConst.CMD_heart_package;
    arrayCopy(distanceValue, 0, value, 1, distanceValue.length);
    value[5] = min;
    value[6] = second;
    value[7] = rssi;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取某天总数据
  ///0:表⽰是从最新的位置开始读取(最多50组数据)  2:表⽰接着读取(当数据总数⼤于50的时候) 0x99:表⽰删除所有运动数据
  ///Obtain total data for a certain day
  ///0: Table 1 starts reading from the latest position (up to 50 sets of data) 2: Table 2 continues reading (when the total number of data exceeds 50) 0x99: Table 1 deletes all motion data
  static Uint8List GetTotalActivityDataWithMode(int mode) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_TotalData;
    if (99 == mode) {
      value[1] = 0x99;
    } else if (0 == mode) {
      value[1] = 0x00;
    } else if (1 == mode) {
      value[1] = 0x01;
    } else {
      value[1] = 0x02;
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///根据某个日期获取到最新的总数据
  ///mode: 0-表⽰是从最新的位置开始读取(最多50组数据)  2-表⽰接着读取(当数据总数⼤于50的时候) 99-表⽰删除所有运动数据
  ///time: yyyy-MM-dd HH:mm:ss
  ///Obtain the latest total data based on a certain date
  ///mode: 0-Table 1 starts reading from the latest position (up to 50 sets of data) 2-Table 2 continues reading (when the total number of data exceeds 50) 99-Table 1 deletes all motion data
  ///time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetTotalActivityDataWithModeForTime(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_TotalData;
    if (99 == mode) {
      value[1] = 0x99;
    } else if (0 == mode) {
      value[1] = 0x00;
    } else if (1 == mode) {
      value[1] = 0x01;
    } else {
      value[1] = 0x02;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static _insertDateValue(List<int> list, String time) {
    if (time.isNotEmpty) {
      var timeArray = time.split(' ');
      int year = int.parse(timeArray[0].split('-')[0]);
      int month = int.parse(timeArray[0].split('-')[1]);
      int day = int.parse(timeArray[0].split('-')[2]);
      int hour = int.parse(timeArray[1].split(':')[0]);
      int min = int.parse(timeArray[1].split(':')[1]);
      int second = int.parse(timeArray[1].split(':')[2]);
      list[4] = _getBcdValue(year - 2000);
      list[5] = _getBcdValue(month);
      list[6] = _getBcdValue(day);
      list[7] = _getBcdValue(hour);
      list[8] = _getBcdValue(min);
      list[9] = _getBcdValue(second);
    }
  }

  ///进入dfu模式
  ///Entering dfu mode
  static Uint8List enterOTA() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Start_Ota;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取设备版本号
  ///Read software version number
  static Uint8List GetDeviceVersion() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Version;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///恢复出厂设置
  ///Restore factory settings
  static Uint8List Reset() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Reset;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取设备mac地址
  ///Read MAC address
  static Uint8List GetDeviceMacAddress() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Address;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取设备电量
  ///Read device power
  static Uint8List GetDeviceBatteryLevel() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_BatteryLevel;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///重启设备
  ///MCU soft reset command
  static Uint8List MCUReset() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Mcu_Reset;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///设置设备名字
  ///Set device name
  static Uint8List SetDeviceName(String strDeviceName) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Set_Name;
    int length = strDeviceName.length > 14 ? 14 : strDeviceName.length;
    for (int i = 0; i < length; i++) {
      value[i + 1] = strDeviceName.codeUnitAt(i);
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取设备名称
  ///Read Bluetooth device name
  static Uint8List GetDeviceName() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Name;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///设置设备信息
  ///Set basic parameters of Bracelet
  static Uint8List SetDeviceInfo(MyDeviceInfo deviceBaseParameter) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Set_DeviceInfo;
    value[1] = (deviceBaseParameter.DistanceUnit ? 0x81 : 0x80);
    value[2] = (deviceBaseParameter.is12Hour ? 0x81 : 0x80);
    value[3] = (deviceBaseParameter.Hand_up_light_screen_switch ? 0x81 : 0x80);
    value[4] = (!deviceBaseParameter.Fahrenheit ? 0x81 : 0x80);
    value[5] = (deviceBaseParameter.Nightmode ? 0x81 : 0x80);
    value[6] = 0x80;
    value[9] = (0x80 + deviceBaseParameter.baseheart);
    value[11] = (0x80 + deviceBaseParameter.screenBrightness);
    value[12] = (0x80 + deviceBaseParameter.indexDial);
    value[14] = (0x80 + deviceBaseParameter.languages);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static bool StartDeviceMeasurementWithType = false;

  ///健康测量控制
  ///Health measurement control
  static Uint8List HealthMeasurementWithDataType(int dataType, bool open) {
    StartDeviceMeasurementWithType = open;
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.MeasurementWithType;
    value[1] = dataType;
    value[2] = open ? 0x01 : 0x00;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static Uint8List SetBraceletdial(int mode) {
    isRuning = true;
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.Braceletdial;
    value[1] = mode;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///自定义命令
  static Uint8List setValue(
    int v1,
    int v2,
    int v3,
    int v4,
    int v5,
    int v6,
    int v7,
    int v8,
    int v9,
    int v10,
    int v11,
    int v12,
    int v13,
    int v14,
    int v15,
  ) {
    final List<int> value = _generateInitValue();
    value[0] = _getBcdValue(v1);
    value[1] = _getBcdValue(v2);
    value[2] = _getBcdValue(v3);
    value[3] = _getBcdValue(v4);
    value[4] = _getBcdValue(v5);
    value[5] = _getBcdValue(v6);
    value[6] = _getBcdValue(v7);
    value[7] = _getBcdValue(v8);
    value[8] = _getBcdValue(v9);
    value[9] = _getBcdValue(v10);
    value[10] = _getBcdValue(v11);
    value[11] = _getBcdValue(v12);
    value[12] = _getBcdValue(v13);
    value[13] = _getBcdValue(v14);
    value[14] = _getBcdValue(v15);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得HRV测试数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time: yyyy-MM-dd HH:mm:ss
  ///Get HRV test data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data  time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetHRVDataWithMode(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_HrvTestData;
    if (99 == mode) {
      value[1] = 0x99;
    } else if (0 == mode) {
      value[1] = 0x00;
    } else if (1 == mode) {
      value[1] = 0x01;
    } else {
      value[1] = 0x02;
    }
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  //获取PPI测试数据
  static Uint8List GetPPIDDataWithMode(int mode) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_PPITestData;
    if (99 == mode) {
      value[1] = 0x99;
    } else if (0 == mode) {
      value[1] = 0x00;
    } else if (1 == mode) {
      value[1] = 0x01;
    } else {
      value[1] = 0x02;
    }
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  //获取Hrv测量时长
  static Uint8List GetHrvTestTime() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_SETTING_HRV_TIME;
    value[1] = 0x00;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  //设置Hrv测试时长
  static Uint8List SetHrvTestTime(int time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_SETTING_HRV_TIME;
    value[1] = 0x01;
    value[2] = time;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  //断开蓝牙
  static Uint8List CloseBlueDevice() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_CLOSE_DEVICE;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///血糖开始测量
  ///Start measuring blood sugar
  static Uint8List startBloodSugar() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_GET_BLOODSUGAR;
    value[1] = 0x01;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///血糖进度设置
  ///Blood glucose progress setting
  static Uint8List progressBloodSugar(int progress) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_GET_BLOODSUGAR;
    value[1] = 0x04;
    value[2] = progress;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///结束测量血糖
  ///End measuring blood glucose
  static Uint8List endBloodSugar() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_GET_BLOODSUGAR;
    value[1] = 0x03;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static bool pregnancyCycleRead = false;

  static bool isSettingSocial = false;

  ///设置自动检测心率时段
  ///Set automatic heart rate detection period
  static Uint8List SetAutomaticHRMonitoring(MyAutomaticHRMonitoring autoHeart) {
    final List<int> value = _generateInitValue();
    int time = autoHeart.time;
    value[0] = DeviceConst.CMD_Set_AutoHeart;
    value[1] = autoHeart.open;
    value[2] = _getBcdValue(autoHeart.startHour);
    value[3] = _getBcdValue(autoHeart.startMinute);
    value[4] = _getBcdValue(autoHeart.endHour);
    value[5] = _getBcdValue(autoHeart.endMinute);
    value[6] = autoHeart.week;
    value[7] = (time & 0xff);
    value[8] = ((time >> 8) & 0xff);
    value[9] = autoHeart.type; //
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///读取自动检测心率时段
  ///1 心率 2 血氧 3 温度 4 HRV
  ///Read auto detect heart rate period
  ///1 Heart rate 2 Blood oxygen 3 Temperature 4 HRV
  static Uint8List GetAutomaticHRMonitoring(int type) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_AutoHeart;
    value[1] = type;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获取多模式运动数据
  ///mode 0:表⽰是从最新的位置开始读取(最多50组数据)  2:表⽰接着读取(当数据总数⼤于50的时候) 0x99:表⽰删除所有GPS数据
  ///Obtain multimodal motion data
  ///Mode 0: Table 1 starts reading from the latest position (up to 50 sets of data) 2: Table 2 continues reading (when the total number of data exceeds 50) 0x99: Table 1 deletes all GPS data
  static Uint8List GetActivityModeDataWithMode(int mode) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_SPORTData;
    value[1] = mode;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得单次心率数据（间隔测试心率）
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据  time: yyyy-MM-dd HH:mm:ss
  ///Obtain single heart rate data (interval test heart rate)
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetStaticHRWithMode(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_OnceHeartData;
    value[1] = mode;
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得心率数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time: yyyy-MM-dd HH:mm:ss
  ///Get heart rate data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetDynamicHRWithMode(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_HeartData;
    value[1] = mode;
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得血氧数据
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time: yyyy-MM-dd HH:mm:ss
  ///Get blood oxygen data
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetBloodOxygen(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Blood_oxygen;
    value[1] = mode;
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///获得血氧数据（自动测试）
  ///mode : 0-读最近的详细数据 2-继续上次读的位置下一段数据 99-删除数据 time: yyyy-MM-dd HH:mm:ss
  ///Obtain blood oxygen data (automatic testing)
  ///mode : 0-Read the latest detailed data 2-Continue with the next data segment at the last read location 99-Delete data time: yyyy-MM-dd HH:mm:ss
  static Uint8List GetAutoBloodOxygen(int mode, String time) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Auto_Blood_oxygen;
    value[1] = mode;
    _insertDateValue(value, time);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///设置目标步数
  ///Set target steps
  static Uint8List SetStepGoal(int stepGoal, int targetExecutionTime,
      int distance, int calorie, int sleepTime) {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Set_Goal;
    value[4] = ((stepGoal >> 24) & 0xff);
    value[3] = ((stepGoal >> 16) & 0xff);
    value[2] = ((stepGoal >> 8) & 0xff);
    value[1] = ((stepGoal) & 0xff);
    value[6] = ((targetExecutionTime >> 8) & 0xff);
    value[5] = ((targetExecutionTime) & 0xff);
    value[8] = ((distance >> 8) & 0xff);
    value[7] = ((distance) & 0xff);
    value[10] = ((calorie >> 8) & 0xff);
    value[9] = ((calorie) & 0xff);
    value[12] = ((sleepTime >> 8) & 0xff);
    value[11] = ((sleepTime) & 0xff);
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///读取目标步数
  ///Read target steps
  static Uint8List GetStepGoal() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Goal;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  ///读取手环基本参数
  ///Read basic parameters of Bracelet
  static Uint8List GetDeviceInfo() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_DeviceInfo;
    _crcValue(value);
    return Uint8List.fromList(value);
  }

  static List<int> intToint(int num) {
    return [((num >> 8) & 0xff), (num & 0xff)];
  }

  static int intArrayToInt(List<int> arr) {
    int targets = ((arr[1] & 0xff) | ((arr[0] << 8) & 0xff00));
    return targets;
  }

// Code Edition for the Alarm

  static Uint8List SetActivityAlarm(Clock activityAlarm) {
    final List<int> value = _generateInitValue();
    List<int> infoValue = _getInfoValue(activityAlarm.content, 30);

    value[0] = DeviceConst.CMD_Set_Clock; // Command ID
    value[1] = (activityAlarm.enable) ? 1 : 0; // Enable/disable alarm
    value[2] = activityAlarm.type; // Start hour
    value[3] = _getBcdValue(activityAlarm.hour); // Start minute
    value[4] = _getBcdValue(activityAlarm.minute); // End hour
    value[5] = _convertWeeksToByte(activityAlarm.weeks); // End minute
    value[6] = infoValue.length; // Days of the week
    _crcValue(value); // Calculate CRC
    return Uint8List.fromList(value);
  }

  static Uint8List GetActivityAlarm() {
    final List<int> value = _generateInitValue();
    value[0] = DeviceConst.CMD_Get_Clock; // Command ID
    _crcValue(value); // Calculate CRC
    return Uint8List.fromList(value);
  }

  static int _convertWeeksToByte(List<String> weeks) {
    int weekByte = 0;
    for (int i = 0; i < weeks.length; i++) {
      if (weeks[i] == "1") {
        weekByte |= (1 << i); // Set bit at position i
      }
    }
    return weekByte;
  }
}
