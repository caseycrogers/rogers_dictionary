import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedantic/pedantic.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/get_dictionary_feedback.dart';

import '../../main.dart';

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
      onPressed: () => _submit(context),
    );
  }

  void _submit(BuildContext context) {
    // Close the menu before displaying feedback.
    onPressed?.call();
    // Log user feedback in analytics
    unawaited(MyApp.analytics.logEvent(
      name: 'feedback_opened',
    ));
    BetterFeedback.of(context).controller.show(
      (userFeedback) async {
        final screenshotFilePath =
            await writeImageToStorage(userFeedback.screenshot);
        final DictionaryFeedback feedback =
            userFeedback.extra!['feedback'] as DictionaryFeedback;
        final String typeString = feedback.type.toString().enumString;

        // Log user feedback in analytics
        unawaited(MyApp.analytics.logEvent(
          name: 'feedback_submitted',
          parameters: feedback.toMap(),
        ));

        await FlutterEmailSender.send(
          Email(
            subject:
                '[Rogers Dictionary - ${typeToString(context, feedback.type)}]'
                ' ${feedback.subject}',
            recipients: [
              'caseycrogers+$typeString@berkeley.edu',
              if (feedback.type == DictionaryFeedbackType.translation_error)
                'glenntrogers+$typeString@gmail.com'
            ],
            body: feedback.body,
            attachmentPaths: [screenshotFilePath],
            isHTML: false,
          ),
        );
      },
    );
  }
}

Future<String> writeImageToStorage(Uint8List feedbackScreenshot) async {
  final Directory output = await getTemporaryDirectory();
  final String screenshotFilePath = '${output.path}/feedback.png';
  final File screenshotFile = File(screenshotFilePath);
  await screenshotFile.writeAsBytes(feedbackScreenshot);
  return screenshotFilePath;
}
