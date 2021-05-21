import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverflowMarkdown extends StatelessWidget {
  const OverflowMarkdown(
    this.text, {
    this.overflow,
    this.defaultStyle,
    this.overrideStyles,
  });

  final String text;
  final TextOverflow? overflow;
  final TextStyle? defaultStyle;
  final List<OverrideStyle>? overrideStyles;

  List<Widget> forWrap(BuildContext context) {
    return _constructSpans(context).expand(
      (e) {
        final s = e.value;
        // This is an override style, return it unperturbed as highlighted
        // content should not wrap.
        if (e.key)
          return [
            _constructText(context, [s]),
          ];
        return s.text!.split(' ').map(
              (word) => _constructText(
                context,
                [
                  TextSpan(
                    // Add space back in for all but last word
                    text: word == s.text!.split(' ').last ? word : '$word ',
                    style: s.style,
                  ),
                ],
              ),
            );
      },
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return _constructText(
      context,
      _constructSpans(context).map((e) => e.value).toList(),
    );
  }

  Widget _constructText(BuildContext context, List<TextSpan> spans) {
    return RichText(
      overflow: overflow ?? TextOverflow.visible,
      text: TextSpan(
        style: defaultStyle ?? Theme.of(context).textTheme.bodyText1,
        children: spans,
      ),
    );
  }

  List<MapEntry<bool, TextSpan>> _constructSpans(BuildContext context) {
    final List<MapEntry<bool, TextSpan>> spans = [];
    bool isBold = false;
    bool isItalic = false;
    bool isSubscript = false;
    TextStyle? currOverrideStyle;
    final StringBuffer buff = StringBuffer();
    int i = 0;
    // Index of user visible characters (excl. parentheses).
    var charIndex = 0;

    TextStyle getTextStyle() {
      final TextStyle baseStyle =
          defaultStyle ?? Theme.of(context).textTheme.bodyText1!;
      return baseStyle
          .merge(currOverrideStyle?.copyWith(inherit: true))
          .copyWith(
            fontWeight: isBold ? FontWeight.bold : null,
            fontStyle: isItalic ? FontStyle.italic : null,
            fontSize: isSubscript ? baseStyle.fontSize! / 2 : null,
          );
    }

    void addSpan() {
      if (buff.isEmpty) {
        return;
      }
      spans.add(
        MapEntry(
          currOverrideStyle != null,
          TextSpan(
            text: buff.toString(),
            style: getTextStyle(),
          ),
        ),
      );
      buff.clear();
    }

    while (i < text.length) {
      if ((overrideStyles ?? []).any((o) => o.matchesStop(i, charIndex))) {
        addSpan();
        currOverrideStyle = null;
      }
      final char = text[i];
      // Skip parentheses BEFORE starting override styles.
      if (['(', ')'].contains(char)) {
        buff.write(char);
        i += 1;
        continue;
      }
      final OverrideStyle? startOverrideStyle =
          // Cast is necessary so that `orElse` can return null.
          // ignore: unnecessary_cast
          (overrideStyles ?? []).map((e) => e as OverrideStyle?).firstWhere(
                (o) => o?.matchesStart(i, charIndex) ?? false,
                orElse: () => null,
              );
      if (startOverrideStyle != null) {
        addSpan();
        currOverrideStyle = startOverrideStyle.style;
      }
      if (char == '\\') {
        assert(i != text.length,
            'Invalid escape character at end of string in $text');
        buff.write(text[i + 1]);
        charIndex += 1;
        i += 2;
        continue;
      }
      if (i + 1 < text.length && text.substring(i, i + 2) == '**') {
        addSpan();
        isBold = !isBold;
        i += 2;
        continue;
      }
      if (char == '*') {
        addSpan();
        isItalic = !isItalic;
        i += 1;
        continue;
      }
      if (char == '`') {
        addSpan();
        isSubscript = !isSubscript;
        i += 1;
        continue;
      }
      buff.write(char);
      charIndex += 1;
      i += 1;
    }
    addSpan();
    assert(!isItalic, 'Unclosed italic mark in $text');
    assert(!isBold, 'Unclosed bold mark in $text');
    return spans;
  }
}

class OverrideStyle {
  OverrideStyle({
    required this.style,
    required this.start,
    required this.stop,
  }) : assert(start != stop);

  TextStyle style;

  /// When to start applying the override style, inclusive.
  int start;

  /// When to stop applying the override style, exclusive.
  int stop;

  bool matchesStart(int index, int charIndex) => charIndex == start;

  bool matchesStop(int index, int charIndex) => charIndex == stop;
}
