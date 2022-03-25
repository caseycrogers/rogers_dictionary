import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';

Future<void> main() async {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(
    DictionaryScreenshotTemplate(
      headerText: const i18n.Message(
        'Search thousands of terms!',
        'buscar por asd;flkj;lkasjdf',
      ),
      device: ScreenshotDevice(device: Devices.android.onePlus8Pro),
      locale: const Locale('es'),
    ),
  );
}

const double kTopPad = 50;

class ScreenshotTemplate extends StatelessWidget {
  ScreenshotTemplate({
    Key? key,
    required this.header,
    required this.background,
    required this.child,
    required ScreenshotDevice device,
  })  : device = device.device,
        outputWidth = device.outputWidth,
        outputHeight = device.outputHeight,
        super(key: key);

  final Widget header;
  final Widget background;
  final Widget child;
  final DeviceInfo device;
  final double outputWidth;
  final double outputHeight;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Builder(builder: (context) {
        return Padding(
          padding: const EdgeInsets.only(top: kTopPad) /
              MediaQuery.of(context).devicePixelRatio,
          child: Transform.scale(
            alignment: Alignment.topLeft,
            scale: (outputWidth / device.screenSize.width) /
                MediaQuery.of(context).devicePixelRatio,
            child: Align(
              alignment: Alignment.topLeft,
              child: Material(
                type: MaterialType.transparency,
                child: SizedBox(
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
                            padding:
                                const EdgeInsets.symmetric(horizontal: 5),
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
          ),
        );
      }),
    );
  }
}

class DictionaryScreenshotTemplate extends StatelessWidget {
  const DictionaryScreenshotTemplate({
    Key? key,
    required this.headerText,
    required this.locale,
    required this.device,
  }) : super(key: key);

  final i18n.Message headerText;
  final Locale locale;
  final ScreenshotDevice device;

  @override
  Widget build(BuildContext context) {
    return ScreenshotTemplate(
      header: Text(
        headerText.getForLocale(locale),
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 32,
        ),
      ),
      background: Container(
        color: _backgroundColor,
      ),
      device: device,
      child: DictionaryAppBase(overrideLocale: locale),
    );
  }

  Color get _backgroundColor {
    return Color.lerp(
      DictionaryModel.instance.isEnglish
          ? DictionaryApp.englishColorScheme.primary
          : DictionaryApp.spanishColorScheme.primary,
      Colors.white,
      .2,
    )!;
  }
}

class ScreenshotDevice {
  ScreenshotDevice({
    required this.device,
    double? outputWidth,
    double? outputHeight,
  })  : assert((outputWidth ?? device.screenSize.width) /
                (outputHeight ?? device.screenSize.height) ==
            device.screenSize.aspectRatio),
        outputWidth = outputWidth ?? device.screenSize.width,
        outputHeight = outputHeight ?? device.screenSize.height;

  final DeviceInfo device;
  final double outputWidth;
  final double outputHeight;
}
