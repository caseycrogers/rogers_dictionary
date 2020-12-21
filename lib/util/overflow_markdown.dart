import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class OverflowMarkdown extends StatelessWidget {
  final String data;
  final TextOverflow overflow;
  final TextStyle defaultStyle;
  final List<TextSpan> appendSpans;

  OverflowMarkdown(this.data,
      {this.overflow, this.defaultStyle, this.appendSpans});

  @override
  Widget build(BuildContext context) {
    var spans = <TextSpan>[];
    var isBold = false;
    var isItalic = false;
    var buff = StringBuffer();
    var i = 0;

    TextStyle getTextStyle() =>
        (defaultStyle ?? Theme.of(context).textTheme.bodyText1).copyWith(
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
      overflow: overflow ?? TextOverflow.visible,
      text: TextSpan(
          style: defaultStyle ?? Theme.of(context).textTheme.bodyText1,
          children: spans..addAll(appendSpans ?? [])),
    );
  }
}
