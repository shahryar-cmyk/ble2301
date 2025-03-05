class Clock {
  ///id
  int? number;

  ///类型 1 普通，2 吃药，3：喝水
  ///type 1 ordinary, 2 taking medication, 3 drinking water
  int type = 0;

  ///小时
  ///hour
  int hour = 0;

  ///分钟
  ///minute
  int minute = 0;

  /// 周日-周六  0 未选  1 选中
  /// Sunday-Saturday  0 not selected 1 selected
  List<String> weeks = ['0', '0', '0', '0', '0', '0', '0'];

  ///备注
  ///remark
  String content = "";

  ///是否开启
  ///Is it enabled
  bool enable = false;

  Clock(
      {this.number,
      required this.type,
      required this.hour,
      required this.minute,
      required this.content,
      required this.enable,
      required this.weeks});
}

class MyPersonalInfo {
  ///1 男,0 女
  ///1 male,0 female
  int sex = 1;

  ///年龄
  ///age
  int age = 0;

  ///身高
  ///stature
  int height = 180;

  ///体重
  ///weight
  int weight = 50;

  ///步长
  ///step length
  int stepLength = 70;
  MyPersonalInfo(
      {required this.sex,
      required this.age,
      required this.height,
      required this.weight});
}

class MySedentaryReminder {
  ///开始运动时间的小时部分
  ///The hour portion of the start of exercise time
  int startHour = 0;

  ///开始运动时间的分钟部分
  ///The minute portion of the start of exercise time
  int startMinute = 0;

  ///结束运动时间的小时部分
  ///Hour portion of end exercise time
  int endHour = 0;

  ///结束运动时间的分钟部分
  ///The minute portion of the ending exercise time
  int endMinute = 0;

  ///选中的星期 pow(2,i)
  ///Selected week pow (2, i)
  int week = 0;

  ///运动提醒周期
  ///Exercise reminder cycle
  int intervalTime = 0;

  ///最少运动步数
  ///Minimum number of motion steps
  int leastStep = 0;

  ///是否开启
  ///Is it enabled
  bool enable = false;

  MySedentaryReminder({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.week,
    required this.intervalTime,
    required this.leastStep,
    required this.enable,
  });
}

class MyDeviceInfo {
  bool DistanceUnit = false; //1 mile（true）,0km(false)
  bool is12Hour = false; //1（12小时）（true），0（24小时制）(false)
  bool Hand_up_light_screen_switch =
      false; //抬手亮屏开关 Raise the hand and turn on the screen
  bool Fahrenheit = false; //华氏温度 Fahrenheit
  bool Nightmode = false; //夜间模式 Night mode
  int baseheart = 60; //Basic heart rate
  int screenBrightness = 0; //屏幕亮度 1- 15
  int indexDial = 0; //表盘 1- 10
  bool socialDistance = false; //社交距离开关
  int languages = 0; //语言 0 英文 1 中文

  MyDeviceInfo(
      {required this.DistanceUnit,
      required this.is12Hour,
      required this.Hand_up_light_screen_switch,
      required this.Fahrenheit,
      required this.Nightmode,
      required this.screenBrightness,
      required this.indexDial,
      required this.socialDistance,
      required this.languages});
}

class WeatherData {
  ///温度
  ///temperature
  int tempNow = 0;

  ///当天最高温度
  ///The highest temperature of the day
  int tempHigh = 0;

  ///当天最低温度
  ///The lowest temperature of the day
  int tempLow = 0;

  ///地点
  ///place
  String cityName = '';

  ///天气 0-38 详细请进入Class内查看
  ///Weather 0-38 For details, please enter the Class to view
  int weatherId = 0;
  WeatherData({
    required this.tempNow,
    required this.tempHigh,
    required this.tempLow,
    required this.cityName,
    required this.weatherId,
  });

  /// Weather
  /// 0 晴（国内城市白天晴）Sunny
  /// 1 晴（国内城市夜晚19晴）Clear
  /// 2 晴（国外城市白天晴）Fair
  /// 3 晴（国外城市夜晚晴）Fair
  /// 4 多云 Cloudy
  /// 5 晴间多云(白天) Partly Cloudy
  /// 6 晴间多云(晚上) Partly Cloudy
  /// 7 大部多云(白天) Mostly Cloudy
  /// 8 大部多云(晚上) Mostly Cloudy
  /// 9 阴 Overcast
  /// 10 阵雨 Shower
  /// 11 雷阵雨 Thundershower
  /// 12 雷阵雨伴有冰雹 Thundershower with Hail
  /// 13 小雨 Light Rain
  /// 14 中雨 Moderate Rain
  /// 15 大雨 Heavy Rain
  /// 16 暴雨 Storm
  /// 17 大暴雨 Heavy Storm
  /// 18 特大暴雨 Severe Storm
  /// 19 冻雨 Ice Rain
  /// 20 雨夹雪 Snow Flurry
  /// 21 阵雪 Snow Flurry
  /// 22 小雪 Light Snow
  /// 23 中雪 Moderate Snow
  /// 24 大雪 Heavy Snow
  /// 25 暴雪 Snowstorm
  /// 26 浮尘 Dust
  /// 27 扬沙 Sand
  /// 28 沙尘暴 Duststorm
  /// 29 强沙尘暴 Sandstorm
  /// 30 雾 Foggy
  /// 31 霾 Haze
  /// 32 风 Windy
  /// 33 大风 Blustery
  /// 34 飓风 Hurricane
  /// 35 热带风暴 Tropical Storm
  /// 36 龙卷风  Tornado
  /// 37 冷 Cold
  /// 38 热 Hot
}

class MyAutomaticHRMonitoring {
  ///1 开启整个时间段都测量 2 时间段内间隔测量 0 关闭
  ///1. Enable measurement throughout the entire time period 2. Measure intervals within the time period 0. Close
  int open = 0;

  ///开始时间的小时部分
  ///Hour portion of start time
  int startHour = 0;

  ///开始时间的分钟部分
  ///The minute portion of the start time
  int startMinute = 0;

  ///结束时间的小时部分
  ///Hour portion of end time
  int endHour = 0;

  ///结束时间的分钟部分
  ///The minute portion of the end time
  int endMinute = 0;

  ///周期 pow(2,i)
  ///Period pow (2, i)
  int week = 0;

  ///最小间隔时间
  ///Minimum interval time
  int time = 0;

  ///1、设置心率 2、设置血氧 3、设置温度 4、HRV测量
  ///1. Set heart rate 2. Set blood oxygen 3. Set temperature 4. HRV measurement
  int type = 1;
  MyAutomaticHRMonitoring({
    required this.open,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.week,
    required this.time,
    required this.type,
  });
}

class Notifier {
  static const int Data_Tel = 0;
  static const int Data_WeChat = 1;
  static const int Data_Sms = 2;
  static const int Data_Facebook = 3;
  static const int Data_Telegra = 4;
  static const int Data_Twitter = 7;
  static const int Data_Vk = 8;
  static const int Data_WhatApp = 9;
  static const int Data_Stop_Tel = 0xff;

  ///类型 0-11 0xFF
  ///type 0-11 0xFF
  int type = 0;

  ///提示内容
  ///Prompt content
  String info = "";

  Notifier({required this.type, required this.info});
}
