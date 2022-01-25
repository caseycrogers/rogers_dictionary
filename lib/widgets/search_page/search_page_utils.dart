import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class NamingStandard extends StatelessWidget {
  const NamingStandard({
    required this.namingStandard,
    Key? key,
  }) : super(key: key);

  final String namingStandard;

  @override
  Widget build(BuildContext context) {
    if (namingStandard.isEmpty) {
      return Container();
    }
    return _md(context);
  }

  static String _getLongText(String namingStandard) {
    String text = namingStandard;
    if (namingStandard == 'i') {
      text = 'INN';
    }
    if (namingStandard == 'u') {
      text = 'USAN';
    }
    if (namingStandard == 'i, u') {
      text = 'INN & USAN';
    }
    return ' (*$text* )';
  }

  InlineSpan asSpan(BuildContext context) {
    if (namingStandard.isEmpty) {
      return const TextSpan();
    }
    return _md(context).asSpans(context).single;
  }

  OverflowMarkdown _md(BuildContext context) {
    return OverflowMarkdown(
      _getLongText(namingStandard),
      defaultStyle: headline3(context),
    );
  }
}
