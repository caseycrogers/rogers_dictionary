import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverflowMarkdown extends StatelessWidget {
  final String data;
  final List<String> children;
  final TextOverflow overflow;
  final TextStyle defaultStyle;
  final List<OverrideStyle> overrideStyles;

  get fullText => data + (children?.join() ?? '');

  OverflowMarkdown(this.data,
      {this.children, this.overflow, this.defaultStyle, this.overrideStyles});

  @override
  Widget build(BuildContext context) {
    var spans = <TextSpan>[];
    var isBold = false;
    var isItalic = false;
    TextStyle currOverrideStyle;
    var buff = StringBuffer();
    var i = 0;
    var charIndex = 0;

    TextStyle getTextStyle() =>
        (defaultStyle ?? Theme.of(context).textTheme.bodyText1)
            .merge(currOverrideStyle?.copyWith(inherit: true))
            .copyWith(
              fontWeight: isBold ? FontWeight.bold : null,
              fontStyle: isItalic ? FontStyle.italic : null,
            );

    void addSpan() {
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
      var startOverrideStyle = (overrideStyles ?? [])
          .firstWhere((o) => o.matchesStart(i, charIndex), orElse: () => null);
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
      if (fullText[i] == '*') {
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
      buff.write(fullText[i]);
      charIndex += 1;
      i += 1;
    }
    addSpan();
    assert(!isItalic, "Unclosed italic mark in $fullText");
    assert(!isBold, "Unclosed bold mark in $fullText");
    return RichText(
      overflow: overflow ?? TextOverflow.visible,
      text: TextSpan(
          style: defaultStyle ?? Theme.of(context).textTheme.bodyText1,
          children: spans),
    );
  }
}

class OverrideStyle {
  TextStyle style;
  int start;
  int stop;
  bool ignoreSymbols;

  bool get _shouldIgnoreSymbols => ignoreSymbols ?? false;

  OverrideStyle(
      {@required this.style,
      @required this.start,
      @required this.stop,
      this.ignoreSymbols})
      : assert(start != stop);

  bool matchesStart(int index, int charIndex) =>
      _shouldIgnoreSymbols ? charIndex == this.start : index == this.start;

  bool matchesStop(int index, int charIndex) =>
      _shouldIgnoreSymbols ? charIndex == this.stop : index == this.stop;
}
