

class DeviceKey {
  static const String DataType = "dataType";
  static const String Data = "dicData";
  static const String End = "dataEnd";

  static const String KGpsResCheck0 = "KGpsResCheck0"; // 设备时间   GET_DEVICE_Time
  static const String KGpsResCheck1 = "KGpsResCheck1"; // 设备时间

  static const String KFinishFlag = "finish";
  static const String DeviceTime = "strDeviceTime"; // 设备时间   GET_DEVICE_Time
  static const String GPSTime = "gpsExpirationTime"; // 设备时间   GET_DEVICE_Time
  static const String TimeZone = "TimeZone"; // 设备时间   GET_DEVICE_Time


  static const String Band = "Band";
  /*
     *  GET_PERSONAL_INFO
     *   sex         性别
     *   Age         年龄
     *   Height      身高
     *   Weight      体重
     *   stepLength  步长
     *   deviceId    设备ID
     */
  static const String Gender = "MyGender";
  static const String Age = "MyAge";
  static const String Height = "MyHeight";
  static const String Weight = "MyWeight";
  static const String Stride = "MyStride";
  static const String KUserDeviceId = "deviceId";


  /*
     *  GET_DEVICE_INFO
     *  distanceUnit  距离单位
     *  hourState     12小时24小时显示
     *  handleEnable  抬手检查使能标志
     *  handleSign    抬手检测左右手标志
     *  screenState   横竖屏显示
     *  anceEnable    ANCS使能开关
     */
  static const String DistanceUnit = "distancUnit";
  static const String TimeUnit = "timeUnit";
  static const String TempUnit = "temperatureUnit";
  static const String WristOn = "wristOn";
  static const String TemperatureUnit = "TemperatureUnit";
  static const String StatusOfTheRaisedHandOnscreen = "Status_of_the_raised_hand_on_screen";
  static const String NightMode = "NightMode";
  static const String LeftOrRight = "handleSign";
  //static const String ScreenShow = "screenState";
  static const String Dialinterface = "dialinterface";
  static const String SocialDistancedwitch = "SocialDistancedwitch";
  static const String ChineseOrEnglish= "ChineseOrEnglish";
  static const String ScreenBrightness = "dcreenBrightness";
  static const String KBaseHeart = "baseHeartRate";
  static const String isHorizontalScreen = "isHorizontalScreen";
  static const String Weather = "Weather";
  static const String DialSwitch = "DialSwitch";

  /*
     *  SET_STEP_MODEL
     *totalSteps   总步数
     *calories     卡路里
     *distance     距离
     *time         时间
     *heartValue   心率值
     */

  static const String Step = "step";
  static const String Calories = "calories";
  static const String Distance = "distance";
  static const String ExerciseMinutes = "exerciseMinutes";
  static const String HeartRate = "heartRate";
  static const String ActiveMinutes = "ExerciseTime";
  static const String TempData = "TempData";
  static const String StepGoal = "stepGoal";   // 目标步数值  GET_GOAL
  static const String DistanceGoal = "distanceGoal";   // 目标距离值  GET_GOAL
  static const String CalorieGoal = "calorieGoal";   // 目标卡路里值  GET_GOAL
  static const String SleepTimeGoal = "sleepTimeGoal";   // 睡眠目标值  GET_GOAL

  static const String BatteryLevel = "batteryLevel";  // 电量级别    READ_DEVICE_BATTERY
  static const String MacAddress = "macAddress"; // MAC地址    READ_MAC_ADDRESS
  static const String DeviceVersion = "deviceVersion";  // 版本号     READ_VERSION
  static const String DeviceName = "deviceName";  // 设备名称    GET_DEVICE_NAME
  static const String TemperatureCorrectionValue = "TemperatureCorrectionValue";  // 设备名称    GET_DEVICE_NAME

  /*
     *  GET_AUTOMIC_HEART
     *workModel         工作模式
     *heartStartHour    开始运动时间的小时
     *heartStartMinter  开始运动时间的分钟
     *heartEndHour      结束运动时间的小时
     *heartEndMinter      结束运动时间的分钟
     *heartWeek         星期使能
     *workTime          工作模式时间
     */
  static const String WorkMode = "workModel";
  static const String StartTime = "heartStartHour";
  static const String KHeartStartMinter = "heartStartMinter";
  static const String EndTime = "heartEndHour";
  static const String KHeartEndMinter = "heartEndMinter";
  static const String Weeks = "weekValue";
  static const String IntervalTime = "intervalTime";


