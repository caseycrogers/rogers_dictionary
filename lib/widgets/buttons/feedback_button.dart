import 'package:flutter/material.dart';

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/widgets/buttons/help_menu.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key, this.onPressed}) : super(key: key);

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return HelpMenuButton(
      icon: Icons.bug_report,
      text: i18n.giveFeedback.get(context),
      onTap: () {
        onPressed?.call();
        DictionaryApp.feedback.showFeedback();
      },
    );
  }
}
