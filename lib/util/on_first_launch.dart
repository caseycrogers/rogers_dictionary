import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _hasLaunched = 'has_launched';

Future<void> onFirstLaunch(VoidCallback onLaunchFunction) async {
  final SharedPreferences preferences = await SharedPreferences.getInstance();
  final bool hasLaunched = preferences.getBool(_hasLaunched) ?? false;
  if (!hasLaunched) {
    //await preferences.setBool(_hasLaunched, true);
    onLaunchFunction();
  }
}
