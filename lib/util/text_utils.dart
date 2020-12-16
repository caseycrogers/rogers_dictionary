import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:rogers_dictionary/entry_database/entry.dart';

TextStyle _headline1(BuildContext context) =>
    Theme.of(context).textTheme.headline1.copyWith(fontWeight: FontWeight.bold);

TextStyle _normal1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1;

TextStyle _bold1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText1.copyWith(fontWeight: FontWeight.bold);

TextStyle _italic1(BuildContext context) =>
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
    backgroundColor: color,
    padding: EdgeInsets.only(bottom: 1.0, top: -1.0, left: 0.0, right: 0.0),
    label: text);

Widget headwordText(BuildContext context, String text, bool preview) {
  return OverflowMarkdown(
    text,
    TextOverflow.visible,
    defaultStyle: preview ? _bold1(context) : _headline1(context),
  );
}

Widget abbreviationLine(BuildContext context, String text) {
  if (text.isEmpty) return Container();
  return RichText(
      text: TextSpan(
    style: _bold1(context),
    children: [
      TextSpan(
        text: 'abbr ',
        style: _italic1(context),
      ),
      TextSpan(
        text: text,
      ),
    ],
  ));
}

Widget alternateHeadwordLine(
    BuildContext context, String altHeadword, String namingStandard) {
  if (altHeadword.isEmpty) return Container();
  return Row(children: [
    RichText(
        text: TextSpan(
      style: _normal1(context),
      children: [
        TextSpan(text: 'alt. ', style: _italic1(context)),
        TextSpan(text: altHeadword, style: _bold1(context)),
        _namingStandard(context, namingStandard),
      ],
    )),
  ]);
}

TextSpan _namingStandard(BuildContext context, String namingStandard) {
  if (namingStandard == 'i') namingStandard = 'INN';
  if (namingStandard.isNotEmpty) return TextSpan(text: ' $namingStandard');
  return TextSpan();
}

Widget _translationParenthetical(
    BuildContext context, String translationParenthetical) {
  if (translationParenthetical.isNotEmpty)
    return _chip(
        context, Text(' $translationParenthetical', style: _italic1(context)));
  return Container();
}

Widget partOfSpeechText(BuildContext context, String text, bool preview) {
  var pos = ['na', ''].contains(text) ? '-' : text;
  return Container(
    padding: EdgeInsets.only(right: 8.0),
    alignment: Alignment.centerRight,
    child: _chip(
        context,
        Text(
          pos,
          style: _italic1(context),
        )),
  );
}

Widget previewTranslationLine(BuildContext context, String text) {
  return Text(text, style: _normal1(context));
}

Widget translationLine(BuildContext context, Translation translation) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.start,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Expanded(
        child: Padding(
          padding: EdgeInsets.only(
              top: translation.translationParentheticalQualifier.isNotEmpty
                  ? 7.0
                  : 0.0),
          child: OverflowMarkdown(translation.translation, TextOverflow.visible,
              appendSpans: [
                _genderAndPluralText(context, translation.genderAndPlural),
                _namingStandard(context, translation.translationNamingStandard)
              ]),
        ),
      ),
      _translationParenthetical(
          context, translation.translationParentheticalQualifier),
    ],
  );
}

Widget parentheticalText(BuildContext context, String text) {
  if (text.isEmpty) return Container();
  return Chip(
      backgroundColor: Colors.tealAccent.withOpacity(.4),
      padding: EdgeInsets.only(bottom: 1.0, top: -1.0, left: 0.0, right: 0.0),
      label: Text(text, style: _italic1(context)));
}

TextSpan _genderAndPluralText(BuildContext context, String text) {
  if (text.isEmpty) return TextSpan();
  return TextSpan(text: ' $text', style: _italic1(context));
}

Widget editorialText(BuildContext context, String text) {
  return MarkdownBody(
    data: text,
    shrinkWrap: true,
  );
}

class OverflowMarkdown extends StatelessWidget {
  final String data;
  final TextOverflow overflow;
  final TextStyle defaultStyle;
  final List<TextSpan> appendSpans;

  OverflowMarkdown(this.data, this.overflow,
      {this.defaultStyle, this.appendSpans});

  @override
  Widget build(BuildContext context) {
    var spans = <TextSpan>[];
    var isBold = false;
    var isItalic = false;
    var buff = StringBuffer();
    var i = 0;

    TextStyle getTextStyle() => (defaultStyle ?? _normal1(context)).copyWith(
          fontWeight: isBold ? FontWeight.bold : null,
          fontStyle: isItalic ? FontStyle.italic : null,
        );

    addSpan() {
      spans.add(TextSpan(
        text: buff.toString(),
        style: getTextStyle(),
      ));
      buff.clear();
    }

    while (i < data.length) {
      if (data[i] == '\\') {
        assert(i != data.length,
            'Invalid escape character at end of string in $data');
        buff.write(data[i + 1]);
        i += 2;
        continue;
      }
      if (i + 2 < data.length && data.substring(i, i + 2) == '**') {
        if (!isBold) {
          addSpan();
          isBold = true;
        } else {
          addSpan();
          isBold = false;
        }
        i += 2;
        continue;
      }
      if (data[i] == '*') {
        if (!isItalic) {
          addSpan();
          isItalic = true;
        } else {
          addSpan();
          isItalic = false;
        }
        i += 1;
        continue;
      }
      buff.write(data[i]);
      i += 1;
    }
    addSpan();
    assert(!isItalic, "Unclosed italic mark in $data");
    assert(!isBold, "Unclosed bold mark in $data");
    return RichText(
      overflow: overflow,
      text: TextSpan(
          style: defaultStyle ?? Theme.of(context).textTheme.bodyText1,
          children: spans..addAll(appendSpans ?? [])),
    );
  }
}
