import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';

class TranslationModeSelector extends StatelessWidget {
  const TranslationModeSelector({Key? key}) : super(key: key);

  static const _englishKey = ValueKey('spanishButton');
  static const _spanishKey = ValueKey('englishButton');

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel pageModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<double>(
      valueListenable: pageModel.pageOffset,
      builder: (context, pageOffset, _) =>
          Container(
            height: _Button._buttonHeight,
            child: Stack(
              children: [
                AnimatedPositioned(
                  left: lerpDouble(
                    0,
                    100 + _Button._buttonSpacing,
                    pageOffset,
                  )!,
                  child: Container(
                    width: 100,
                    height: _Button._buttonHeight,
                    decoration: BoxDecoration(
                      color: Colors.black38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  duration: const Duration(milliseconds: 100),
                ),
                Row(
                  children: const [
                    _Button(TranslationMode.English, key: _englishKey),
                    SizedBox(width: _Button._buttonSpacing),
                    _Button(TranslationMode.Spanish, key: _spanishKey),
                  ],
                ),
              ],
            ),
          ),
    );
  }
}

class _Button extends StatelessWidget {
  const _Button(this.mode, {Key? key}) : super(key: key);

  static const double _buttonHeight = 50;
  static const double _buttonSpacing = 10;

  final TranslationMode mode;

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    final bool isSelected =
        dictionaryModel.translationPageModel.value.translationMode == mode;
    return Container(
      height: _buttonHeight,
      child: TextButton(
        style: ButtonStyle(
          overlayColor: MaterialStateProperty.all(Colors.black38),
          splashFactory: NoSplash.splashFactory,
        ),
        onPressed: isSelected
            ? null
            : () => dictionaryModel.onTranslationModeChanged(context, mode),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            mode == TranslationMode.English
                ? i18n.english.cap.get(context)
                : i18n.spanish.cap.get(context),
            style: Theme
                .of(context)
                .textTheme
                .headline1!
                .copyWith(
              color: Colors.white,
              fontSize: 24,
            ),
          ),
        ),
      ),
    );
  }
}
