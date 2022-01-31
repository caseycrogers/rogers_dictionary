import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/overflow_markdown_base.dart';

class OverflowMarkdown extends StatelessWidget {
  OverflowMarkdown(
    this.text, {
    this.overflow,
    this.defaultStyle,
    this.overrideRules,
    this.overrideStyles,
  })  : assert(overrideRules?.length == overrideStyles?.length),
        base = MarkdownBase(
          text,
          overrideRules,
        );

  final String text;
  final TextOverflow? overflow;
  final TextStyle? defaultStyle;
  final List<OverrideRule>? overrideRules;
  final List<TextStyle>? overrideStyles;
  final MarkdownBase base;

  List<InlineSpan> asSpans(BuildContext context) {
    final List<TextSpan> spans = [];
    base.constructSpans().forEach(
      (entry) {
        final s = entry.value;
        final textStyle = getTextStyle(context, entry.key);
        if (!entry.key.canWrap) {
          spans.add(TextSpan(text: s, style: textStyle));
          return;
        }
        if (entry.key.isSubscript && spans.isNotEmpty) {
          // Subscript should not be wrapped
          spans[spans.length - 1] = TextSpan(
            children: [
              spans.last,
              TextSpan(text: s, style: textStyle),
            ],
          );
          return;
        }
        spans.add(
          TextSpan(text: s, style: textStyle),
        );
      },
    );
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return _constructText(
      context,
      base
          .constructSpans()
          .map(
            (e) => TextSpan(text: e.value, style: getTextStyle(context, e.key)),
          )
          .toList(),
    );
  }

  Widget _constructText(BuildContext context, List<TextSpan> spans) {
    return Text.rich(
      TextSpan(
        style: defaultStyle ?? DefaultTextStyle.of(context).style,
        children: spans,
      ),
      overflow: overflow ?? TextOverflow.visible,
    );
  }

  TextStyle getTextStyle(BuildContext context, MarkdownStyle mdStyle) {
    final TextStyle baseStyle =
        defaultStyle ?? DefaultTextStyle.of(context).style;
    if (mdStyle.isDefault) {
      return baseStyle;
    }
    return baseStyle.copyWith(
      fontWeight: mdStyle.isBold ? FontWeight.bold : null,
      fontStyle: mdStyle.isItalic ? FontStyle.italic : null,
      fontSize: mdStyle.isSubscript ? _subscriptHeight(context) : null,
    );
  }

  double _subscriptHeight(BuildContext context) {
    return (defaultStyle?.fontSize ??
            DefaultTextStyle.of(context).style.fontSize!) /
        2;
  }
}
