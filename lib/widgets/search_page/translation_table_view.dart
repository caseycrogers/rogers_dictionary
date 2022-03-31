import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/entry_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_chip.dart';
import 'package:rogers_dictionary/widgets/search_page/entry_view.dart';
import 'package:rogers_dictionary/widgets/search_page/translation_view.dart';

class TranslationTableView extends StatelessWidget {
  const TranslationTableView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    if (model.isPreview) {
      return const _PreviewTranslationTable();
    }
    return Column(
      children: model.entry.translationMap.entries.map((entry) {
        return _PartOfSpeechView(
          translations: entry.value,
          inflections: entry.value.first.irregularInflections,
        );
      }).toList(),
    );
  }
}

class _PreviewTranslationTable extends StatelessWidget {
  const _PreviewTranslationTable({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: kPad / 2),
      child: Table(
        columnWidths: const {
          0: IntrinsicColumnWidth(),
        },
        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
        children: model.entry.translationMap.entries.map((e) {
          return TableRow(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: kPad, right: kPad),
                alignment: Alignment.centerRight,
                child: _PartOfSpeechChip(text: e.key),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: kPad),
                child: PreviewTranslationLine(
                  translation: e.value.first,
                  addEllipses: e.value.length > 1,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _PartOfSpeechView extends StatelessWidget {
  const _PartOfSpeechView({
    required this.translations,
    required this.inflections,
    Key? key,
  }) : super(key: key);

  final List<Translation> translations;
  final List<String> inflections;

  String get partOfSpeech => translations.first.partOfSpeech;

  @override
  Widget build(BuildContext context) {
    String parenthetical = '';
    final hasParenthetical = translations
        .any((t) => t.dominantHeadwordParentheticalQualifier.isNotEmpty);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PartOfSpeechChip(text: partOfSpeech),
        _IrregularInflectionsTable(inflections: inflections),
        Indent(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: translations.map((t) {
              final bool parentheticalChanged =
                  t.dominantHeadwordParentheticalQualifier != parenthetical;
              parenthetical = t.dominantHeadwordParentheticalQualifier;
              return Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (parentheticalChanged)
                      Padding(
                        padding: const EdgeInsets.only(top: kPad / 2),
                        child: ParentheticalView(
                          text: parenthetical,
                          addSpace: false,
                        ),
                      ),
                    TranslationView(
                      index: translations.indexOf(t) + 1,
                      translation: t,
                      indent: hasParenthetical && parenthetical != '',
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PartOfSpeechChip extends StatelessWidget {
  const _PartOfSpeechChip({required this.text, Key? key}) : super(key: key);

  final String text;

  @override
  Widget build(BuildContext context) {
    final EntryViewModel model = EntryViewModel.of(context);
    String? pos = ['na', ''].contains(text) ? '-' : text;
    if (!EntryViewModel.of(context).isPreview) {
      final String? longPos = EntryUtils.longPartOfSpeech(
        pos,
        Localizations.localeOf(context).languageCode == 'es',
      );
      if (longPos == null) {
        FirebaseCrashlytics.instance.recordFlutterError(
          FlutterErrorDetails(
            exception: ArgumentError(
              'Entry \'${model.entry.headword.text}\' contained unrecognized '
              'part of speech \'$pos\'',
            ),
          ),
        );
        pos = '$pos*';
      } else {
        pos = longPos;
      }
    }
    if (Localizations.localeOf(context).languageCode == 'es') {
      pos = pos
          .replaceAll(i18n.phrase.en, i18n.phrase.es)
          .spanishAdjectiveReorder(i18n.phrase.es);
    }
    return DictionaryChip(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: Text(
          pos,
          style: const TextStyle().asItalic,
        ),
      ),
    );
  }
}

class _IrregularInflectionsTable extends StatelessWidget {
  const _IrregularInflectionsTable({
    required this.inflections,
    Key? key,
  }) : super(key: key);

  final List<String> inflections;

  @override
  Widget build(BuildContext context) {
    if (inflections.isEmpty) {
      return Container();
    }
    return Padding(
      padding: const EdgeInsets.only(top: kPad / 2, bottom: kPad / 2),
      child: DictionaryChip(
        childPadding: const EdgeInsets.all(kPad / 2),
        color: Colors.grey.shade200,
        borderRadius: kPad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${i18n.irregularInflections.get(context)}:',
              style: const TextStyle().asBold,
            ),
            Table(
              defaultColumnWidth: const IntrinsicColumnWidth(),
              children: [
                ...inflections.map(
                  (i) => TableRow(
                    children: [
                      OverflowMarkdown('${i.split('* ').first.trim()}* '),
                      Indent(
                        child: OverflowMarkdown(
                          i.split('* ').sublist(1).join('* ').trim(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PreviewTranslationLine extends StatelessWidget {
  const PreviewTranslationLine({
    required this.translation,
    required this.addEllipses,
    Key? key,
  }) : super(key: key);

  final Translation translation;
  final bool addEllipses;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: [
        ...OverflowMarkdown(translation.text).asSpans(context),
        if (translation.genderAndPlural.isNotEmpty)
          ...OverflowMarkdown(' *${translation.genderAndPlural}*')
              .asSpans(context),
        if (addEllipses) const TextSpan(text: '...'),
      ]),
    );
  }
}
