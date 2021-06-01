import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rogers_dictionary/widgets/get_dictionary_feedback.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.bug_report),
      onPressed: () => {
        BetterFeedback.of(context).controller.show(
          (userFeedback) async {
            final screenshotFilePath =
                await writeImageToStorage(userFeedback.screenshot);
            final DictionaryFeedback feedback =
                userFeedback.extra!['feedback'] as DictionaryFeedback;
            final String typeString = feedback.type.toString().split('.').last;
            await FlutterEmailSender.send(
              Email(
                subject: '[Rogers Dictionary - ${typeToString(feedback.type)}]'
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
        ),
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
