import 'dart:math';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';

class TranslationModeSelector extends StatefulWidget {
  const TranslationModeSelector({Key? key}) : super(key: key);

  @override
  _TranslationModeSelectorState createState() =>
      _TranslationModeSelectorState();
}

class _TranslationModeSelectorState extends State<TranslationModeSelector> {
  static const double _buttonWidth = 110;
  static const double _buttonHeight = 50;

  double offset = 0;
  PageController? controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (controller == null) {
      controller = DictionaryPageModel.readFrom(context).pageController;
      controller!.addListener(() {
        setState(() {
          offset = controller!.offset;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel pageModel = DictionaryPageModel.of(context);
    final TranslationMode currMode =
        pageModel.translationPageModel.value.translationMode;
    final TranslationMode oppMode = currMode == TranslationMode.English
        ? TranslationMode.Spanish
        : TranslationMode.English;
    final double swipePercent =
        offset == 0 ? 0 : offset / MediaQuery.of(context).size.width;
    final Color color = swipePercent == 0 || swipePercent == 1.0
        ? Colors.black38
        : Color.lerp(
            primaryColor(
                pageModel.translationPageModel.value.translationMode),
            Colors.black,
            .38,
          )!;
    return Container(
      height: _buttonHeight,
      width: 2 * _buttonWidth + Theme.of(context).iconTheme.size!,
      child: Stack(
        children: [
          Positioned(
            left: _buttonWidth,
            height: _buttonHeight,
            child: GestureDetector(
              onTap: () => pageModel.onTranslationModeChanged(context),
              child: Transform(
                transform: Matrix4.rotationY(lerpDouble(
                  0,
                  pi,
                  _superSlowMiddle(swipePercent),
                )!),
                child: const Icon(Icons.swap_horiz, color: Colors.white),
                alignment: Alignment.center,
              ),
            ),
          ),
          AnimatedPositioned(
            left: lerpDouble(
              0,
              _buttonWidth + Theme.of(context).iconTheme.size!,
              currMode == TranslationMode.Spanish
                  ? swipePercent
                  : 1 - swipePercent,
            )!,
            child: _button(context, oppMode, color),
            duration: const Duration(milliseconds: 100),
          ),
          AnimatedPositioned(
            left: lerpDouble(
              0,
              _buttonWidth + Theme.of(context).iconTheme.size!,
              currMode == TranslationMode.English
                  ? swipePercent
                  : 1 - swipePercent,
            )!,
            child: _button(context, currMode, color),
            duration: const Duration(milliseconds: 100),
          ),
        ],
      ),
    );
  }

  Widget _button(BuildContext context, TranslationMode mode, Color color) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    final bool isSelected =
        dictionaryModel.translationPageModel.value.translationMode == mode;
    return Container(
      height: _buttonHeight,
      width: _buttonWidth,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.black38),
          backgroundColor: MaterialStateProperty.resolveWith(
            (states) => states.contains(MaterialState.disabled) ? color : null,
          ),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: isSelected
            ? null
            : () => dictionaryModel.onTranslationModeChanged(context, mode),
        child: Container(
          width: double.infinity,
          child: Text(
            mode == TranslationMode.English ? 'English' : 'Spanish',
            style: Theme.of(context).textTheme.headline1!.copyWith(
                  color: Colors.white,
                  fontSize: 24,
                ),
          ),
        ),
      ),
    );
  }

  double _superSlowMiddle(double t) =>
      Curves.slowMiddle.transform(Curves.slowMiddle.transform(t));
}
