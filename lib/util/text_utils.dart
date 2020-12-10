import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

Text headwordText(BuildContext context, String text, bool preview) {
  if (preview)
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
    );
  return Text(
    text,
    style: Theme.of(context)
        .textTheme
        .headline1
        .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
  );
}

Widget headwordAbbreviationText(BuildContext context, String text) {
  return Text(
    text,
    style: Theme.of(context)
        .textTheme
        .bodyText1
        .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
    overflow: TextOverflow.ellipsis,
  );
}

Widget partOfSpeechText(BuildContext context, String text, bool preview) {
  var pos = ['na', ''].contains(text) ? '-' : text;
  return Container(
    padding: EdgeInsets.only(right: 8.0),
    alignment: Alignment.centerRight,
    child: Chip(
        padding: EdgeInsets.only(bottom: 1.0, top: -1.0, left: 0.0, right: 0.0),
        label: Text(
          pos,
          style: Theme.of(context)
              .textTheme
              .bodyText2
              .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
        )),
  );
}

Widget translationText(BuildContext context, String text, bool preview) {
  return OverflowMarkdown(
      text, preview ? TextOverflow.ellipsis : TextOverflow.visible,
      defaultStyle: Theme.of(context).textTheme.bodyText2);
}

Widget genderAndPluralText(BuildContext context, String text) {
  return Text(
    text,
    style: Theme.of(context)
        .textTheme
        .bodyText2
        .merge(TextStyle(fontStyle: FontStyle.italic, inherit: true)),
  );
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

  OverflowMarkdown(this.data, this.overflow, {this.defaultStyle});

  @override
  Widget build(BuildContext context) {
    var spans = <TextSpan>[];
    var isBold = false;
    var isItalic = false;
    var buff = StringBuffer();
    var i = 0;
    addSpan() {
      spans.add(TextSpan(
        text: buff.toString(),
        style: TextStyle(
          fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
          inherit: true,
        ),
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
          children: spans),
    );
  }
}
