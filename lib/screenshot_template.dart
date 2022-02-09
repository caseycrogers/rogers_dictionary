import 'package:device_frame/device_frame.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rogers_dictionary/dictionary_app.dart';

Future<void> main() async {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(
    ScreenshotTemplate(
      headerText: 'Search thousands of terms!',
      background: Container(color: DictionaryApp.englishColorScheme.primary),
      device: Devices.ios.iPhone13,
      locale: const Locale('es'),
    ),
  );
}

class ScreenshotTemplate extends StatelessWidget {
  const ScreenshotTemplate({
    Key? key,
    required this.headerText,
    required this.background,
    required this.device,
    required this.locale,
  }) : super(key: key);

  final String headerText;
  final Widget background;
  final DeviceInfo device;
  final Locale locale;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Align(
        alignment: Alignment.topLeft,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.only(top: 50),
            height: device.screenSize.height,
            width: device.screenSize.width,
            child: Stack(
              children: [
                background,
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(5),
                      child: Text(
                        headerText,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.roboto(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 32,
                        ),
                      ),
                    ),
                    Container(
                      child: Align(
                        alignment: Alignment.topLeft,
                        child: Container(
                          width: device.screenSize.width,
                          child: DeviceFrame(
                            device: device,
                            screen: DictionaryAppBase(overrideLocale: locale),
                          ),
                        ),
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
