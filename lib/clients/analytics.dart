// Dart imports:
import 'dart:io';

// Package imports:
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

const List<String> DISABLED_IDS = [
  'S2B2.211203.006', // Pixel 5 emulator.
];

Future<void> disableIfTestDevice() async {
  final DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String? deviceId;
  late bool isEmulator;
  if (Platform.isIOS) {
    final IosDeviceInfo info = await deviceInfo.iosInfo;
    deviceId = info.identifierForVendor;
    isEmulator = info.isPhysicalDevice == false;
  } else if (Platform.isAndroid) {
    final AndroidDeviceInfo info = await deviceInfo.androidInfo;
    deviceId = info.id;
    isEmulator = info.isPhysicalDevice == false;
  }
  if (DISABLED_IDS.contains(deviceId) || isEmulator) {
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(false);
  }
}
