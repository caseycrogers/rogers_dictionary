import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary_app.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/text_utils.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text(
        i18n.giveFeedback.get(context),
        style: kButtonTextStyle,
      ),
      onPressed: () {
        onPressed?.call();
        DictionaryApp.feedback.showFeedback();
      },
    );
  }
}