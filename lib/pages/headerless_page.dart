import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';

class HeaderlessPage extends StatelessWidget {
  const HeaderlessPage({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    Future.delayed(
        Duration.zero, () => DictionaryTopBar.of(context).onClose = null);
    return child;
  }
}
