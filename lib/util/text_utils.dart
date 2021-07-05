import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/entry_database/entry_builders.dart';
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/protobufs/entry.pb.dart';
import 'package:rogers_dictionary/util/overflow_markdown_base.dart';
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

const TextStyle kButtonTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 20,
  fontWeight: FontWeight.normal,
);

class Indent extends StatelessWidget {
  const Indent({required this.child, this.size});

  final Widget child;
  final double? size;

  @override
  Widget build(BuildContext context) =>
      Padding(child: child, padding: EdgeInsets.only(left: size ?? 20));
}

List<Widget> highlightedText(
  BuildContext context,
  String text,
  bool preview, {
  bool isHeadword = false,
  required String searchString,
  bool forWrap = true,
}) {
  final overrides = _highlightSearchMatch(context, text, preview, searchString);
  final OverflowMarkdown md = OverflowMarkdown(
    text,
    defaultStyle: !preview && isHeadword ? headline1(context) : bold1(context),
    overrideRules: overrides.keys.toList(),
    overrideStyles: overrides.values.toList(),
  );
  if (forWrap) {
    return md.forWrap(context);
  }
  return [md];
}

LinkedHashMap<OverrideRule, TextStyle> _highlightSearchMatch(
    BuildContext context, String text, bool preview, String searchString) {
  if (!preview || searchString.isEmpty) {
    // ignore: prefer_collection_literals
    return LinkedHashMap();
  }
  // Prepend `text` and `searchString` with spaces to rule out matches that are
  // in the middle of a word.
  Iterable<Match> overrideMatches =
      ' $searchString'.allMatches(' ${text.searchable}');
  bool isOptionalMatch = false;
  if (overrideMatches.isEmpty) {
    overrideMatches =
        ' $searchString'.allMatches(' ${text.withoutOptionals.searchable}');
    isOptionalMatch = true;
  }
  return LinkedHashMap.fromEntries(
    overrideMatches.toList().asMap().entries.map(
      (e) {
        final int start = e.value.start;
        int stop = e.value.end - 1;
        if (isOptionalMatch) {
          // Add the length of the optional back in
          stop +=
              text.searchable.length - text.withoutOptionals.searchable.length;
        }
        return MapEntry(
          OverrideRule(styleIndex: e.key, start: start, stop: stop),
          TextStyle(
              backgroundColor: Theme.of(context).accentColor.withOpacity(.25)),
        );
      },
    ),
  );
}

Widget alternateHeadwordLines(BuildContext context,
    List<Headword> alternateHeadwords, bool preview, String searchString) {
  if (alternateHeadwords.isEmpty) {
    return Container();
  }
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Column(
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
                    if (alt.abbreviation.isNotEmpty) normal1Text(context, ' '),
                    if (alt.abbreviation.isNotEmpty)
                      ...highlightedText(
                          context, '(${alt.abbreviation})', preview,
                          searchString: searchString, forWrap: false),
                    if (alt.namingStandard.isNotEmpty)
                      _namingStandard(context, alt.namingStandard, true),
                    ...parentheticalTexts(
                      context,
                      alt.parentheticalQualifier,
                      true,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ).toList(),
    ),
  );
}

Widget _namingStandard(
    BuildContext context, String namingStandard, bool isHeadword) {
  assert(namingStandard.isNotEmpty);
  String text = namingStandard;
  if (namingStandard == 'i') {
    text = 'INN';
  }
  if (namingStandard == 'u') {
    text = 'USAN';
  }
  return OverflowMarkdown(' (*$text* )',
      defaultStyle: isHeadword ? bold1(context) : null);
}

List<Widget> _translationParentheticals(
    BuildContext context, String translationParenthetical) {
  if (translationParenthetical.isEmpty) {
    return [];
  }
  return translationParenthetical
      .split(';')
      .expand((q) => [
            normal1Text(context, ' '),
            DictionaryChip(
              padding: const EdgeInsets.only(top: 4),
              child: Text(q, style: italic1(context).copyWith(fontSize: 20)),
            )
          ])
      .toList();
}

