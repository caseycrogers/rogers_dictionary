import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';

class TranslationModeSelector extends StatelessWidget {
  const TranslationModeSelector({Key? key}) : super(key: key);

  static const double _buttonWidth = 110;
  static const double _buttonHeight = 50;
  static const double _buttonSpacing = 10;

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel pageModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<double>(
      valueListenable: pageModel.pageOffset,
      builder: (context, offset, _) {
        final double swipePercent =
            offset == 0 ? 0 : offset / MediaQuery.of(context).size.width;
        return Container(
          height: _buttonHeight,
          width: 2 * _buttonWidth + _buttonSpacing,
          child: Stack(
            children: [
              AnimatedPositioned(
                left: lerpDouble(
                  0,
                  _buttonWidth + _buttonSpacing,
                  swipePercent,
                )!,
                child: Container(
                  width: _buttonWidth,
                  height: _buttonHeight,
                  decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                duration: const Duration(milliseconds: 100),
              ),
              Row(
                children: [
                  _button(context, TranslationMode.English),
                  const SizedBox(width: _buttonSpacing),
                  _button(context, TranslationMode.Spanish),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _button(BuildContext context, TranslationMode mode) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    final bool isSelected =
        dictionaryModel.translationPageModel.value.translationMode == mode;
    return Container(
      height: _buttonHeight,
      width: _buttonWidth,
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
}