  /*
     *  READ_SPORT_PERIOD
     *StartTimeHour       开始运动时间的小时
     *StartTimeMin     开始运动时间的分钟
     *EndTimeHour         结束运动时间的小时
     *EndTimeMin       结束运动时间的分钟
     *Week      星期使能
     *KSportNotifierTime    运动提醒周期
     */
  static const String StartTimeHour = "sportStartHour";
  static const String StartTimeMin = "sportStartMinter";
  static const String EndTimeHour = "sportEndHour";
  static const String EndTimeMin = "sportEndMinter";

  static const String LeastSteps = "leastSteps";

  /*
     *  GET_STEP_DATA
     *historyDate       日期：年月日
     *historySteps      步数
     *historyTime       运动时间
     *historyDistance   距离
     *Calories  卡路里
     *historyGoal       目标
     */
  static const String Date = "date";
  static const String Goal = "goal";



  /*
     *  GET_STEP_DETAIL
     *Date       日期：年月日时分秒
     *ArraySteps          步数
     *Calories       卡路里
     *Distance       距离
     *KDetailMinterStep     10分钟内每一分钟的步数
     */

  static const String ArraySteps = "arraySteps";

  static const String KDetailMinterStep = "detailMinterStep";
  static const String temperature = "temperature";
  static const String axillaryTemperature = "axillaryTemperature";

  /*
     * GET_SLEEP_DETAIL
     *Date        日期：年月日时分秒
     *KSleepLength      睡眠数据的长度
     *ArraySleep    5分钟的睡眠质量 (总共24个数据，每一个数据代表五分钟)
     */

  static const String KSleepLength = "sleepLength";
  static const String ArraySleep = "arraySleepQuality";
  static const String sleepUnitLength = "sleepUnitLength";//是不是一分钟的睡眠数据 1为1分钟数据 0为5分钟数据

  /*
     *  GET_HEART_DATA
     *Date        日期：年月日时分秒
     *ArrayDynamicHR        10秒一个心率值，总共12个心率值
     */

  static const String ArrayDynamicHR = "arrayDynamicHR";
  static const String Blood_oxygen = "Blood_oxygen";


  /*
     * GET_ONCE_HEARTDATA
     *Date        日期：年月日时分秒
     *StaticHR       心率值
     */

  static const String StaticHR = "onceHeartValue";

  /*
     *  GET_HRV_DATA
     *Date          日期：年月日时分秒
     *HRV         HRV值
     *VascularAging    血管老化度值
     *HeartRate    心率值
     *Stress         疲劳度
     */

  static const String HRV = "hrv";
  static const String VascularAging = "vascularAging";

  static const String Stress = "stress";
  static const String HighPressure = "highPressure";
  static const String LowPressure = "lowPressure";
  static const String highBP = "highBP";
  static const String lowBP = "lowBP";

  /*
     *GET_ALARM
     *KAlarmId          0到4闹钟编号
     *ClockType        闹钟类型
     *ClockTime        闹钟时间的小时
     *KAlarmMinter      闹钟时间的分钟
     *Week  星期使能
     *KAlarmLength      长度
     *KAlarmContent     文本的内容
     */
  static const String KAlarmId = "alarmId";
  static const String OpenOrClose = "clockOpenOrClose";
  static const String ClockType = "clockType";
  static const String ClockTime = "alarmHour";
  static const String KAlarmMinter = "alarmMinter";
  static const String Week = "weekValue";
  static const String DayOfWeek = "DayOfWeek";
  static const String KAlarmLength = "alarmLength";
  static const String KAlarmContent = "dicClock";


  /***********************GET_HRV_TESTDATA***************************************************/
  /*
     *KBloodTestLength      数据长度
     *KBloodTestProgress    进度
     *KBloodTestValue       本次PPG获得的值
     *KBolldTestCurve       本次波型的高度
     */
  static const String KBloodTestLength = "bloodTestLength";
  static const String KBloodTestProgress = "bloodTestProgress";
  static const String KBloodTestValue = "bloodTestValue";
  static const String KBloodTestCurve = "bloodTestCurve";

  /*
     *KBloodResultPercent       反弹的百分比
     *KBloodResultRebound       平均反弹高度
     *KBloodResultMax           最大高度
     *KBloodResultRank          结果级别（1到6）
     */
  static const String KBloodResultPercent = "bloodPercent";
  static const String KBloodResultRebound = "bloodRebound";
  static const String KBloodResultMax = "bloodResultMax";
  static const String KBloodResultRank = "bloodResultRank";


