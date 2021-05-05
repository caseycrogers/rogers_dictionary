import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_chip.dart';
import 'package:rogers_dictionary/widgets/buttons/favorites_button.dart';

import 'overflow_markdown.dart';

TextStyle headline1(BuildContext context) =>
    Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.bold);

TextStyle headline2(BuildContext context) =>
    Theme.of(context).textTheme.headline2;

TextStyle normal1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1;

TextStyle bold1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold);

TextStyle italic1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1.copyWith(fontStyle: FontStyle.italic);

Text headline1Text(BuildContext context, String text, {Color color}) => Text(
      text,
      style: headline1(context).copyWith(color: color),
    );

Text headline2Text(BuildContext context, String text, {Color color}) => Text(
      text,
      style: headline2(context).copyWith(color: color),
    );

Text normal1Text(BuildContext context, String text, {Color color}) => Text(
      text,
      style: normal1(context).copyWith(color: color),
    );

Text bold1Text(BuildContext context, String text, {Color color}) => Text(
      text,
      style: bold1(context).copyWith(color: color),
    );

class Indent extends StatelessWidget {
  final Widget child;
  final double size;

  Indent({@required this.child, this.size});

  @override
  Widget build(BuildContext context) =>
      Padding(child: child, padding: EdgeInsets.only(left: size ?? 20.0));
}

Widget headwordText(BuildContext context, String text, bool preview,
    {@required String searchString}) {
  return OverflowMarkdown(
    text,
    defaultStyle: preview ? bold1(context) : headline1(context),
    overrideStyles: _highlightSearchMatch(context, text, preview, searchString),
  );
}

List<OverrideStyle> _highlightSearchMatch(
    BuildContext context, String text, bool preview, String searchString,
    {bool ignoreSymbols}) {
  var overrideStart = text.searchable.indexOf(searchString.searchable);
  if (!preview || searchString.isEmpty || overrideStart == -1) return [];
  return [
    OverrideStyle(
      style: TextStyle(
          backgroundColor: Theme.of(context).accentColor.withOpacity(.25)),
      start: overrideStart,
      stop: overrideStart + searchString.length,
      ignoreSymbols: ignoreSymbols,
    )
  ];
}

Widget abbreviationLine(
    BuildContext context, String text, bool preview, String searchString) {
  if (text.isEmpty) return Container();
  return OverflowMarkdown(
    '*abbr *$text',
    overrideStyles: _highlightSearchMatch(context, text, preview, searchString),
  );
}

Widget alternateHeadwordLines(BuildContext context,
    List<Headword> alternateHeadwords, bool preview, String searchString) {
  if (alternateHeadwords.isEmpty) return Container();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        child: Text('alt. ', style: italic1(context)),
        padding: EdgeInsets.only(
            top: alternateHeadwords.first.parentheticalQualifier.isEmpty
                ? 0.0
                : 7.0),
      ),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: alternateHeadwords
              .map((alt) => Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      OverflowMarkdown(
                        '**${alt.headwordText}${alt.abbreviation.isEmpty ? '' : ' (${alt.abbreviation})'}**${_namingStandard(context, alt.namingStandard)}',
                        defaultStyle: normal1(context),
                        overflow: preview
                            ? TextOverflow.ellipsis
                            : TextOverflow.visible,
                        overrideStyles: _highlightSearchMatch(context,
                            '**${alt.headwordText}**', preview, searchString),
                      ),
                      if (alt.parentheticalQualifier.isNotEmpty)
                        Text(' ', style: normal1(context)),
                      parentheticalText(context, alt.parentheticalQualifier),
                    ],
                  ))
              .toList(),
        ),
      ),
    ],
  );
}

String _namingStandard(BuildContext context, String namingStandard) {
  if (namingStandard.isEmpty) return '';
  if (namingStandard == 'i') namingStandard = 'INN';
  if (namingStandard == 'u') namingStandard = 'USAN';
  return ' ($namingStandard)';
}

Widget _translationParenthetical(
    BuildContext context, String translationParenthetical) {
  if (translationParenthetical.isNotEmpty)
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Wrap(
        children: translationParenthetical
            .split(';')
            .map((q) => DictionaryChip(
                child:
                    Text(q, style: italic1(context).copyWith(fontSize: 20.0))))
            .toList(),
      ),
    );
  return Container();
}

Widget partOfSpeechText(BuildContext context, String text, bool preview) {
  var pos = ['na', ''].contains(text) ? '-' : text;
  if (!preview) pos = Entry.longPartOfSpeech(pos);
  return Container(
    padding: EdgeInsets.only(right: 8.0),
    child: DictionaryChip(
      child: Text(
        pos,
        style: italic1(context),
      ),
    ),
  );
}

Widget previewTranslationLine(
    BuildContext context, Translation translation, bool addEllipsis) {
  var text = translation.translationText;
  if (translation.genderAndPlural.isNotEmpty)
    text += ' *${translation.genderAndPlural}*';
  if (addEllipsis) text += '...';
  return OverflowMarkdown(text);
}

String _addSpace(String text) => text.isEmpty ? text : ' $text';

Widget translationLine(BuildContext context, Translation translation) {
  return Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      OverflowMarkdown(translation.translationText, children: [
        if (translation.genderAndPlural.isNotEmpty)
          ' *${translation.genderAndPlural}*',
        _namingStandard(context, translation.translationNamingStandard)
      ]),
      _translationParenthetical(
          context, translation.translationParentheticalQualifier),
    ],
  );
}

Widget parentheticalText(BuildContext context, String text) {
  if (text.isEmpty) return Container();
  return DictionaryChip(
    child: Text(text, style: italic1(context)),
    color: Colors.cyan.shade100.withOpacity(.6),
  );
}

Widget editorialText(BuildContext context, String text) {
  return OverflowMarkdown(text);
}

Widget examplePhraseText(BuildContext context, List<String> examplePhrases) {
  if (examplePhrases.isEmpty) return Container();
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      SizedBox(height: 16.0),
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.all(Radius.circular(16.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Example Phrases:', style: italic1(context)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: examplePhrases
                    .map((example) => OverflowMarkdown(
                        example.replaceAll('/', ' / '),
                        defaultStyle: normal1(context).copyWith(height: 1.5)))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget headwordLine(
    BuildContext context, Entry entry, bool preview, String searchString) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          FavoritesButton(entry: entry),
          headwordText(
              context,
              entry.headword.abbreviation.isEmpty
                  ? entry.headword.headwordText
                  : '${entry.headword.headwordText} (${entry.headword.abbreviation})',
              preview,
              searchString: searchString),
          if (entry.headword.parentheticalQualifier.isNotEmpty)
            Text(' ', style: normal1(context)),
          parentheticalText(context, entry.headword.parentheticalQualifier),
        ],
      ),
      alternateHeadwordLines(
          context, entry.alternateHeadwords, preview, searchString),
    ],
  );
}
