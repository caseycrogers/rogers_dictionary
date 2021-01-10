import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';
import 'package:rogers_dictionary/util/string_utils.dart';

import 'overflow_markdown.dart';

TextStyle headline1(BuildContext context) =>
    Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.bold);

TextStyle normal1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1;

TextStyle bold1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold);

TextStyle italic1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1.copyWith(fontStyle: FontStyle.italic);

class Indent extends StatelessWidget {
  final Widget child;
  final double size;

  Indent({@required this.child, this.size});

  @override
  Widget build(BuildContext context) =>
      Padding(child: child, padding: EdgeInsets.only(left: size ?? 20.0));
}

Widget _chip(BuildContext context, Text text, {Color color}) => Chip(
    backgroundColor: color ?? Colors.grey.shade300,
    padding: EdgeInsets.zero.add(EdgeInsets.only(bottom: 2.0)),
    label: text,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16.0))));

Widget headwordText(BuildContext context, String text, bool preview,
    {@required String searchString}) {
  return OverflowMarkdown(
    text,
    defaultStyle: preview ? bold1(context) : headline1(context),
    overrideStyles: _getOverrideStyle(context, text, preview, searchString),
  );
}

List<OverrideStyle> _getOverrideStyle(
    BuildContext context, String text, bool preview, String searchString,
    {bool ignoreSymbols}) {
  var overrideStart = text.searchable.indexOf(searchString.searchable);
  if (!preview || searchString.isEmpty || overrideStart == -1) return [];
  return [
    OverrideStyle(
      style: TextStyle(
          backgroundColor: Theme.of(context).accentColor.withOpacity(.5)),
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
    overrideStyles: _getOverrideStyle(context, text, preview, searchString),
  );
}

Widget alternateHeadwordLine(
    BuildContext context,
    List<String> alternateHeadwords,
    List<String> namingStandards,
    bool preview,
    String searchString) {
  if (alternateHeadwords.where((alt) => alt.isNotEmpty).isEmpty)
    return Container();
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('alt. ', style: italic1(context)),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: alternateHeadwords
              .asMap()
              .keys
              .map((i) => OverflowMarkdown(
                    '**${alternateHeadwords[i]}**${_namingStandard(context, namingStandards[i])}',
                    defaultStyle: normal1(context),
                    overflow:
                        preview ? TextOverflow.ellipsis : TextOverflow.visible,
                    overrideStyles: _getOverrideStyle(context,
                        '**${alternateHeadwords[i]}**', preview, searchString),
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
            .map((q) => _chip(context,
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
    child: _chip(
      context,
      Text(
        pos,
        style: italic1(context),
      ),
    ),
  );
}

Widget previewTranslationLine(
    BuildContext context, Translation translation, bool addEllipsis) {
  var text = translation.translation;
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
      OverflowMarkdown(translation.translation, children: [
        _addSpace(translation.genderAndPlural),
        _namingStandard(context, translation.translationNamingStandard)
      ]),
      _translationParenthetical(
          context, translation.translationParentheticalQualifier),
    ],
  );
}

Widget parentheticalText(BuildContext context, String text) {
  if (text.isEmpty) return Container();
  return _chip(
    context,
    Text(text, style: italic1(context)),
    color: Colors.cyan.shade100,
  );
}

Widget editorialText(BuildContext context, String text) {
  return MarkdownBody(
    data: text,
    shrinkWrap: true,
  );
}

Widget examplePhraseText(BuildContext context, String exampleText) {
  if (exampleText.isEmpty) return Container();
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
                children: exampleText
                    .split('...')
                    .map((example) => OverflowMarkdown(example,
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
      headwordText(
          context,
          entry.headwordAbbreviation.isEmpty
              ? entry.headword
              : '${entry.headword} (${entry.headwordAbbreviation})',
          preview,
          searchString: searchString),
      alternateHeadwordLine(context, entry.alternateHeadwords,
          entry.alternateHeadwordNamingStandards, preview, searchString),
    ],
  );
}
