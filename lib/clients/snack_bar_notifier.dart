// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/dictionary_app.dart';
import 'package:rogers_dictionary/i18n.dart' as i18n;

class SnackBarNotifier {
  SnackBarNotifier(this.context);

  BuildContext context;

  void showErrorMessage({
    required String message,
    String? extraText,
  }) {
    _showMessage(
      message: message,
      buttonLabel: i18n.reportBug.get(context),
      onPressed: () {
        DictionaryApp.feedback.showFeedback(extraText: extraText);
      },
    );
  }

  void showRetryMessage({
    required String message,
    required VoidCallback retry,
    String? extraText,
  }) {
    final ScaffoldMessengerState scaffoldMessenger =
    ScaffoldMessenger.of(context);
    _showMessage(
      message: message,
      buttonLabel: i18n.retry.get(context),
      onPressed: () {
        scaffoldMessenger.hideCurrentSnackBar();
        retry();
      },
    );
  }

  void showDismissibleMessage({
    required String message,
  }) {
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    _showMessage(
      message: message,
      buttonLabel: i18n.dismiss.get(context),
      onPressed: scaffoldMessenger.hideCurrentSnackBar,
    );
  }

  void _showMessage({
    required String message,
    required String buttonLabel,
    required VoidCallback onPressed,
  }) {
    // We need to save a reference before calling the post frame callback as
    // context may no longer be valid later.
    final ScaffoldMessengerState scaffoldMessenger =
        ScaffoldMessenger.of(context);
    Future<void>.delayed(Duration.zero).whenComplete(() {
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
          action: SnackBarAction(label: buttonLabel, onPressed: onPressed),
        ),
      );
    });
  }
}