  /*
     *KHrvTestProgress  进度
     *KHrvTestWidth     本次心跳的宽度
     *KHrvTestValue     心率值
     */
  static const String KHrvTestProgress = "hrvTestProgress";
  static const String KHrvTestWidth = "hrvTestWidth";
  static const String KHrvTestValue = "hrvTestValue";

  /*
     *KHrvResultState   SDNN结果  如果是0,说明检测失败
     *KHrvResultAvg     SDNN平均值
     *KHrvResultTotal   总SDNN结果
     *KHrvResultCount   有效数据个数
     *KHrvResultTired   疲劳指数据
     *KHrvResultValue   心率值
     */
  static const String KHrvResultState = "hrvResultState";
  static const String KHrvResultAvg = "hrvResultAvg";
  static const String KHrvResultTotal = "hrvResultTotal";
  static const String KHrvResultCount = "hrvResultCount";
  static const String KHrvResultTired = "hrvResultTired";
  static const String KHrvResultValue = "hrvResultValue";


  /*
     *KDisturbState     1:开始运动   0：停止运动
     *KSlipHand         1: 带在手上   0;脱手。
     *KPPGData          PPG的波型值
     */
  static const String KDisturbState = "disturbState";
  static const String KSlipHand = "slipHand";
  static const String KPPGData = "ppgData";


  /*
     *@param Date       时间：年月日时分秒
     *@param Latitude   纬度数据
     *@param Longitude  经度数据
     */


  static const String Latitude = "locationLatitude";
  static const String Longitude = "locationLongitude";

  static const String KActivityLocationTime = "ActivityLocationTIme";
  static const String KActivityLocationLatitude = "ActivityLocationLatitude";
  static const String KActivityLocationLongitude = "ActivityLocationLongitude";
  static const String KActivityLocationCount = "KActivityLocationCount";
/*
 *      GET_SPORTMODEL_DATA
 *@param  Date        时间：年月日时分秒
 *@param  ActivityMode 运动类型
 0=Run,
 1=Cycling,
 2=Swimming,
 3=Badminton,
 4=Football,
 5=Tennis,
 6=Yoga,
 7=Medication,
 8=Dance
 
 *@param  HeartRate       心率
 *@param  ActiveMinutes   运动时间
 *@param  Step       运动步数
 *@param  Pace       运动速度
 *@param  Calories    卡路里
 *@param  Distance     距离
 */


  static const String ActivityMode = "sportModel";
  static const String Pace = "sportModelSpeed";

  static const String KDataID = "KDataID";
  static const String KPhoneDataLength = "KPhoneDataLength";
  static const String KClockLast = "KClockLast";


  static const String TakePhotoMode = "TakePhotoMode";
  static const String KFunction_tel = "TelMode";
  static const String KFunction_reject_tel = "RejectTelMode";

  static const String FindMobilePhoneMode = "FindMobilePhoneMode";
  static const String KEnable_exercise = "KEnable_exercise";
  static const String ECGQualityValue = "ECGQualityValue";

  static const String ECGResultValue = "ECGResultVALUE";
  static const String ECGHrvValue = "ECGHrvValue";
  static const String ECGAvBlockValue = "ECGAvBlockValue";
  static const String ECGHrValue = "ECGHrValue";
  static const String ECGStreesValue = "ECGStreesValue";
  static const String ECGhighBpValue = "ECGhighBpValue";
  static const String ECGLowBpValue = "ECGLowBpValue";
  static const String ECGMoodValue = "ECGMoodValue";
  static const String ECGBreathValue = "ECGBreathValue";
  static const String ECGValue = "ECGValue";
  static const String PPGValue = "PPGValue";
  static const String EcgStatus = "EcgStatus";


  static const String WomenHealthPeriod = "womenHealthPeriod";//经期
  static const String WomenHealthLength = "womenHealthLength";//周期

  //PPI
  static const String TOTAL_ID = "totalID";
  static const String PPI_ID = "ppiId";
  static const String PPI_LIST = "ppiListValue";
  static const String PPI_NUM = "ppiNum";

  //HRV
  static const String HRV_TIME_MODE="hrvTimeMode";
  static const String HRV_TIME_Value="hrvTimeValue";

  //脱手检测状态
  static const String GET_OFF_TAG = "getOffTag";
  static const String GET_OFF_STATE="getOffState";

  static const String RESULT = "result";



}
