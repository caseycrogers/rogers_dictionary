import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:feedback/feedback.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:path_provider/path_provider.dart';

class FeedbackButton extends StatelessWidget {
  const FeedbackButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      visualDensity: VisualDensity.compact,
      icon: const Icon(Icons.bug_report),
      onPressed: () => {
        BetterFeedback.of(context)!.controller.show(
          (feedbackText, feedbackScreenshot) async {
            final screenshotFilePath =
                await writeImageToStorage(feedbackScreenshot!);

            await FlutterEmailSender.send(
              Email(
                body: feedbackText as String,
                subject: '[Rogers Dictionary Bug Report]',
                recipients: ['caseycrogers@berkeley.edu'],
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
