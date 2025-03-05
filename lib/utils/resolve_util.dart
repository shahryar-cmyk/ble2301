import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'device_key.dart';
import 'ble_const.dart';
import '../ble_sdk.dart';
import 'device_cmd.dart';

class ResolveUtil {
  ///crc校验
  static void crcValue(List<int> value) {
    int crc = 0;
    for (int i = 0; i < value.length - 1; i++) {
      crc += value[i];
    }
    value[value.length - 1] = crc & 0xff;
  }

  static int _hexByte2Int(int b, int count) {
    return (b & 0xff) * pow(256, count) as int;
  }

  /// bcd code time analysis
  static String _bcd2String(int bytes) {
    final int a = (bytes & 0xf0) >> 4;
    final int b = bytes & 0x0f;
    final String results = "$a$b";
    return results;
  }

  static String intList2String(List<int> bytes) {
    String data = '';
    bytes.forEach((element) {
      data += '${element.toRadixString(16).padLeft(2, '0').toUpperCase()} ';
    });
    return data;
  }

  static double _intBitToDouble(int value) {
    final bData = ByteData(8);
    bData.setInt32(0, value);
    return bData.getFloat32(0, Endian.big);
  }

  ///设备时间
  static Map getDeviceTime(List<int> value) {
    String date =
        "20${_bcd2String(value[1])}-${_bcd2String(value[2])}-${_bcd2String(value[3])} ${_bcd2String(value[4])}:${_bcd2String(value[5])}:${_bcd2String(value[6])}";
    String gpsDate =
        "${_bcd2String(value[9])}.${_bcd2String(value[10])}.${_bcd2String(value[11])}";
    Map mapData = {DeviceKey.DeviceTime: date, DeviceKey.GPSTime: gpsDate};
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceTime,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///int 转 ascll
  static String int2Ascll(int value) {
    var list = [value];
    var byteValue = Uint8List.fromList(list);
    return utf8.decode(byteValue);
  }

  static String getGpsTime(List<int> value) {
    String gpsDate =
        "${_bcd2String(value[9])}.${_bcd2String(value[10])}.${_bcd2String(value[11])}";
    return gpsDate;
  }

  ///用户信息
  static Map getUserInfo(List<int> value) {
    final List<int> userInfo = List<int>.generate(6, (int index) {
      return 0;
    });
    for (int i = 0; i < 5; i++) {
      userInfo[i] = _hexByte2Int(value[i + 1], 0);
    }
    final StringBuffer stringBuffer = StringBuffer();
    for (int i = 6; i < 12; i++) {
      if (value[i] == 0) continue;
      stringBuffer.write(String.fromCharCode(_hexByte2Int(value[i], 0)));
    }
    Map mapData = {
      DeviceKey.Gender: userInfo[0],
      DeviceKey.Age: userInfo[1],
      DeviceKey.Height: userInfo[2],
      DeviceKey.Weight: userInfo[3],
      DeviceKey.Stride: userInfo[4],
      DeviceKey.KUserDeviceId: stringBuffer.toString()
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetPersonalInfo,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///设备信息
  static Map getDeviceInfo(List<int> value) {
    Map mapData = {
      DeviceKey.DistanceUnit: _hexByte2Int(value[1], 0).toString(),
      DeviceKey.TimeUnit: _hexByte2Int(value[2], 0).toString(),
      DeviceKey.StatusOfTheRaisedHandOnscreen:
          _hexByte2Int(value[3], 0).toString(), //抬手亮屏开关
      DeviceKey.TempUnit: _hexByte2Int(value[4], 0).toString(), //温度单位
      DeviceKey.NightMode: _hexByte2Int(value[5], 0).toString(), //夜间模式
      DeviceKey.KBaseHeart: _hexByte2Int(value[9], 0).toString(), //基础心率
      DeviceKey.ScreenBrightness: _hexByte2Int(value[11], 0).toString(), //亮度
      DeviceKey.Dialinterface: _hexByte2Int(value[12], 0).toString(), //表盘
      DeviceKey.SocialDistancedwitch:
          _hexByte2Int(value[13], 0).toString(), //社交距离
      DeviceKey.ChineseOrEnglish:
          _hexByte2Int(value[14], 0).toString() //中英文切换 0 英文 1 中文
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceInfo,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///实时计步信息
  static Map getActivityData(List<int> value) {
    final List<String> activityData = List<String>.generate(6, (int index) {
      return "";
    });
    int step = 0;
    double cal = 0;
    double distance = 0;
    int time = 0;
    int heart = 0;
    int exerciseTime = 0;
    for (int i = 1; i < 5; i++) {
      step += _hexByte2Int(value[i], i - 1);
    }
    for (int i = 5; i < 9; i++) {
      cal += _hexByte2Int(value[i], i - 5);
    }
    for (int i = 9; i < 13; i++) {
      distance += _hexByte2Int(value[i], i - 9);
    }
    for (int i = 13; i < 17; i++) {
      time += _hexByte2Int(value[i], i - 13);
    }
    for (int i = 17; i < 21; i++) {
      exerciseTime += _hexByte2Int(value[i], i - 17);
    }
    heart = _hexByte2Int(value[21], 0);
    int temp = 0;
    int spo2 = 0;
    if (value.length > 22) {
      temp = _hexByte2Int(value[22], 0) + _hexByte2Int(value[23], 1);
      if (value.length > 24) {
        spo2 = _hexByte2Int(value[24], 0);
      }
    }
    // int temp = _hexByte2Int(value[22], 0) + _hexByte2Int(value[23],1);
    activityData[0] = step.toString();
    activityData[1] = (cal / 100).toStringAsFixed(1);
    activityData[2] = (distance / 100).toStringAsFixed(1);
    activityData[3] = (time / 60).toString();
    activityData[4] = heart.toString();
    activityData[5] = exerciseTime.toString();
    Map mapData = {
      DeviceKey.Step: activityData[0],
      DeviceKey.Calories: activityData[1],
      DeviceKey.Distance: activityData[2],
      DeviceKey.ExerciseMinutes: activityData[3],
      DeviceKey.HeartRate: activityData[4],
      DeviceKey.ActiveMinutes: activityData[5],
      DeviceKey.TempData: temp.toStringAsFixed(1),
      DeviceKey.Blood_oxygen: spo2.toString()
    };
    Map maps = {
      DeviceKey.DataType: BleConst.RealTimeStep,
      DeviceKey.End: true,
      DeviceKey.Data: mapData,
    };
    return maps;
  }

  ///步数目标
  static Map getGoal(List<int> value) {
    int goal = 0;
    int distance = 0;
    int calorie = 0;
    int sleepTime = 0;
    for (int i = 0; i < 4; i++) {
      goal += _hexByte2Int(value[i + 1], i);
    }
    for (int i = 0; i <= 1; i++) {
      //78
      distance += _hexByte2Int(value[i + 7], i);
    }
    for (int i = 0; i <= 1; i++) {
      //9 10
      calorie += _hexByte2Int(value[i + 9], i);
    }
    for (int i = 0; i <= 1; i++) {
      //11 12
      sleepTime += _hexByte2Int(value[i + 11], i);
    }
    Map mapData = {
      DeviceKey.StepGoal: goal.toString(),
      DeviceKey.DistanceGoal: distance.toString(),
      DeviceKey.CalorieGoal: calorie.toString(),
      DeviceKey.SleepTimeGoal: sleepTime.toString()
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetStepGoal,
      DeviceKey.End: true,
      DeviceKey.Data: mapData,
    };
    return maps;
  }

  ///设备电量
  static Map getDeviceBattery(List<int> value) {
    int battery = _hexByte2Int(value[1], 0);
    Map mapData = {DeviceKey.BatteryLevel: battery.toString()};
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceBatteryLevel,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///设备mac地址
  static Map getDeviceAddress(List<int> value) {
    final StringBuffer address = StringBuffer();
    if (value.isEmpty) return {};
    for (int i = 1; i < 7; i++) {
      final String mac = value[i].toRadixString(16);
      address.write("${mac.length == 1 ? '0$mac' : mac}:");
    }
    final String macAddress = address.toString();
    Map mapData = {
      DeviceKey.MacAddress: macAddress.substring(0, macAddress.lastIndexOf(":"))
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceMacAddress,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///设备版本号
  static Map getDeviceVersion(List<int> value) {
    final StringBuffer stringBuffer = StringBuffer();
    if (value.isEmpty) return {};
    for (int i = 1; i < 5; i++) {
      stringBuffer.write(value[i].toRadixString(16) + (i == 4 ? "" : "."));
    }
    Map mapData = {
      DeviceKey.DeviceVersion: stringBuffer.toString(),
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceVersion,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///恢复出厂设置
  static Map Reset() {
    return {DeviceKey.DataType: BleConst.CMD_Reset, DeviceKey.End: true};
  }

  ///MCU软复位指令
  static Map MCUReset() {
    return {DeviceKey.DataType: BleConst.CMD_MCUReset, DeviceKey.End: true};
  }

  ///第三方提醒命令
  static Map Notify() {
    return {DeviceKey.DataType: BleConst.Notify, DeviceKey.End: true};
  }

  ///设备名字
  static Map getDeviceName(List<int> value) {
    String name = "";
    for (int i = 1; i < 15; i++) {
      int charValue = _hexByte2Int(value[i], 0);
      if (charValue == 0 || charValue > 127) continue;
      name += int2Ascll(charValue);
    }
    Map mapData = {DeviceKey.DeviceName: name};
    Map maps = {
      DeviceKey.DataType: BleConst.GetDeviceName,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  static int getWeekInt(List<String> ar) {
    int week = 0;
    for (int i = 0; i < ar.length; i++) {
      if (int.parse(ar[i]) == 1) {
        week += pow(2, i).toInt();
      }
    }
    return week;
  }

  static String getByteString(int b) {
    final List<int> array = List<int>.generate(8, (int index) {
      return 0;
    });
    var stringBuffer = StringBuffer();
    for (int i = 0; i <= 6; i++) {
      array[i] = b & 1;
      b = b >> 1;
      stringBuffer.write(array[i].toString());
      stringBuffer.write((i == 6 ? "" : "-"));
    }
    return stringBuffer.toString();
  }

  static String getByteArray(int b) {
    final List<int> array = List<int>.generate(8, (int index) {
      return 0;
    });
    var stringBuffer = StringBuffer();
    for (int i = 0; i <= 7; i++) {
      array[i] = b & 1;
      b = b >> 1;
      stringBuffer.write(array[i]);
    }
    return stringBuffer.toString();
  }

  ///自动测量心率时间段
  static Map getAutoHeart(List<int> value) {
    int time = _hexByte2Int(value[7], 0) + _hexByte2Int(value[8], 1);
    Map mapData = {
      DeviceKey.WorkMode: _hexByte2Int(value[1], 0).toString(),
      DeviceKey.StartTime: _bcd2String(value[2]),
      DeviceKey.KHeartStartMinter: _bcd2String(value[3]),
      DeviceKey.EndTime: _bcd2String(value[4]),
      DeviceKey.KHeartEndMinter: _bcd2String(value[5]),
      DeviceKey.Weeks: getByteString(value[6]),
      DeviceKey.IntervalTime: time.toString()
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetAutomaticHRMonitoring,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///运动提醒
  static Map getActivityAlarm(List<int> value) {
    Map mapData = {
      DeviceKey.StartTimeHour: _bcd2String(value[1]),
      DeviceKey.StartTimeMin: _bcd2String(value[2]),
      DeviceKey.EndTimeHour: _bcd2String(value[3]),
      DeviceKey.EndTimeMin: _bcd2String(value[4]),
      DeviceKey.Week: getByteString(value[5]),
      DeviceKey.IntervalTime: _hexByte2Int(value[6], 0).toString(),
      DeviceKey.LeastSteps: _hexByte2Int(value[7], 0).toString()
    };
    Map maps = {
      DeviceKey.DataType: BleConst.GetSedentaryReminder,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    };
    return maps;
  }

  ///总运动数据
  static Map getTotalStepData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetTotalActivityData,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = getStepCount(value);
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      int flag = 1 + (i + 1) * count;
      if (flag < length && value[flag] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      String date =
          "20${_bcd2String(value[2 + i * count])}.${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}";
      int step = 0;
      int time = 0;
      double cal = 0;
      double distance = 0;
      for (int j = 0; j < 4; j++) {
        step += _hexByte2Int(value[5 + j + i * count], j);
      }
      for (int j = 0; j < 4; j++) {
        time += _hexByte2Int(value[9 + j + i * count], j);
      }
      for (int j = 0; j < 4; j++) {
        distance += _hexByte2Int(value[13 + j + i * count], j);
      }
      for (int j = 0; j < 4; j++) {
        cal += _hexByte2Int(value[17 + j + i * count], j);
      }
      int exerciseTime = 0;
      int goal = count == 26
          ? _hexByte2Int(value[21 + i * count], 0)
          : (_hexByte2Int(value[21 + i * count], 0) +
              _hexByte2Int(value[22 + i * count], 1));
      for (int j = 0; j < 4; j++) {
        exerciseTime += _hexByte2Int(value[count - 4 + j + i * count], j);
      }
      Map hashMap = {
        DeviceKey.Date: date,
        DeviceKey.Step: step.toString(),
        DeviceKey.ExerciseMinutes: time.toString(),
        DeviceKey.Calories: (cal / 100).toStringAsFixed(1),
        DeviceKey.Distance: (distance / 100).toStringAsFixed(1),
        DeviceKey.Goal: goal.toString(),
        DeviceKey.ActiveMinutes: exerciseTime
      };
      list.add(hashMap);
    }
    return maps;
  }

  static int getStepCount(List<int> value) {
    int goal = 27;
    int length = value.length;
    if (length != 2) {
      if (length % 26 == 0) {
        goal = 26;
      } else if (length % 27 == 0) {
        goal = 27;
      } else {
        if ((length - 2) % 26 == 0) {
          goal = 26;
        } else if ((length - 2) % 27 == 0) {
          goal = 27;
        }
      }
    }
    return goal;
  }

  ///详细运动数据
  static Map getDetailData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetDetailActivityData,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 25;
    int length = value.length;
    int size = length ~/ count;
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      Map hashMap = {};
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      String date =
          "20${_bcd2String(value[3 + i * 25])}.${_bcd2String(value[4 + i * 25])}.${_bcd2String(value[5 + i * 25])} ${_bcd2String(value[6 + i * 25])}:${_bcd2String(value[7 + i * 25])}:${_bcd2String(value[8 + i * 25])}";
      int step = 0;
      double cal = 0;
      double distance = 0;
      var stringBuffer = StringBuffer();
      for (int j = 0; j < 2; j++) {
        step += _hexByte2Int(value[9 + j + i * 25], j);
      }
      for (int j = 0; j < 2; j++) {
        cal += _hexByte2Int(value[11 + j + i * 25], j);
      }
      for (int j = 0; j < 2; j++) {
        distance += _hexByte2Int(value[13 + j + i * 25], j);
      }
      for (int j = 0; j < 10; j++) {
        stringBuffer.write(_hexByte2Int(value[15 + j + i * 25], 0).toString());
        stringBuffer.write(j == 9 ? "" : " ");
      }
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.KDetailMinterStep: step.toString(),
        DeviceKey.Calories: (cal / 100).toStringAsFixed(2),
        DeviceKey.Distance: (distance / 100).toStringAsFixed(2),
        DeviceKey.ArraySteps: stringBuffer.toString()
      });
      list.add(hashMap);
    }
    return maps;
  }

  ///睡眠数据
  static Map getSleepData(List<int> value) {
    int length = value.length;
    Map maps = {
      DeviceKey.DataType: BleConst.GetDetailSleepData,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    bool end = value[value.length - 1] == 0xff &&
        value[value.length - 2] == DeviceConst.CMD_Get_SleepData;
    if (end) {
      maps.addAll({DeviceKey.End: true});
    }
    if (130 == length || (end && 132 == length)) {
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3])}-${_bcd2String(value[4])}-${_bcd2String(value[5])} ${_bcd2String(value[6])}:${_bcd2String(value[7])}:${_bcd2String(value[8])}";
      hashMap.addAll({DeviceKey.Date: date});
      int sleepLength = _hexByte2Int(value[9], 0);
      var stringBuffer = StringBuffer();
      for (int j = 0; j < sleepLength; j++) {
        stringBuffer.write(_hexByte2Int(value[10 + j], 0));
        stringBuffer.write(j == sleepLength ? "" : " ");
      }
      hashMap.addAll({
        DeviceKey.ArraySleep: stringBuffer.toString(),
        DeviceKey.sleepUnitLength: "1"
      });
      list.add(hashMap);
    } else {
      int count = 34;
      int size = length ~/ count;
      if (size == 0) {
        maps.addAll({DeviceKey.Data: list, DeviceKey.End: true});
        return maps;
      }
      for (int i = 0; i < size; i++) {
        var hashMap = {};
        String date =
            "20${_bcd2String(value[3 + i * 34])}-${_bcd2String(value[4 + i * 34])}-${_bcd2String(value[5 + i * 34])} ${_bcd2String(value[6 + i * 34])}:${_bcd2String(value[7 + i * 34])}:${_bcd2String(value[8 + i * 34])}";
        hashMap.addAll({DeviceKey.Date: date});
        int sleepLength = _hexByte2Int(value[9 + i * 34], 0);
        var stringBuffer = StringBuffer();
        try {
          for (int j = 0; j < sleepLength; j++) {
            stringBuffer.write(_hexByte2Int(value[10 + j + i * 34], 0));
            stringBuffer.write(j == sleepLength ? "" : " ");
          }
        } catch (e) {}
        hashMap.addAll({
          DeviceKey.ArraySleep: stringBuffer.toString(),
          DeviceKey.sleepUnitLength: "5"
        });
        list.add(hashMap);
      }
    }
    return maps;
  }

  ///获得血氧数据（自动测试)解析
  static Map getAutoBloodOxygen(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.AutoBloodOxygen,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 10;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.Blood_oxygen: _hexByte2Int(value[9 + i * 10], 0).toString()
      });
      list.add(hashMap);
    }
    return maps;
  }

  ///历史心率数据
  static Map getBloodoxygen(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.Blood_oxygen,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 10;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.Blood_oxygen: _hexByte2Int(value[9 + i * 10], 0).toString()
      });
      list.add(hashMap);
    }
    return maps;
  }

  ///历史心率数据
  static Map getHeartData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetDynamicHR,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 24;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      var stringBuffer = StringBuffer();
      for (int j = 0; j < 15; j++) {
        stringBuffer
            .write(_hexByte2Int(value[9 + j + i * count], 0).toString());
        stringBuffer.write(j == 14 ? "" : " ");
      }
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.ArrayDynamicHR: stringBuffer.toString()
      });
      list.add(hashMap);
    }
    return maps;
  }

  ///单次历史心率数据
  static Map getOnceHeartData(List<int> value) {
    Map maps = {DeviceKey.DataType: BleConst.GetStaticHR, DeviceKey.End: false};
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 10;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0 || (size == 1 && value[1] == 0x99)) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * 10])}.${_bcd2String(value[4 + i * 10])}.${_bcd2String(value[5 + i * 10])} ${_bcd2String(value[6 + i * 10])}:${_bcd2String(value[7 + i * 10])}:${_bcd2String(value[8 + i * 10])}";
      String heart = _hexByte2Int(value[9 + i * 10], 0).toString();
      hashMap.addAll({DeviceKey.Date: date, DeviceKey.StaticHR: heart});
      list.add(hashMap);
    }
    return maps;
  }

  ///htv测试数据
  static Map getHrvTestData(List<int> value) {
    Map maps = {DeviceKey.DataType: BleConst.GetHRVData, DeviceKey.End: false};
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 15;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    if (value[value.length - 1] == 0xff) {
      maps.addAll({DeviceKey.End: true});
    }
    for (int i = 0; i < size; i++) {
      Map<String, String> hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      String hrv = _hexByte2Int(value[9 + i * count], 0).toString();
      String blood = _hexByte2Int(value[10 + i * count], 0).toString();
      String heart = _hexByte2Int(value[11 + i * count], 0).toString();
      String tired = _hexByte2Int(value[12 + i * count], 0).toString();
      String moodValue = _hexByte2Int(value[13 + i * count], 0).toString();
      String breathRate = _hexByte2Int(value[14 + i * count], 0).toString();
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.HRV: hrv,
        DeviceKey.VascularAging: blood,
        DeviceKey.Stress: tired,
        DeviceKey.highBP: moodValue,
        DeviceKey.lowBP: breathRate,
        DeviceKey.HeartRate: heart
      });
      list.add(hashMap);
    }
    return maps;
  }

  ///闹钟数据
  static Map getClockData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetAlarmClock,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 41;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      int flag = 1 + (i + 1) * count;
      if (flag < length && value[flag] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String id = _hexByte2Int(value[4 + i * count], 0).toString();
      String enable = _hexByte2Int(value[5 + i * count], 0).toString();
      String type = _hexByte2Int(value[6 + i * count], 0).toString();
      String hour = _bcd2String(value[7 + i * count]);
      String min = _bcd2String(value[8 + i * count]);
      String week = getByteString(value[9 + i * count]);
      int lengthS = _hexByte2Int(value[10 + i * count], 0);
      String content = "";
      for (int J = 0; J < lengthS; J++) {
        if (value[11 + i * count] == 0) {
          continue;
        }
        content += int2Ascll(_hexByte2Int(value[11 + J + i * count], 0));
      }
      hashMap.addAll({
        DeviceKey.KAlarmId: id,
        DeviceKey.OpenOrClose: enable,
        DeviceKey.ClockType: type,
        DeviceKey.ClockTime: hour,
        DeviceKey.KAlarmMinter: min,
        DeviceKey.Week: week,
        DeviceKey.KAlarmContent: content,
        DeviceKey.KAlarmLength: lengthS.toString()
      });
      list.add(hashMap);
    }
    return maps;
  }

  static Map getTempDataer(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetAxillaryTemperatureDataWithMode,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 11;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0 || value[length - 1] == 0xff) {
      maps.addAll({DeviceKey.End: true});
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      int tempValue = _hexByte2Int(value[9 + i * count], 0) +
          _hexByte2Int(value[10 + i * count], 1);
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.axillaryTemperature: (tempValue * 0.1).toStringAsFixed(1)
      });
      list.add(hashMap);
    }
    return maps;
  }

  static const String TAG = "ResolveUtil";

  static Map getQrCode(List<int> value, bool flag) {
    if (flag) {
      return {
        DeviceKey.DataType: BleConst.EnterQrCode,
        DeviceKey.End: true,
        DeviceKey.Data: {},
      };
    } else {
      if (0x80 == value[1] || 0x81 == value[1]) {
        return {
          DeviceKey.DataType: BleConst.QrCodeBandBack,
          DeviceKey.End: true,
          DeviceKey.Data: {
            DeviceKey.Band: (0x81 == value[1]) ? 1.toString() : 0.toString()
          },
        };
      } else {
        return {
          DeviceKey.DataType: BleConst.ExitQrCode,
          DeviceKey.End: true,
          DeviceKey.Data: {},
        };
      }
    }
  }

  static Map getTempData(List<int> value) {
    Map maps = {};
    List<Map> list = [];
    maps.addAll({
      DeviceKey.DataType: BleConst.Temperature_history,
      DeviceKey.End: false,
      DeviceKey.Data: list
    });
    int count = 11;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0 ||
        value[length - 1] == 0xff ||
        (size == 1 && value[1] == 0x99)) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      if (value[length - 1] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map<String, String> hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      int tempValue = _hexByte2Int(value[9 + i * count], 0) +
          _hexByte2Int(value[10 + i * count], 1);
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.temperature: (tempValue * 0.1).toStringAsFixed(1)
      });
      list.add(hashMap);
    }
    return maps;
  }

  static Map getExerciseData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetActivityModeData,
      DeviceKey.End: false
    };
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    int count = 25;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    for (int i = 0; i < size; i++) {
      int flag = 1 + (i + 1) * count;
      if (flag < length && i == size - 1 && value[flag] == 0xff) {
        maps.addAll({DeviceKey.End: true});
      }
      Map<String, String> hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      String mode = _hexByte2Int(value[9 + i * count], 0).toString();
      String heartRate = _hexByte2Int(value[10 + i * count], 0).toString();
      int periodTime = getData(2, 11 + i * count, value);
      int steps = getData(2, 13 + i * count, value);
      int speedMin = _hexByte2Int(value[15 + i * count], 0);
      int speedS = _hexByte2Int(value[16 + i * count], 0);
      List<int> valueCal = List<int>.generate(4, (int index) {
        return 0;
      });
      for (int j = 0; j < 4; j++) {
        valueCal[3 - j] = value[17 + j + i * count];
      }
      List<int> valueDistance = List<int>.generate(4, (int index) {
        return 0;
      });
      for (int j = 0; j < 4; j++) {
        valueDistance[3 - j] = value[21 + j + i * count];
      }
      double cal = getFloat(valueCal, 0);
      double distance = getFloat(valueDistance, 0);
      hashMap.addAll({
        DeviceKey.Date: date,
        DeviceKey.ActivityMode: mode,
        DeviceKey.HeartRate: heartRate,
        DeviceKey.ActiveMinutes: periodTime.toString(),
        DeviceKey.Step: steps.toString(),
        DeviceKey.Pace:
            "${speedMin.toRadixString(16)}'${speedS.toRadixString(16)}",
        DeviceKey.Distance: distance.toStringAsFixed(2),
        DeviceKey.Calories: cal.toStringAsFixed(1)
      });
      list.add(hashMap);
    }
    return maps;
  }

  static Map getActivityExerciseData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.EnterActivityMode,
      DeviceKey.End: true
    };
    Map map = {};
    maps.addAll({DeviceKey.Data: map});
    int heartRate = _hexByte2Int(value[1], 0);
    int steps = 0;
    double kcal = 0;
    for (int i = 0; i < 4; i++) {
      steps += _hexByte2Int(value[i + 2], i);
    }
    List<int> valueCal = List<int>.generate(4, (index) => 0);
    for (int i = 0; i < 4; i++) {
      valueCal[3 - i] = value[i + 6];
    }
    int time = 0;
    for (int i = 0; i < 4; i++) {
      time += _hexByte2Int(value[i + 10], i);
    }
    kcal = getFloat(valueCal, 0);
    map.addAll({
      DeviceKey.HeartRate: heartRate.toString(),
      DeviceKey.Step: steps.toString(),
      DeviceKey.Calories: kcal.toStringAsFixed(1),
      DeviceKey.ActiveMinutes: time.toString()
    });
    return maps;
  }

  static Map setTimeSuccessful(List<int> value) {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: BleConst.SetDeviceTime,
      DeviceKey.End: true
    };
    Map map = {
      DeviceKey.KPhoneDataLength: _hexByte2Int(value[1], 0).toString()
    };
    maps.addAll({DeviceKey.Data: map});
    return maps;
  }

  static Map setMacSuccessful() {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: BleConst.CMD_Set_Mac,
      DeviceKey.End: true,
      DeviceKey.Data: {}
    };
    return maps;
  }

  static Map getEcgHistoryData(List<int> value) {
    Map maps = {};
    Map list = {};
    maps.addAll({
      DeviceKey.DataType: BleConst.ECGdata,
      DeviceKey.End: false,
      DeviceKey.Data: list
    });
    int length = value.length;
    if (length == 3 ||
        (value[length - 3] == 0x71 &&
            value[length - 2] == 0xff &&
            value[length - 1] == 0xff)) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    int id = _hexByte2Int(value[1], 0) + _hexByte2Int(value[2], 1);
    int offset = 3;
    Map hashMap = {};
    if (id == 0) {
      //第一条
      String date =
          "20${_bcd2String(value[3])}-${_bcd2String(value[4])}-${_bcd2String(value[5])} ${_bcd2String(value[6])}:${_bcd2String(value[7])}:${_bcd2String(value[8])}";
      String hrv = _hexByte2Int(value[11], 0).toString();
      String heart = _hexByte2Int(value[12], 0).toString();
      String moodValue = _hexByte2Int(value[13], 0).toString();
      list.addAll({
        DeviceKey.Date: date,
        DeviceKey.HRV: hrv,
        DeviceKey.HeartRate: heart,
        DeviceKey.ECGMoodValue: moodValue
      });
      offset = 27;
    }
    List<int> tempValue = List<int>.generate(
        length - offset, (index) => 0); //new byte[length - offset];
    BleSDK.arrayCopy(value, offset, tempValue, 0, tempValue.length);
    String ecgData = getEcgDataString(tempValue);
    list.addAll({DeviceKey.ECGValue: ecgData});
    return maps;
  }

  static String getEcgDataString(List<int> value) {
    var stringBuffer = StringBuffer();
    int length = value.length ~/ 2 - 1;
    for (int i = 0; i < length; i++) {
      int ecgValue =
          _hexByte2Int(value[i * 2 + 1], 1) + _hexByte2Int(value[i * 2 + 2], 0);
      if (ecgValue >= 32768) ecgValue = ecgValue - 65536;
      stringBuffer.write(ecgValue);
      stringBuffer.write(",");
    }
    return stringBuffer.toString();
  }

  static Map ecgData(List<int> value) {
    Map maps = {};
    maps.addAll({
      DeviceKey.End: true,
      DeviceKey.DataType: BleConst.EcgppGstatus,
    });
    Map map = {};
    int index = _hexByte2Int(value[1], 0);
    map.addAll({DeviceKey.EcgStatus: index.toString()});
    maps.addAll({DeviceKey.Data: map});
    return maps;
  }

  static Map PPGData(List<int> value) {
    Map maps = {};
    Map<String, List<int>> mapData = {};
    maps.addAll({
      DeviceKey.DataType: BleConst.EcgppGstatus,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    });
    mapData.addAll({DeviceKey.PPGValue: value});
    return maps;
  }

  static Map ECGResult(List<int> value) {
    Map maps = {};
    Map mapData = {};
    maps.addAll({
      DeviceKey.DataType: BleConst.GetEcgPpgStatus,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    });
    int resultValue = _hexByte2Int(value[1], 0);
    if (resultValue == 3) {
      String date =
          "20${_bcd2String(value[10])}.${_bcd2String(value[11])}.${_bcd2String(value[12])} ${_bcd2String(value[13])}:${_bcd2String(value[14])}:${_bcd2String(value[15])}";
      int hrv = _hexByte2Int(value[2], 0);
      int avBlock = _hexByte2Int(value[3], 0);
      int hr = _hexByte2Int(value[4], 0);
      int strees = _hexByte2Int(value[5], 0);
      int highBp = _hexByte2Int(value[6], 0);
      int lowBp = _hexByte2Int(value[7], 0);
      int moodValue = _hexByte2Int(value[8], 0);
      int breathValue = _hexByte2Int(value[9], 0);
      mapData.addAll({
        DeviceKey.Date: date,
        DeviceKey.ECGHrvValue: hrv.toString(),
        DeviceKey.ECGAvBlockValue: avBlock.toString(),
        DeviceKey.ECGHrValue: hr.toString(),
        DeviceKey.ECGStreesValue: strees.toString(),
        DeviceKey.ECGhighBpValue: highBp.toString(),
        DeviceKey.ECGLowBpValue: lowBp.toString(),
        DeviceKey.ECGMoodValue: moodValue.toString(),
        DeviceKey.ECGBreathValue: breathValue.toString()
      });
    }

    return maps;
  }

  static Map enterEcg(List<int> value) {
    Map maps = {};
    Map mapData = {};
    maps.addAll({
      DeviceKey.DataType: BleConst.ENTERECG,
      DeviceKey.End: true,
      DeviceKey.Data: mapData
    });
    return maps;
  }

  static Map measurementWithType(bool flag, List<int> value) {
    if (flag) {
      switch (value[1]) {
        case 1: //hrv
          Map maps = {};
          Map mapData = {};
          maps.addAll({
            DeviceKey.DataType: BleConst.MeasurementHrvCallback,
            DeviceKey.End: true,
            // DeviceKey.Data:mapData
          });
          int hrv = _hexByte2Int(value[4], 0);
          mapData.addAll({DeviceKey.HRV: hrv});
          return maps;
        case 2: //heart
          Map maps = {};
          Map mapData = {};
          maps.addAll({
            DeviceKey.DataType: BleConst.MeasurementHeartCallback,
            DeviceKey.End: true,
            // DeviceKey.Data:mapData
          });
          int hr = _hexByte2Int(value[2], 0);
          mapData.addAll({DeviceKey.HeartRate: hr});
          return maps;
        // return setMethodSuccessful(BleConst.MeasurementHeartCallback);
        case 3: //0xy
          Map maps = {};
          Map mapData = {};
          maps.addAll({
            DeviceKey.DataType: BleConst.MeasurementOxygenCallback,
            DeviceKey.End: true,
            // DeviceKey.Data:mapData
          });
          int spo2 = _hexByte2Int(value[3], 0);
          mapData.addAll({DeviceKey.Blood_oxygen: spo2});
          return maps;
        case 4: //temperature
          Map maps = {};
          Map mapData = {};
          maps.addAll({
            DeviceKey.DataType: BleConst.MeasurementTempCallback,
            DeviceKey.End: true,
            // DeviceKey.Data:mapData
          });
          int tempValue = _hexByte2Int(value[8], 0) + _hexByte2Int(value[9], 1);
          mapData.addAll(
              {DeviceKey.temperature: (tempValue * 0.1).toStringAsFixed(1)});
          return maps;
      }
    } else {
      switch (value[1]) {
        case 1: //hrv
          return setMethodSuccessful(BleConst.StopMeasurementHrvCallback);
        case 2: //heart
          return setMethodSuccessful(BleConst.StopMeasurementHeartCallback);
        case 3: //0xy
          return setMethodSuccessful(BleConst.StopMeasurementOxygenCallback);
        case 4: //temperature
          return setMethodSuccessful(BleConst.StopMeasurementTempCallback);
      }
    }
    return {};
  }

  static Map braceletdial(bool isruning, List<int> value) {
    if (isruning) {
      Map lll = {
        DeviceKey.DataType: BleConst.Braceletdial,
        DeviceKey.End: true
      };
      return lll;
    } else {
      Map lll = {};
      Map lm = {};
      lm.addAll({"index": value[1].toString()});
      lll.addAll({
        DeviceKey.DataType: BleConst.Braceletdialok,
        DeviceKey.End: true,
        DeviceKey.Data: lm
      });
      return lll;
    }
  }

  static Map getSportMode(List<int> value) {
    Map nnn = {DeviceKey.DataType: BleConst.GetSportMode, DeviceKey.End: true};
    var workOutType = StringBuffer();
    int length = _hexByte2Int(value[1], 0);
    for (int i = 0; i < length; i++) {
      //workoutType里没有呼吸模式选项
      int selected = _hexByte2Int(value[i + 2], 0);
      workOutType.write(selected);
      workOutType.write(",");
    }
    nnn.addAll({DeviceKey.Data: workOutType.toString()});
    return nnn;
  }

  static Map gPSControlCommand(List<int> value) {
    Map GPSControlCommand = {
      DeviceKey.DataType: BleConst.GPSControlCommand,
      DeviceKey.End: true
    };
    Map hashMap = {};
    String date =
        "20${_bcd2String(value[1])}-${_bcd2String(value[2])}-${_bcd2String(value[3])} ${_bcd2String(value[4])}:${_bcd2String(value[5])}:${_bcd2String(value[6])}";
    List<int> valueLatitude = List<int>.generate(4, (index) => 0);
    List<int> valueLongitude = List<int>.generate(4, (index) => 0);
    for (int j = 0; j < 4; j++) {
      valueLatitude[3 - j] = value[9 + j];
      valueLongitude[3 - j] = value[14 + j];
    }
    String Latitude = getFloat(valueLatitude, 0).toString();
    String Longitude = getFloat(valueLongitude, 0).toString();
    int count = _hexByte2Int(value[18], 0);
    hashMap.addAll({
      DeviceKey.KActivityLocationTime: date,
      DeviceKey.KActivityLocationLatitude: Latitude,
      DeviceKey.KActivityLocationLongitude: Longitude,
      DeviceKey.KActivityLocationCount: count.toString()
    });
    GPSControlCommand.addAll({DeviceKey.Data: hashMap.toString()});
    return GPSControlCommand;
  }

  static Map setSocial(List<int> value) {
    Map mapsa = {
      DeviceKey.DataType: BleConst.SocialdistanceGetting,
      DeviceKey.End: true
    };
    Map mapll = {};
    int interval = _hexByte2Int(value[2], 0);
    int duration = _hexByte2Int(value[3], 0);
    mapll.addAll({
      "scanInterval": interval.toString(),
      "scanTime": duration,
      "signalStrength": value[4].toString(),
      DeviceKey.Data: mapll
    });
    return mapsa;
  }

  static eCGQuality(List<int> value) {
    Map bn = {};
    Map ccc = {};
    ccc.addAll({
      "heartValue": _hexByte2Int(value[1], 0).toString(),
      "hrvValue": _hexByte2Int(value[2], 0).toString(),
      "Quality": _hexByte2Int(value[3], 0).toString()
    });
    bn.addAll({
      DeviceKey.DataType: BleConst.EcgppG,
      DeviceKey.End: true,
      DeviceKey.Data: ccc
    });
    return bn;
  }

  static Map enterPhotoModeback(List<int> value) {
    Map mapdd = {};
    Map mapbb = {};
    switch (value[1]) {
      case 1:
        mapbb.addAll({"type": value[2] == 0 ? "0" : "1"});
        break;
      case 2:
        mapbb.addAll({"type": "2"});
        break;
      case 3:
        switch (value[2]) {
          case 1:
            mapbb.addAll({"type": "3"});
            break;
          case 2:
            mapbb.addAll({"type": "4"});
            break;
          case 3:
            mapbb.addAll({"type": "5"});
            break;
          case 4:
            mapbb.addAll({"type": "6"});
            break;
          case 5:
            mapbb.addAll({"type": "7"});
            break;
        }
        break;
      case 4:
        mapbb.addAll({"type": "8"});
        break;
    }
    mapdd.addAll({
      DeviceKey.Data: mapbb,
      DeviceKey.DataType: BleConst.DeviceSendDataToAPP,
      DeviceKey.End: true
    });
    return mapdd;
  }

  static Map setNewDeviceInfo(List<int> value) {
    Map maps = {};
    maps.addAll({
      DeviceKey.Data: {},
      DeviceKey.DataType: BleConst.SetNewDeviceInfo,
      DeviceKey.End: true
    });
    return maps;
  }

  static Map getNewDeviceInfo(List<int> value) {
    Map maps = {};
    maps.addAll({
      "KEcg": _hexByte2Int(value[1], 0).toString(),
      DeviceKey.DataType: BleConst.GetNewDeviceInfo,
      DeviceKey.End: true
    });
    return maps;
  }

  static Map updateClockSuccessful(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.SetAlarmClockWithAllClock,
      DeviceKey.End: true,
    };
    Map map = {};
    maps.addAll({DeviceKey.Data: map});
    map.addAll({
      DeviceKey.KClockLast: _hexByte2Int(value[value.length - 1], 0).toString()
    });
    return maps;
  }

  static int getData(int length, int start, List<int> value) {
    int data = 0;
    for (int j = 0; j < length; j++) {
      data += _hexByte2Int(value[j + start], j);
    }
    return data;
  }

  ///字节转浮点
  static double getFloat(List<int> arr, int index) {
    return _intBitToDouble(getInt(arr, index));
  }

  static int getInt(List<int> arr, int index) {
    return (0xff000000 & (arr[index + 0] << 24)) |
        (0x00ff0000 & (arr[index + 1] << 16)) |
        (0x0000ff00 & (arr[index + 2] << 8)) |
        (0x000000ff & arr[index + 3]);
  }

  static Map setMethodSuccessful(String dataType) {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: dataType,
      DeviceKey.End: true,
      DeviceKey.Data: {}
    };
    return maps;
  }

  static Map setBoolSugarStatus(List<int> value) {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: BleConst.BoolsugarStatus,
      DeviceKey.End: true,
      DeviceKey.Data: {DeviceKey.EcgStatus: _hexByte2Int(value[2], 0)}
    };
    return maps;
  }

  static Map setBoolSugarValue(List<int> value) {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: BleConst.BoolsugarValue,
      DeviceKey.End: true
    };
    List<int> tempValue = List<int>.generate(
        value.length - 3, (index) => 0); //new byte[length - offset];
    BleSDK.arrayCopy(value, 3, tempValue, 0, tempValue.length);
    Map map = {};
    List<int> datas = [];
    for (int i = 0; i < tempValue.length ~/ 3; i++) {
      datas.add(_hexByte2Int(tempValue[3 * i], 2) +
          _hexByte2Int(tempValue[3 * i + 1], 1) +
          _hexByte2Int(tempValue[3 * i + 2], 0));
    }
    map.addAll({
      'timestamp': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'ppg': datas
    });
    maps.addAll({DeviceKey.Data: map});
    return maps;
  }

  static Map setMethodError(String dataType) {
    //设置时间成功后返回手机一个数据包的最大长度
    Map maps = {
      DeviceKey.DataType: dataType,
      DeviceKey.End: false,
      DeviceKey.Data: {}
    };
    return maps;
  }

  static int byteArrayToInt(List<int> arr) {
    int targets = ((arr[1] & 0xff) | ((arr[0] << 8) & 0xff00));
    return targets;
  }

  static Map readWomenHealth(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetWomenHealth,
      DeviceKey.End: true,
      DeviceKey.Data: {
        DeviceKey.Date: "${_bcd2String(value[1])}-${_bcd2String(value[2])}",
        DeviceKey.WomenHealthPeriod: _hexByte2Int(value[3], 0),
        DeviceKey.WomenHealthLength: _hexByte2Int(value[4], 0)
      }
    };
    return maps;
  }

  static Map readPregnancyCycle(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetPregnancyCycle,
      DeviceKey.End: true,
      DeviceKey.Data: {
        DeviceKey.Date:
            "20${_bcd2String(value[3])}-${_bcd2String(value[4])}-${_bcd2String(value[5])}",
        DeviceKey.Week: _hexByte2Int(value[1], 0),
        DeviceKey.DayOfWeek: _hexByte2Int(value[2], 0)
      }
    };
    return maps;
  }

  static Map GetTemperatureCorrectionValue(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.CMD_Set_TemperatureCorrection,
      DeviceKey.End: true
    };
    Map mapData = {};
    maps.addAll({DeviceKey.Data: mapData});
    List<int> tempValue = List<int>.generate(2, (index) => 0);
    tempValue[0] = value[3];
    tempValue[1] = value[2];
    int temperatureCorrectionValue = byteArrayToInt(tempValue);
    mapData.addAll({
      DeviceKey.TemperatureCorrectionValue:
          temperatureCorrectionValue.toString()
    });
    return maps;
  }
