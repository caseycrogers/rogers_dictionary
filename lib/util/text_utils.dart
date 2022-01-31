import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/dictionary_chip.dart';

import 'constants.dart';

extension UtilStyle on TextStyle {
  TextStyle get asBold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get asNotBold => copyWith(fontWeight: FontWeight.normal);

  TextStyle get asItalic => copyWith(fontStyle: FontStyle.italic);

  TextStyle get asNotItalic => copyWith(fontStyle: FontStyle.normal);

  TextStyle asSize(double size) => copyWith(fontSize: size);

  TextStyle asColor(Color color) => copyWith(color: color);
}

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
            WidgetSpan(
              child: DictionaryChip(
                child: Text(
                  t,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                color: Colors.cyan.shade100.withOpacity(.6),
              ),
            ),
          ],
        ),
  ];
}

/// Overrides the text theme's base text style with the specified style. Used
/// instead of `DefaultTextStyle` because default styles are really buggy when
/// used with `Text.rich` and text spans.
class BaseTextStyle extends StatelessWidget {
  const BaseTextStyle({required this.style, required this.child, Key? key})
      : super(key: key);

  final Widget child;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        textTheme: Theme.of(context).textTheme.copyWith(
              bodyText2: style,
            ),
      ),
      child: child,
    );
  }
}
