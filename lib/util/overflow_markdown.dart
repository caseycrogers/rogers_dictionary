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
    final List<TextSpan> spans = [];
    _constructSpans(context).forEach(
      (entry) {
        final s = entry.value;
        if (!entry.key.canWrap) {
          spans.add(s);
          return;
        }
        if (entry.key.isSubscript && spans.isNotEmpty) {
          print('asdf');
          // Subscript should not be wrapped
          spans[spans.length - 1] =
              TextSpan(children: [spans.last, entry.value]);
          return;
        }
        spans.addAll(
          s.text!.split(' ').map(
                (word) => TextSpan(
                  // Add space back in for all but last word
                  text: word == s.text!.split(' ').last ? word : '$word ',
                  style: s.style,
                ),
              ),
        );
      },
    );
    return spans.map((s) => _constructText(context, [s])).toList();
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

  List<MapEntry<_MarkdownStyle, TextSpan>> _constructSpans(
    BuildContext context,
  ) {
    final List<MapEntry<_MarkdownStyle, TextSpan>> spans = [];
    _MarkdownStyle mdStyle = const _MarkdownStyle();
    final StringBuffer buff = StringBuffer();
    int i = 0;
    // Index of user visible characters (excl. parentheses).
    var charIndex = 0;

    TextStyle getTextStyle() {
      final TextStyle baseStyle =
          defaultStyle ?? Theme.of(context).textTheme.bodyText1!;
      return baseStyle
          .merge(mdStyle.overrideStyle?.copyWith(inherit: true))
          .copyWith(
            fontWeight: mdStyle.isBold ? FontWeight.bold : null,
            fontStyle: mdStyle.isItalic ? FontStyle.italic : null,
            fontSize: mdStyle.isSubscript ? baseStyle.fontSize! / 2 : null,
          );
    }

    void addSpan(_MarkdownStyle newMdStyle) {
      if (buff.isEmpty) {
        mdStyle = newMdStyle;
        return;
      }
      spans.add(
        MapEntry(
          mdStyle,
          TextSpan(
            text: buff.toString(),
            style: getTextStyle(),
          ),
        ),
      );
      buff.clear();
      mdStyle = newMdStyle;
    }

    while (i < text.length) {
      if ((overrideStyles ?? []).any((o) => o.matchesStop(i, charIndex))) {
        addSpan(mdStyle.copyWith(clearOverride: true));
      }
      final char = text[i];
      // Skip parentheses BEFORE starting override styles.
      if (['(', ')'].contains(char)) {
        buff.write(char);
        i += 1;
        continue;
      }
      final OverrideStyle? startOverride =
          // Cast is necessary so that `orElse` can return null.
          // ignore: unnecessary_cast
          (overrideStyles ?? []).map((e) => e as OverrideStyle?).firstWhere(
                (o) => o?.matchesStart(i, charIndex) ?? false,
                orElse: () => null,
              );
      if (startOverride != null) {
        addSpan(mdStyle.copyWith(overrideStyle: startOverride.style));
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
        addSpan(mdStyle.copyWith(isBold: !mdStyle.isBold));
        i += 2;
        continue;
      }
      if (char == '*') {
        addSpan(mdStyle.copyWith(isItalic: !mdStyle.isItalic));
        i += 1;
        continue;
      }
      if (char == '`') {
        addSpan(mdStyle.copyWith(isSubscript: !mdStyle.isSubscript));
        i += 1;
        continue;
      }
      buff.write(char);
      charIndex += 1;
      i += 1;
    }
    addSpan(mdStyle);
    assert(!mdStyle.isItalic, 'Unclosed italic mark in $text');
    assert(!mdStyle.isBold, 'Unclosed bold mark in $text');
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

@immutable
class _MarkdownStyle {
  const _MarkdownStyle({
    this.isBold = false,
    this.isItalic = false,
    this.isSubscript = false,
    this.overrideStyle,
  });

  _MarkdownStyle copyWith({
    bool? isBold,
    bool? isItalic,
    bool? isSubscript,
    TextStyle? overrideStyle,
    bool clearOverride = false,
  }) =>
      _MarkdownStyle(
        isBold: isBold ?? this.isBold,
        isItalic: isItalic ?? this.isItalic,
        isSubscript: isSubscript ?? this.isSubscript,
        overrideStyle:
            clearOverride ? null : overrideStyle ?? this.overrideStyle,
      );

  final bool isBold;
  final bool isItalic;
  final bool isSubscript;
  final TextStyle? overrideStyle;

  bool get canWrap => overrideStyle == null;
}
