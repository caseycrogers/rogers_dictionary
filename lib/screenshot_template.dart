import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rogers_dictionary/dictionary_app.dart';

Future<void> main() async {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(
    DictionaryScreenshotTemplate(
      headerText: 'Search thousands of terms!',
      background: Container(color: DictionaryApp.englishColorScheme.primary),
      device: Devices.android.onePlus8Pro,
      child: const DictionaryAppBase(overrideLocale: Locale('es')),
    ),
  );
}

class ScreenshotTemplate extends StatelessWidget {
  const ScreenshotTemplate({
    Key? key,
    required this.header,
    required this.background,
    required this.child,
    required this.device,
  }) : super(key: key);

  final Widget header;
  final Widget background;
  final Widget child;
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.only(top: 50),
            width: device.screenSize.width,
            height: device.screenSize.height,
            child: Stack(
              children: [
                background,
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: header,
                    ),
                    Container(
                      width: device.screenSize.width,
                      child: DeviceFrame(
                        device: device,
                        screen: child,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DictionaryScreenshotTemplate extends StatelessWidget {
  const DictionaryScreenshotTemplate({
    Key? key,
    required this.headerText,
    required this.background,
    required this.child,
    required this.device,
  }) : super(key: key);

  final String headerText;
  final Widget background;
  final Widget child;
  final DeviceInfo device;

  @override
  Widget build(BuildContext context) {
    return ScreenshotTemplate(
      header: Text(
        'Search thousands of terms!',
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 32,
        ),
      ),
      background: background,
      device: device,
      child: child,
    );
  }
}
