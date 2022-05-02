import 'dart:convert';
import 'dart:io';

import 'package:feedback/feedback.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_feedback_view.dart';

class FeedbackSender {
  FeedbackSender({
    required this.locale,
    required this.feedbackController,
  });

  final http.Client _client = http.Client();
  static final Uri _feedbackUrl = Uri.parse('https://firestore.googleapis.com/'
      'v1/projects/rogers-dictionary/databases/(default)/documents/feedback');
  static final Uri _screenshotUrl =
      Uri.parse('https://firebasestorage.googleapis.com/'
          'v0/b/rogers-dictionary.appspot.com/o/');

  final FeedbackController feedbackController;
  final Locale locale;

  void showFeedback({
    String? extraText,
  }) {
    feedbackController.show(
      (userFeedback) async {
        await _onFeedback(userFeedback, locale, extraText);
      },
    );
    DictionaryApp.analytics.logEvent(
      name: 'feedback_opened',
    );
  }

  Future<void> dispose() async {
    _client.close();
  }

  Future<void> _onFeedback(
    UserFeedback userFeedback,
    Locale locale,
    String? extraText,
  ) async {
    final DictionaryFeedback feedback =
        userFeedback.extra!['feedback'] as DictionaryFeedback;
    final DateTime timestamp = DateTime.now().toUtc();
    final String docId = '${feedback.email.split('@').first}'
        '-${timestamp.toIso8601String().substring(0, 19).replaceAll(':', '-')}';
    final Uri contentUrl = _feedbackUrl.replace(
      queryParameters: <String, String>{'documentId': docId},
    );
    final Uri screenshotPost =
        _screenshotUrl.resolve('feedback%2F$docId%2Fscreenshot.png');
    final http.Response response = await _client.post(
      contentUrl,
      body: json.encode({
        'fields': {
          'to': {'stringValue': 'caseycrogersdev+dictionaryFeedback@gmail.com'},
          'cc': {'stringValue': 'glenntrogers+dictionaryFeedback@gmail.com'},
          'replyTo': {'stringValue': feedback.email},
          'message': {
            'mapValue': {
              'fields': {
                'subject': {
                  'stringValue': '[${feedback.type.toString().enumString}] '
                      '${feedback.body.truncated(20)}...',
                },
                'html': {
                  'stringValue': '''Feedback from ${feedback.email}:<br>
--------------------------------------------<br>
${feedback.body}<br>
<br>
<img height="750" src="$screenshotPost?alt=media"><br>
<br>
Extra details:<br>
--------------------------------------------<br>
${extraText ?? ''}<br>''',
                },
              }
            },
          },
          'type': {'stringValue': feedback.type.toString().enumString},
          'body': {'stringValue': feedback.body},
          'timestamp': {
            'integerValue': timestamp.millisecondsSinceEpoch,
          },
          if (extraText != null) 'extra_text': extraText,
        },
      }),
    );
    if (response.statusCode != 200) {
      await FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: HttpException(
            'Failed to upload feedback content:\n ${response.body}',
            uri: contentUrl,
          ),
          stack: StackTrace.current,
        ),
      );
      DictionaryApp.snackBarNotifier.showRetryMessage(
          message: i18n.feedbackError.getForLocale(locale),
          retry: () {
            _onFeedback(userFeedback, locale, extraText);
          });
      return;
    }
    final http.Response storageResponse = await _client.post(
      screenshotPost,
      headers: {'Content-Type': 'image/png'},
      body: userFeedback.screenshot,
    );
    if (storageResponse.statusCode != 200) {
      await FirebaseCrashlytics.instance.recordFlutterError(
        FlutterErrorDetails(
          exception: HttpException(
            'Failed to upload feedback screenshot:\n ${storageResponse.body}',
            uri: _screenshotUrl,
          ),
          stack: StackTrace.current,
        ),
      );
    }
    DictionaryApp.snackBarNotifier.showDismissibleMessage(
      message: i18n.feedbackSuccess.getForLocale(locale),
    );

    // Log user feedback in analytics
    await DictionaryApp.analytics.logEvent(
      name: 'feedback_submitted',
      parameters: feedback.toMap(),
    );
  }
}
