import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:mdi/mdi.dart';

Text headwordText(BuildContext context, String text, bool preview) {
  if (preview)
    return Text(
      text,
      style: Theme.of(context)
          .textTheme
          .bodyText1
          .merge(TextStyle(fontWeight: FontWeight.bold, inherit: true)),
      overflow: TextOverflow.ellipsis,
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
  var pos = text == 'na' ? '-' : text;
  return Container(
    padding: EdgeInsets.only(right: 8.0),
    alignment: Alignment.centerRight,
    child: Chip(
        padding: EdgeInsets.all(0.0),
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
  return Text(
    text,
    style: Theme.of(context).textTheme.bodyText2,
    overflow: preview ? TextOverflow.ellipsis : null,
  );
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
