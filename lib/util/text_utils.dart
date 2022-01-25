import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/protobufs/entry_utils.dart';
import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_chip.dart';

import 'constants.dart';

TextStyle headline1(BuildContext context) => Theme.of(context)
    .textTheme
    .headline1!
    .copyWith(fontWeight: FontWeight.bold);

TextStyle headline2(BuildContext context) =>
    Theme.of(context).textTheme.headline2!;

TextStyle headline3(BuildContext context) =>
    Theme.of(context).textTheme.headline3!;

TextStyle normal1(BuildContext context) =>
    Theme.of(context).textTheme.bodyText2!;

TextStyle bold1(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyText2!
    .copyWith(fontWeight: FontWeight.bold);

TextStyle italic1(BuildContext context) => Theme.of(context)
    .textTheme
    .bodyText2!
    .copyWith(fontStyle: FontStyle.italic);

Text headline1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: headline1(context).copyWith(color: color),
    );

Text headline2Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: headline2(context).copyWith(color: color),
    );

Text headline3Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: headline3(context).copyWith(color: color),
    );

Text normal1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: normal1(context).copyWith(color: color),
    );

Text italic1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: normal1(context).copyWith(
        color: color,
        fontStyle: FontStyle.italic,
      ),
    );

Text bold1Text(BuildContext context, String text, {Color? color}) => Text(
      text,
      style: bold1(context).copyWith(color: color),
    );

const TextStyle kButtonTextStyle = TextStyle(
  color: Colors.black,
  fontSize: 18,
  fontWeight: FontWeight.normal,
);

class Indent extends StatelessWidget {
  const Indent({required this.child, this.size});

  final Widget child;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Padding(
      child: child,
      padding: EdgeInsets.only(left: size ?? 20),
    );
  }
}

List<InlineSpan> parentheticalSpans(
  BuildContext context,
  String text,
) {
  if (text.isEmpty) {
    return [];
  }
  return [
    const WidgetSpan(child: SizedBox(width: kPad / 2)),
    ...text.split(';').expand(
          (t) => [
            if (t != text.split(';').first) const TextSpan(text: ' '),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: kPad / 4),
                child: DictionaryChip(
                  child: Text(t, style: italic1(context)),
                  color: Colors.cyan.shade100.withOpacity(.6),
                ),
              ),
            ),
          ],
        ),
  ];
}
