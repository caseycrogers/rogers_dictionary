import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/dictionary_navigator/animated_listenable_switcher.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/widgets/buttons/close_page.dart';
import 'package:rogers_dictionary/widgets/buttons/drop_down_widget.dart';
import 'package:rogers_dictionary/widgets/buttons/feedback_button.dart';

class DictionaryTopBar extends StatelessWidget {
  const DictionaryTopBar({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  final Widget child;
  final DictionaryTopBarController controller;

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    return Column(
      children: [
        ValueListenableBuilder<TranslationPageModel>(
          valueListenable: dictionaryModel.currTranslationPageModel,
          builder: (context, translationPageModel, _) => Material(
            color: primaryColor(translationPageModel.translationMode),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    AnimatedListenableSwitcher<Function(BuildContext)?>(
                      valueListenable: controller._onClose,
                      builder: (context, onClose, _) => onClose != null
                          ? ClosePage(onClose: onClose)
                          : Container(),
                      transitionBuilder: (child, animation) => SlideTransition(
                        child: child,
                        position: Tween(
                          begin: const Offset(-1, 0),
                          end: Offset.zero,
                        ).animate(animation),
                      ),
                    ),
                    Text(
                      translationPageModel.isEnglish ? 'English' : 'Español',
                      style: Theme.of(context).textTheme.headline1!.copyWith(
                          color: Colors.white,
                          fontSize: Theme.of(context).iconTheme.size),
                    ),
                    DropDownWidget(
                        builder: (_, closeMenu) => Column(
                              children: [
                                FeedbackButton(onPressed: closeMenu),
                              ],
                            ),
                        icon: const Icon(Icons.info)),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: child,
        ),
      ],
    );
  }
}

class DictionaryTopBarController {
  final ValueNotifier<Function(BuildContext)?> _onClose = ValueNotifier(null);

  set onClose(Function(BuildContext)? value) => _onClose.value = value;
}
