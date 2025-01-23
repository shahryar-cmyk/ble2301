import 'package:shared_preferences/shared_preferences.dart';

///SharedPreferences 工具类
class SpUtils{

  static SharedPreferences? _sharedPreferences;

  ///初始化
  static Future<SharedPreferences?> init() async{
    if(_sharedPreferences == null){
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    return _sharedPreferences;
  }

  static void putString(String key,String value){
    if(_sharedPreferences != null){
      _sharedPreferences!.setString(key, value);
    }else{
      print('SpUtil工具未初始化');
    }
  }

  static String getString(String key){
    if(_sharedPreferences != null){
      if(_sharedPreferences!.containsKey(key)){
        return _sharedPreferences!.get(key) as String;
      }else{
        return "";
      }
    }else{
      print('SpUtil工具未初始化');
      return "";
    }
  }



}