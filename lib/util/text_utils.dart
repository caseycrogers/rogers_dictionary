import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/search_page_model.dart';
import 'package:rogers_dictionary/models/translation_page_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_chip.dart';
import 'package:rogers_dictionary/widgets/buttons/favorites_button.dart';

import 'overflow_markdown.dart';

TextStyle headline1(BuildContext context) => Theme.of(context)
    .textTheme
    .headline1!
    .copyWith(fontWeight: FontWeight.bold);

TextStyle headline2(BuildContext context) =>
    Theme.of(context).textTheme.headline2!;

TextStyle normal1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1!;

TextStyle bold1(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyText1!
    .copyWith(fontWeight: FontWeight.bold);

TextStyle italic1(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyText1!
    .copyWith(fontStyle: FontStyle.italic);

Text headline1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: headline1(context).copyWith(color: color),
    );

Text headline2Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: headline2(context).copyWith(color: color),
    );

Text normal1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: normal1(context).copyWith(color: color),
    );

Text italic1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style:
          normal1(context).copyWith(color: color, fontStyle: FontStyle.italic),
    );

Text bold1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: bold1(context).copyWith(color: color),
    );

class Indent extends StatelessWidget {
  final Widget child;
  final double? size;

  Indent({required this.child, this.size});

  @override
  Widget build(BuildContext context) =>
      Padding(child: child, padding: EdgeInsets.only(left: size ?? 20.0));
}

List<Widget> highlightedText(
  BuildContext context,
  String text,
  bool preview, {
  bool isHeadword = false,
  required String searchString,
}) {
  return OverflowMarkdown(
    text,
    defaultStyle: !preview && isHeadword ? headline1(context) : bold1(context),
    overrideStyles: _highlightSearchMatch(context, text, preview, searchString),
  ).forWrap(context);
}

List<OverrideStyle> _highlightSearchMatch(
    BuildContext context, String text, bool preview, String searchString) {
  if (!preview || searchString.isEmpty) return [];
  bool ignoreAccents = SearchPageModel.of(context)
      .entrySearchModel
      .searchSettingsModel
      .ignoreAccents;
  // Prepend `text` and `searchString` with spaces to rule out matches that are
  // in the middle of a word.
  var searchable =
      ' ${ignoreAccents ? text.searchable.withoutDiacriticalMarks : text.searchable}';
  var overrideMatches = ' $searchString'.allMatches(searchable);
  return overrideMatches
      .map(
        (m) => OverrideStyle(
          style: TextStyle(
              backgroundColor: Theme.of(context).accentColor.withOpacity(.25)),
          start: m.start,
          stop: m.end - 1,
        ),
      )
      .toList();
}

Widget alternateHeadwordLines(BuildContext context,
    List<Headword> alternateHeadwords, bool preview, String searchString) {
  if (alternateHeadwords.isEmpty) return Container();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: alternateHeadwords.map(
      (alt) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Only display the alt header for the first entry.
            Opacity(
              opacity: alt == alternateHeadwords.first ? 1.0 : 0.0,
              child: italic1Text(context, 'alt. '),
            ),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  ...highlightedText(context, alt.headwordText, preview,
                      searchString: searchString),
                  if (alt.abbreviation.isNotEmpty)
                    ...highlightedText(context, alt.abbreviation, preview,
                        searchString: searchString),
                  _namingStandard(context, alt.namingStandard, true),
                  ...parentheticalTexts(
                    context,
                    alt.parentheticalQualifier,
                    true,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).toList(),
  );
}

Widget _namingStandard(
    BuildContext context, String namingStandard, isHeadword) {
  if (namingStandard.isEmpty) return Container();
  var text = namingStandard;
  if (namingStandard == 'i') text = 'INN';
  if (namingStandard == 'u') text = 'USAN';
  return OverflowMarkdown(' (*$text* )',
      defaultStyle: isHeadword ? bold1(context) : null);
}

