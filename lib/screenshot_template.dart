import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';

Future<void> main() async {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(
    DictionaryScreenshotTemplate(
      headerText: const i18n.Message(
        'Search thousands of terms!',
        '¡Traduzca más de 16K términos médicos en inglés al español!',
      ),
      config: ScreenshotConfig(device: Devices.ios.iPhone13ProMax),
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
    required ScreenshotConfig device,
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
                      Padding(
                        padding: const EdgeInsets.all(4 * kPad),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2*kPad),
                              child: header,
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 2 * kPad),
                                child: DeviceFrame(
                                  device: device,
                                  screen: _SimulatedNavBar(child: child),
                                ),
                              ),
                            ),
                          ],
                        ),
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
    required this.config,
  }) : super(key: key);

  final i18n.Message headerText;
  final Locale locale;
  final ScreenshotConfig config;

  @override
  Widget build(BuildContext context) {
    return ScreenshotTemplate(
      header: Container(
        constraints: BoxConstraints(
            minHeight:
                sizeBigEnoughForAdvanced(config.device.screenSize) ? 50 : 115),
        alignment: Alignment.center,
        child: Text(
          headerText.getForLocale(locale),
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            color: Colors.white,
            fontSize: 32,
          ),
        ),
      ),
      background: ValueListenableBuilder<TranslationModel>(
          valueListenable: DictionaryModel.instance.translationModel,
          builder: (context, translationModel, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _backgroundColor,
                    Color.lerp(_backgroundColor, Colors.white, .7)!,
                  ],
                  stops: const [.7, 1.0],
                ),
              ),
            );
          }),
      device: config,
      child: DictionaryAppBase(overrideLocale: locale),
    );
  }

  Color get _primaryColor {
    return DictionaryModel.instance.isEnglish
        ? DictionaryApp.englishColorScheme.primary
        : DictionaryApp.spanishColorScheme.primary;
  }

  Color get _backgroundColor {
    return Color.lerp(_primaryColor, Colors.white, .2)!;
  }
}

class ScreenshotConfig {
  ScreenshotConfig({
    required this.device,
    double? outputWidth,
    double? outputHeight,
  })  : assert((outputWidth ?? device.screenSize.width) /
                (outputHeight ?? device.screenSize.height) ==
            device.screenSize.aspectRatio),
        outputWidth = outputWidth ?? device.screenSize.width,
        outputHeight = outputHeight ?? device.screenSize.height,
        isLargeScreen = sizeBigEnoughForAdvanced(device.screenSize);

  final DeviceInfo device;
  final double outputWidth;
  final double outputHeight;
  final bool isLargeScreen;
}

class _SimulatedNavBar extends StatelessWidget {
  const _SimulatedNavBar({required this.child, Key? key}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).padding.bottom == 0) {
      return child;
    }
    return Stack(
      children: [
        child,
        Positioned(
          bottom: 0,
          height: MediaQuery.of(context).padding.bottom,
          child: Container(
            width: MediaQuery.of(context).size.width,
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 4,
              width: 175,
              decoration: BoxDecoration(
                color: Colors.white38,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
