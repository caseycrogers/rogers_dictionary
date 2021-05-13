import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverflowMarkdown extends StatelessWidget {
  final String data;
  final List<String>? children;
  final TextOverflow? overflow;
  final TextStyle? defaultStyle;
  final List<OverrideStyle>? overrideStyles;

  get fullText => data + (children?.join() ?? '');

  OverflowMarkdown(
    this.data, {
    this.children,
    this.overflow,
    this.defaultStyle,
    this.overrideStyles,
  });

  List<Widget> forWrap(BuildContext context) {
    return _constructSpans(context)
        .expand(
          (s) => s.text!.split(' ').map(
                (word) => _constructText(
                  context,
                  [
                    TextSpan(
                      // Add space back in for all but first word
                      text: word == s.text!.split(' ').first ? word : ' $word',
                      style: s.style,
                    ),
                  ],
                ),
              ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return _constructText(context, _constructSpans(context));
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

  List<TextSpan> _constructSpans(BuildContext context) {
    var spans = <TextSpan>[];
    var isBold = false;
    var isItalic = false;
    var isSubscript = false;
    TextStyle? currOverrideStyle;
    var buff = StringBuffer();
    var i = 0;
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
      if (buff.isEmpty) return;
      spans.add(TextSpan(
        text: buff.toString(),
        style: getTextStyle(),
      ));
      buff.clear();
    }

    while (i < fullText.length) {
      if ((overrideStyles ?? []).any((o) => o.matchesStop(i, charIndex))) {
        addSpan();
        currOverrideStyle = null;
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
      if (fullText[i] == '\\') {
        assert(i != fullText.length,
            'Invalid escape character at end of string in $fullText');
        buff.write(fullText[i + 1]);
        charIndex += 1;
        i += 2;
        continue;
      }
      if (i + 1 < fullText.length && fullText.substring(i, i + 2) == '**') {
        addSpan();
        isBold = !isBold;
        i += 2;
        continue;
      }
      if (fullText[i] == '*') {
        addSpan();
        isItalic = !isItalic;
        i += 1;
        continue;
      }
      if (fullText[i] == '`') {
        addSpan();
        isSubscript = !isSubscript;
        i += 1;
        continue;
      }
      buff.write(fullText[i]);
      charIndex += 1;
      i += 1;
    }
    addSpan();
    assert(!isItalic, "Unclosed italic mark in $fullText");
    assert(!isBold, "Unclosed bold mark in $fullText");
    return spans;
  }
}

class OverrideStyle {
  TextStyle style;
  int start;
  int stop;
  bool ignoreSymbols;

  OverrideStyle({
    required this.style,
    required this.start,
    required this.stop,
    this.ignoreSymbols = false,
  }) : assert(start != stop);

  bool matchesStart(int index, int charIndex) =>
      ignoreSymbols ? charIndex == this.start : index == this.start;

  bool matchesStop(int index, int charIndex) =>
      ignoreSymbols ? charIndex == this.stop : index == this.stop;
}