List<Widget> _translationParentheticals(
    BuildContext context, String translationParenthetical) {
  if (translationParenthetical.isEmpty) return [];
  return translationParenthetical
      .split(';')
      .expand((q) => [
            normal1Text(context, ' '),
            DictionaryChip(
                padding: EdgeInsets.only(top: 4.0),
                child:
                    Text(q, style: italic1(context).copyWith(fontSize: 20.0)))
          ])
      .toList();
}

Widget partOfSpeechText(BuildContext context, String text, bool preview) {
  var pos = ['na', ''].contains(text) ? '-' : text;
  if (!preview) pos = EntryUtils.longPartOfSpeech(pos);
  return Container(
    padding: EdgeInsets.only(right: 8.0),
    child: DictionaryChip(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        pos,
        style: italic1(context),
      ),
    ),
  );
}

Widget previewTranslationLine(
    BuildContext context, Translation translation, bool addEllipsis) {
  var text = translation.content;
  if (translation.genderAndPlural.isNotEmpty)
    text += ' *${translation.genderAndPlural}*';
  if (addEllipsis) text += '...';
  return OverflowMarkdown(text);
}

Widget translationLine(BuildContext context, Translation translation, int i) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      normal1Text(context, '${i.toString()}. '),
      ...OverflowMarkdown(translation.content).forWrap(context),
      if (translation.genderAndPlural.isNotEmpty)
        OverflowMarkdown(' *${translation.genderAndPlural}*'),
      if (translation.abbreviation.isNotEmpty)
        OverflowMarkdown(' (${translation.abbreviation})'),
      _namingStandard(context, translation.namingStandard, false),
      ..._translationParentheticals(
          context, translation.parentheticalQualifier),
    ],
  );
}

List<Widget> parentheticalTexts(
    BuildContext context, String text, bool addSpace) {
  if (text.isEmpty) return [];
  return [
    if (addSpace) normal1Text(context, ' '),
    ...text.split(';').expand(
          (t) => [
            if (t != text.split(';').first) normal1Text(context, ' '),
            DictionaryChip(
              padding: EdgeInsets.symmetric(vertical: 4.0),
              child: Text(t, style: italic1(context)),
              color: Colors.cyan.shade100.withOpacity(.6),
            ),
          ],
        ),
  ];
}

Widget editorialText(BuildContext context, String text) {
  return OverflowMarkdown(text);
}

Widget irregularInflectionsTable(BuildContext context, String text) {
  if (text.isEmpty) return Container();
  return DictionaryChip(
    childPadding: EdgeInsets.only(left: 4.0),
    color: Colors.grey.shade200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bold1Text(context,
            'Irregular Inflections (${TranslationPageModel.of(context).isEnglish ? 'EN' : 'ES'}):'),
        ...text.split(';').map(
              (i) => italic1Text(context, i.trim()),
            ),
      ],
    ),
  );
}

Widget examplePhraseText(BuildContext context, List<String> examplePhrases) {
  if (examplePhrases.isEmpty) return Container();
  return DictionaryChip(
    padding: EdgeInsets.only(top: 8.0),
    childPadding: EdgeInsets.only(left: 4.0),
    color: Colors.grey.shade200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Example Phrases:', style: italic1(context)),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: examplePhrases
              .map((example) => OverflowMarkdown(example.replaceAll('/', ' / '),
                  defaultStyle: normal1(context).copyWith(height: 1.5)))
              .toList(),
        ),
      ],
    ),
  );
}

Widget headwordLine(
    BuildContext context, Entry entry, bool preview, String searchString) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          FavoritesButton(entry: entry),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...highlightedText(
                    context, entry.headword.headwordText, preview,
                    searchString: searchString, isHeadword: true),
                if (entry.headword.abbreviation.isNotEmpty)
                  ...highlightedText(
                      context, ' (${entry.headword.abbreviation})', preview,
                      searchString: searchString),
                ...parentheticalTexts(
                  context,
                  entry.headword.parentheticalQualifier,
                  true,
                ),
              ],
            ),
          ),
        ],
      ),
      alternateHeadwordLines(
          context, entry.alternateHeadwords, preview, searchString),
    ],
  );
}
