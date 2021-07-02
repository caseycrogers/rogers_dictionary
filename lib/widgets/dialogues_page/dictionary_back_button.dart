import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class DictionaryBackButton extends StatelessWidget {
  const DictionaryBackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DictionaryPageModel dictionaryModel = DictionaryPageModel.of(context);
    return ValueListenableBuilder<int>(
      valueListenable: dictionaryModel.netDepth,
      builder: (context, depth, _) {
        if (depth == 0) {
          return Container();
        }
        return const BackButton();
      },
    );
  }
}
