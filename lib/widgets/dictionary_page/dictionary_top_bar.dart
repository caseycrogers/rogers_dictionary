import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';

class DictionaryTopBar extends StatelessWidget {
  const DictionaryTopBar({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var dictionaryModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<TranslationPageModel>(
      valueListenable: dictionaryModel.currTranslationPageModel,
      builder: (context, translationPageModel, _) => Material(
        color: primaryColor(translationPageModel.translationMode),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    translationPageModel.isEnglish ? 'English' : 'Español',
                    style: Theme.of(context).textTheme.headline1.copyWith(
                        color: Colors.white,
                        fontSize: Theme.of(context).iconTheme.size),
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.bug_report),
                  onPressed: () {},
                ),
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
    );
  }
}
