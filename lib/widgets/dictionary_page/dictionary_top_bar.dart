import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/widgets/buttons/close_page.dart';
import 'package:rogers_dictionary/widgets/buttons/feedback_button.dart';

class DictionaryTopBar extends StatelessWidget {
  DictionaryTopBar({Key? key, required this.child}) : super(key: key);

  final Widget child;
  final ValueNotifier<VoidCallback?> _onClose = ValueNotifier(null);

  set onClose(VoidCallback? value) => _onClose.value = value;

  static DictionaryTopBar of(BuildContext context) =>
      context.read<DictionaryTopBar>();

  @override
  Widget build(BuildContext context) {
    var dictionaryModel = DictionaryPageModel.of(context);
    return Column(
      children: [
        ValueListenableBuilder<TranslationPageModel>(
          valueListenable: dictionaryModel.currTranslationPageModel,
          builder: (context, translationPageModel, _) => Material(
            color: primaryColor(translationPageModel.translationMode),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(4),
                child: Row(
                  children: [
                    ValueListenableBuilder<VoidCallback?>(
                      valueListenable: _onClose,
                      builder: (context, onClose, _) => onClose != null
                          ? ClosePage(onClose: onClose)
                          : Container(),
                    ),
                    Expanded(
                      child: Text(
                        translationPageModel.isEnglish ? 'English' : 'Español',
                        style: Theme.of(context).textTheme.headline1!.copyWith(
                            color: Colors.white,
                            fontSize: Theme.of(context).iconTheme.size),
                      ),
                    ),
                    FeedbackButton(),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: Icon(Icons.help),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: Provider.value(
            value: this,
            child: child,
          ),
        ),
      ],
    );
  }
}
