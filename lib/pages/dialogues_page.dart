import 'package:async_list_view/async_list_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/entry_database/dialogue.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';

class DialoguesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var dialoguesPageModel = DictionaryPageModel.of(context).dialoguesPageModel;
    return Material(
      elevation: 0.0,
      color: Theme.of(context).cardColor,
      child: AsyncListView<Dialogue>(
        stream: dialoguesPageModel.dialogueStream,
        itemBuilder: (context, dialogues, index) {
          return Text(dialogues.data[index].englishContent);
        },
      ),
    );
  }
}
