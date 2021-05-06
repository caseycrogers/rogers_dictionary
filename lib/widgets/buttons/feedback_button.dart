import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feedback/feedback.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.bug_report),
      onPressed: () => {
        BetterFeedback.of(context)!.controller.show(
              (feedback, feedbackScreenshot) {},
            ),
      },
    );
  }
}
