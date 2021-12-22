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
import 'package:rogers_dictionary/widgets/get_dictionary_feedback.dart';

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

    final http.Response response = await _client.post(
      _feedbackUrl,
      body: json.encode({
        'fields': {
          'type': {'stringValue': feedback.type.toString().enumString},
          'body': {'stringValue': feedback.body},
          'timestamp': {
            'integerValue': DateTime.now().toUtc().millisecondsSinceEpoch,
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
            uri: _feedbackUrl,
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
    final String docId = Uri.parse(jsonDecode(response.body)['name']! as String)
        .pathSegments
        .last;
    final http.Response storageResponse = await _client.post(
      _screenshotUrl.resolve('feedback%2F$docId%2Fscreenshot.png'),
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

    // Log user feedback in analytics
    await DictionaryApp.analytics.logEvent(
      name: 'feedback_submitted',
      parameters: feedback.toMap(),
    );
  }
}