Widget partOfSpeechText(BuildContext context, String text, bool preview) {
  var pos = ['na', ''].contains(text) ? '-' : text;
  if (!preview) {
    pos = EntryUtils.longPartOfSpeech(pos);
  }
  return Container(
    padding: const EdgeInsets.only(right: 8),
    child: DictionaryChip(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
  if (addEllipsis) {
    text += '...';
  }
  return OverflowMarkdown(text);
}

Widget translationLine(
  BuildContext context,
  Translation translation,
  int i,
) {
  final List<Widget> wraps =
      OverflowMarkdown(translation.content).forWrap(context);
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      normal1Text(context, '${i.toString()}. '),
      Expanded(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            ...wraps.map((t) {
              if (t == wraps.last && translation.oppositeHeadword.isNotEmpty) {
                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      t,
                      IconButton(
                        padding: const EdgeInsets.only(bottom: 2),
                        onPressed: () {
                          DictionaryModel.readFrom(context)
                              .onOppositeHeadwordSelected(
                            context,
                            EntryUtils.urlEncode(
                                translation.getOppositeHeadword),
                          );
                        },
                        icon: const Icon(Icons.open_in_new, color: Colors.grey),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                );
              }
              return t;
            }),
            if (translation.genderAndPlural.isNotEmpty)
              OverflowMarkdown(' *${translation.genderAndPlural}*'),
            if (translation.abbreviation.isNotEmpty) ...[
              normal1Text(context, ' '),
              OverflowMarkdown('(${translation.abbreviation})'),
            ],
            if (translation.namingStandard.isNotEmpty)
              _namingStandard(context, translation.namingStandard, false),
            ..._translationParentheticals(
                context, translation.parentheticalQualifier),
          ],
        ),
      ),
    ],
  );
}

List<Widget> parentheticalTexts(
    BuildContext context, String text, bool addSpace,
    {double? size}) {
  if (text.isEmpty) {
    return [];
  }
  return [
    if (addSpace) normal1Text(context, ' '),
    ...text.split(';').expand(
          (t) => [
            if (t != text.split(';').first) normal1Text(context, ' '),
            DictionaryChip(
              padding: const EdgeInsets.only(top: 4),
              child: Text(t, style: italic1(context).copyWith(fontSize: size)),
              color: Colors.cyan.shade100.withOpacity(.6),
            ),
          ],
        ),
  ];
}

Widget editorialText(BuildContext context, String text) {
  return OverflowMarkdown(text);
}

Widget irregularInflectionsTable(
  BuildContext context,
  List<String> inflections,
) {
  if (inflections.isEmpty) {
    return Container();
  }
  return DictionaryChip(
    childPadding: const EdgeInsets.only(left: 4),
    color: Colors.grey.shade200,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        bold1Text(context, 'Irregular Inflections:'),
        ...inflections.map(
          (i) => OverflowMarkdown(i.trim()),
        ),
      ],
    ),
  );
}

Widget examplePhraseText(BuildContext context, List<String> examplePhrases) {
  if (examplePhrases.isEmpty) {
    return Container();
  }
  return DictionaryChip(
    padding: const EdgeInsets.only(top: 8),
    childPadding: const EdgeInsets.only(left: 4),
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
  final List<Widget> wraps = [
    ...highlightedText(context, entry.headword.headwordText, preview,
        searchString: searchString, isHeadword: true),
    if (entry.headword.abbreviation.isNotEmpty) headline1Text(context, ' '),
    if (entry.headword.abbreviation.isNotEmpty)
      ...highlightedText(context, '(${entry.headword.abbreviation})', preview,
          searchString: searchString, isHeadword: true, forWrap: false),
    ...parentheticalTexts(
      context,
      entry.headword.parentheticalQualifier,
      true,
    ),
  ];
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          ...wraps.getRange(0, wraps.length - 1),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              wraps[wraps.length - 1],
              FavoritesButton(entry: entry),
            ],
          ),
        ],
      ),
      alternateHeadwordLines(
        context,
        entry.alternateHeadwords,
        preview,
        searchString,
      ),
    ],
  );
}
