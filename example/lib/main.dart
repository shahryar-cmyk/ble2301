
import 'package:ble2301_example/scan_page.dart';
import 'package:ble2301_example/util/message.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TestDemo',
      translations: Messages(), // 你的翻译
      locale:const Locale('en', 'US'), //const Locale('en', 'US') // 将会按照此处指定的语言翻译
      fallbackLocale:const Locale('zh', 'CN'), // 添加一个回调语言选项，以备上面指定的语言翻译不存在
      // fallbackLocale:const Locale('en', 'US'), // 添加一个回调语言选项，以备上面指定的语言翻译不存在
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue
      ),
      home: ScanPage(),
    );

  }
}
