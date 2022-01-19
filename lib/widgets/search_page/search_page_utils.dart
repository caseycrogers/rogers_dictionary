import 'package:flutter/material.dart';

import 'package:rogers_dictionary/util/overflow_markdown.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class NamingStandard extends StatelessWidget {
  const NamingStandard({
    required this.isHeadword,
    required this.namingStandard,
    required this.size,
    Key? key,
  }) : super(key: key);

  final bool isHeadword;
  final String namingStandard;
  final double size;

  @override
  Widget build(BuildContext context) {
    assert(namingStandard.isNotEmpty);
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
    return OverflowMarkdown(
      ' (*$text* )',
      defaultStyle: isHeadword
          ? bold1(context)
          : normal1(context).copyWith(fontSize: size),
    );
  }
}