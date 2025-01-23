// import 'package:flutter_test/flutter_test.dart';
// import 'package:ble2301/ble2301.dart';
// import 'package:ble2301/ble2301_platform_interface.dart';
// import 'package:ble2301/ble2301_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';
//
// class MockBle2301Platform
//     with MockPlatformInterfaceMixin
//     implements Ble2301Platform {
//
//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }
//
// void main() {
//   final Ble2301Platform initialPlatform = Ble2301Platform.instance;
//
//   test('$MethodChannelBle2301 is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelBle2301>());
//   });
//
//   test('getPlatformVersion', () async {
//     Ble2301 ble2301Plugin = Ble2301();
//     MockBle2301Platform fakePlatform = MockBle2301Platform();
//     Ble2301Platform.instance = fakePlatform;
//
//     expect(await ble2301Plugin.getPlatformVersion(), '42');
//   });
// }
