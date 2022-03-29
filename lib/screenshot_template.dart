import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/layout_picker.dart';

Future<void> main() async {
  WidgetsApp.debugAllowBannerOverride = false;
  runApp(
    DictionaryScreenshotTemplate(
      headerText: const i18n.Message(
        'Search thousands of terms!',
        'buscar por ',
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
                      ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(5),
                            child: header,
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: DeviceFrame(
                              device: device,
                              screen: _SimulatedNavBar(child: child),
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
    required this.config,
  }) : super(key: key);

  final i18n.Message headerText;
  final Locale locale;
  final ScreenshotConfig config;

  @override
  Widget build(BuildContext context) {
    return ScreenshotTemplate(
      header: Text(
        headerText.getForLocale(locale),
        textAlign: TextAlign.center,
        style: GoogleFonts.roboto(
          color: Colors.white,
          fontSize: 32,
        ),
      ),
      background: ValueListenableBuilder<TranslationModel>(
          valueListenable: DictionaryModel.instance.translationModel,
          builder: (context, translationModel, child) {
            return Container(
              color: _backgroundColor,
            );
          }),
      device: config,
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