//
//
//   static String[] getWorkOutReminder(List<int> value) {
//   String[] activityAlarm = new String[6];
//   String startHour = bcd2String(value[1]);
//   String startMin = bcd2String(value[2]);
//   String days= _hexByte2Int(value[3], 0)+"";
//   String week = getByteString(value[4]);
//   int enable=_hexByte2Int(value[5], 0);
//   int time = _hexByte2Int(value[6], 0)+_hexByte2Int(value[7],1);
//
//   activityAlarm[0] = startHour;
//   activityAlarm[1] = startMin;
//   activityAlarm[2] = days;
//   activityAlarm[3] = week;
//   activityAlarm[4] = String.valueOf(enable);
//   activityAlarm[5] = String.valueOf(time);
//
//   return activityAlarm;
//   }
//

  static Map getHistoryGpsData(List<int> value) {
    List<Map> list = [];
    Map mmp = {DeviceKey.DataType: BleConst.Gps, DeviceKey.End: false};
    int count = 59;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      return mmp;
    }
    if ((value[value.length - 1] == 0xff && value[value.length - 2] == 0x5a)) {
      mmp.addAll({DeviceKey.End: true});
    }
    for (int i = 0; i < size; i++) {
      Map<String, String> hashMap = {};
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      List<int> valueLatitude = List<int>.generate(4, (index) => 0);
      List<int> valueLongitude = List<int>.generate(4, (index) => 0);
      var stringBufferLatitude = StringBuffer();
      var stringBufferLongitude = StringBuffer();
      for (int k = 0; k < 6; k++) {
        for (int j = 0; j < 4; j++) {
          valueLatitude[3 - j] = value[9 + j + i * count + k * 8];
          valueLongitude[3 - j] = value[13 + j + i * count + k * 8];
        }
        String Latitude = getFloat(valueLatitude, 0).toString();
        String Longitude = getFloat(valueLongitude, 0).toString();
        stringBufferLatitude.write(Latitude);
        stringBufferLatitude.write(k == 5 ? "" : ",");
        stringBufferLongitude.write(Longitude);
        stringBufferLongitude.write(k == 5 ? "" : ",");
      }
      hashMap.addAll({
        DeviceKey.Date: date.length == 17 ? date : "2019.01.01 00:00:00",
        DeviceKey.Latitude: stringBufferLatitude.toString(),
        DeviceKey.Longitude: stringBufferLongitude.toString()
      });
      list.add(hashMap);
    }
    mmp.addAll({DeviceKey.Data: list.toString()});
    return mmp;
  }

  //ppi测试数据
  static Map getPPITestData(List<int> value) {
    Map maps = {DeviceKey.DataType: BleConst.GetPPIData, DeviceKey.End: false};
    List<Map> list = [];
    maps.addAll({DeviceKey.Data: list});
    //一条的总长度
    int count = 123;
    int length = value.length;
    int size = (length ~/ count);
    if (size == 0) {
      maps.addAll({DeviceKey.End: true});
      return maps;
    }
    if (value[value.length - 1] == 0xff) {
      maps.addAll({DeviceKey.End: true});
    }
    int arraySize = 56;
    for (int i = 0; i < size; i++) {
      var stop = false;
      Map<String, dynamic> hashMap = {};
      //数据编号
      List<int> numList = List<int>.generate(2, (int index) {
        return 0;
      });
      for (int k = 0; k < 2; k++) {
        numList[1 - k] = value[1 + k + i * count];
      }
      int numCode = getInt(numList, 0);
      String date =
          "20${_bcd2String(value[3 + i * count])}.${_bcd2String(value[4 + i * count])}.${_bcd2String(value[5 + i * count])} ${_bcd2String(value[6 + i * count])}:${_bcd2String(value[7 + i * count])}:${_bcd2String(value[8 + i * count])}";
      //数据条数
      int totalId = _hexByte2Int(value[9 + i * count], 0).toInt();
      String ID = _hexByte2Int(value[10 + i * count], 0).toString();
      int startFrame = 11;
      List<double> ppiList = [];
      childFor:
      for (int j = 0; j < arraySize; j++) {
        int tempFrame = startFrame + j * 2;
        List<int> valueCal = List<int>.generate(2, (int index) {
          return 0;
        });
        for (int j = 0; j < 2; j++) {
          valueCal[1 - j] = value[tempFrame + j + i * count];
        }
        double PII = getFloat(valueCal, 0);
        if (PII == 0.0) {
          break childFor;
        }
        ppiList.add(PII);
      }
      hashMap[DeviceKey.TOTAL_ID] = totalId.toString();
      hashMap[DeviceKey.PPI_ID] = ID.toString();
      hashMap[DeviceKey.DeviceTime] = date;
      hashMap[DeviceKey.PPI_LIST] = ppiList;
      hashMap[DeviceKey.PPI_NUM] = numCode;
      list.add(hashMap);
    }
    return maps;
  }

  //获取HRV测量时间
  static Map getHrvTimeData(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetHrvTimeValue,
      DeviceKey.End: true
    };
    Map mapData = {};
    maps.addAll({DeviceKey.Data: mapData});
    mapData.addAll({
      DeviceKey.HRV_TIME_MODE: _hexByte2Int(value[1], 0),
      DeviceKey.HRV_TIME_Value: _hexByte2Int(value[2], 0),
    });
    return maps;
  }

  //断开蓝牙
  static Map CloseDevices(List<int> value) {
    Map maps = {DeviceKey.DataType: BleConst.CloseDevices, DeviceKey.End: true};
    Map mapData = {DeviceKey.RESULT: true};
    maps.addAll({DeviceKey.Data: mapData});
    return maps;
  }

  //脱手检测状态变化主动上报
  static Map GetOffCheckStatus(List<int> value) {
    Map maps = {
      DeviceKey.DataType: BleConst.GetOffCheckStatus,
      DeviceKey.End: true
    };
    Map mapData = {};
    mapData.addAll({
      DeviceKey.GET_OFF_TAG: _hexByte2Int(value[1], 0),
      DeviceKey.GET_OFF_STATE: _hexByte2Int(value[2], 0),
    });
    maps.addAll({DeviceKey.Data: mapData});
    return maps;
  }

  static Map readOxy(List<int> value) {
    print('When Reading this is returning $value');
    Map maps = {
      DeviceKey.DataType: BleConst.GetBloodpressure_calibration,
      DeviceKey.End: true
    };

    Map mapData = {
      DeviceKey.KHrvBloodLowPressure: _hexByte2Int(value[1], 0) + 10,
      DeviceKey.KHrvBloodHighPressure: _hexByte2Int(value[3], 0) + 10,
    };

    maps.addAll({DeviceKey.Data: mapData});
    return maps;
  }
}
