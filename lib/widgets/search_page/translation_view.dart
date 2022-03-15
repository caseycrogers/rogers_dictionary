import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/models/search_model.dart';
import 'package:rogers_dictionary/models/translation_model.dart';
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/buttons/opposite_headword_button.dart';
import 'package:rogers_dictionary/widgets/buttons/pronunciation_button.dart';
import 'package:rogers_dictionary/widgets/dictionary_chip.dart';
import 'package:rogers_dictionary/widgets/search_page/abbreviation_view.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_utils.dart';

class TranslationView extends StatelessWidget {
  const TranslationView({
    required this.index,
    required this.translation,
    required this.indent,
    Key? key,
  }) : super(key: key);

  final int index;
  final Translation translation;
  final bool indent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Indent(
          child: _TranslationLine(index: index, translation: translation),
          size: indent ? null : 0.0,
        ),
        _ExamplePhraseView(examplePhrases: translation.examplePhrases),
      ],
    );
  }
}

class _TranslationLine extends StatelessWidget {
  const _TranslationLine({
    required this.index,
    required this.translation,
    Key? key,
  }) : super(key: key);

  final int index;
  final Translation translation;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$index. '),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                ...OverflowMarkdown(translation.text).asSpans(context),
                if (translation.genderAndPlural.isNotEmpty)
                  ...OverflowMarkdown(' *${translation.genderAndPlural}*')
                      .asSpans(context),
                ...AbbreviationView(
                  translation.abbreviation,
                  isHeadword: false,
                ).asSpans(context),
                if (translation.disambiguation.isNotEmpty)
                  ...OverflowMarkdown(
                    ' (*${translation.disambiguation}*)',
                  ).asSpans(context),
                NamingStandardView(namingStandard: translation.namingStandard)
                    .asSpan(context),
                ...ParentheticalView(
                  text: translation.parentheticalQualifier,
                ).asSpans(context),
                WidgetSpan(
                  child: PronunciationButton(
                    text: translation.text.pronounceable,
                    pronunciation: translation.pronunciationOverride
                        .split('|')
                        .join(
                            ' <break time="350ms"/>${i18n.or.get(context)}<break time="150ms"/> ')
                        .emptyToNull,
                    mode: oppositeMode(SearchModel.of(context).mode),
                  ),
                ),
                if (translation.oppositeHeadword.isNotEmpty)
                  WidgetSpan(
                    child: OppositeHeadwordButton(translation: translation),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExamplePhraseView extends StatelessWidget {
  const _ExamplePhraseView({
    required this.examplePhrases,
    Key? key,
  }) : super(key: key);

  final List<String> examplePhrases;

  @override
  Widget build(BuildContext context) {
    if (examplePhrases.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: kPad),
      child: DictionaryChip(
        childPadding: const EdgeInsets.all(kPad / 2),
        color: Colors.grey.shade200,
        borderRadius: kPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${i18n.examplePhrases.get(context)}:',
              style: const TextStyle().asBold,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: examplePhrases
                  .map(
                    (example) => OverflowMarkdown(
                      example.replaceAll('/', ' / '),
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
