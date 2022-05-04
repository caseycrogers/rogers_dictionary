import 'package:email_validator/email_validator.dart';
import 'package:feedback/feedback.dart';

import 'package:flutter/material.dart';
import 'package:rogers_dictionary/clients/database_constants.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/constants.dart';
import 'package:rogers_dictionary/util/string_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DictionaryFeedback {
  DictionaryFeedback(this.body, this.type, this.email);

  final String body;
  final DictionaryFeedbackType type;
  final String email;

  Map<String, String> toMap() {
    return {'body': body, 'type': type.toString().enumString, 'email': email};
  }
}

class _DictionaryFeedbackBuilder {
  String? body;
  DictionaryFeedbackType type = DictionaryFeedbackType.bug_report;
  String? _email;

  String? get email => _email;

  set email(String? newValue) => _email = newValue?.trimRight();

  DictionaryFeedback build() {
    return DictionaryFeedback(body ?? '', type, _email!);
  }
}

enum DictionaryFeedbackType {
  translation_error,
  bug_report,
  feature_request,
  other,
}

String typeToString(Locale locale, DictionaryFeedbackType type) {
  switch (type) {
    case DictionaryFeedbackType.bug_report:
      return i18n.bugReport.getForLocale(locale);
    case DictionaryFeedbackType.feature_request:
      return i18n.featureRequest.getForLocale(locale);
    case DictionaryFeedbackType.translation_error:
      return i18n.translationError.getForLocale(locale);
    case DictionaryFeedbackType.other:
      return i18n.other.getForLocale(locale);
  }
}

class DictionaryFeedbackView extends StatefulWidget {
  const DictionaryFeedbackView(this.onSubmit, this.controller, {Key? key})
      : super(key: key);

  final OnSubmit onSubmit;
  final ScrollController controller;

  @override
  _DictionaryFeedbackViewState createState() => _DictionaryFeedbackViewState();
}

class _DictionaryFeedbackViewState extends State<DictionaryFeedbackView> {
  final _feedbackBuilder = _DictionaryFeedbackBuilder();
  final TextEditingController _emailController = TextEditingController();
  final Future<SharedPreferences> sharedPreferences =
      SharedPreferences.getInstance();

  // Necessary to prevent double submissions from pressing the button
  // repeatedly.
  bool _submitted = false;

  // Whether the user just attempted a failed submit. Used to determine if the
  // invalid error should be displayed.
  bool _failedSubmit = false;

  @override
  void initState() {
    sharedPreferences.then((sharedPreferences) {
      final String? cachedEmail = sharedPreferences.getString(feedbackEmail);
      if (cachedEmail != null) {
        setState(() {
          _emailController.value = TextEditingValue(text: cachedEmail);
          _feedbackBuilder.email = cachedEmail;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                // The stack is necessary to make the feedback drag handle work.
                child: Stack(
                  children: [
                    ListView(
                      // 20 is the radius of feedback's rounded corners.
                      padding: const EdgeInsets.all(20),
                      controller: widget.controller,
                      children: [
                        Row(
                          children: [
                            Text('${i18n.feedbackType.cap.get(context)}: '),
                            DropdownButton<DictionaryFeedbackType>(
                              value: _feedbackBuilder.type,
                              items: DictionaryFeedbackType.values.map(
                                (feedbackType) {
                                  return DropdownMenuItem<
                                      DictionaryFeedbackType>(
                                    child: Text(
                                      typeToString(
                                        Localizations.localeOf(context),
                                        feedbackType,
                                      ),
                                    ),
                                    value: feedbackType,
                                  );
                                },
                              ).toList(),
                              onChanged: (feedbackType) {
                                setState(() {
                                  _feedbackBuilder.type = feedbackType!;
                                });
                              },
                            ),
                          ],
                        ),
                        TextField(
                          minLines: 1,
                          maxLines: 10,
                          decoration: InputDecoration(
                            helperText: i18n.feedback.cap.get(context),
                          ),
                          onChanged: (value) => _feedbackBuilder.body = value,
                        ),
                        TextField(
                          keyboardType: TextInputType.emailAddress,
                          controller: _emailController,
                          decoration: InputDecoration(
                            errorText: _feedbackBuilder.email == null ||
                                    EmailValidator.validate(
                                        _feedbackBuilder.email!)
                                ? null
                                : i18n.emailError.cap.get(context),
                            helperText: i18n.email.cap.get(context),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _feedbackBuilder.email = value;
                            });
                          },
                        ),
                      ],
                    ),
                    const FeedbackSheetDragHandle(),
                  ],
                ),
              ),
              TextButton(
                // Display null if we've submitted or we've already failed to submit
                // and haven't fixed the form yet.
                onPressed: !_submitted && !(_failedSubmit && !_isValid)
                    ? () {
                        if (!_isValid) {
                          // Display error message and expand sheet.
                          setState(() {
                            _failedSubmit = true;
                            BetterFeedback.of(context)
                                .sheetController
                                .animateTo(
                                  1,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.linear,
                                )
                                .then((_) {
                              WidgetsBinding.instance!.addPostFrameCallback(
                                  (timeStamp) => _simulateDrag());
                            });
                          });
                          return;
                        }
                        sharedPreferences.then(
                          (db) {
                            return db.setString(
                              feedbackEmail,
                              _feedbackBuilder.email!,
                            );
                          },
                        );
                        setState(() {
                          _submitted = true;
                        });
                        widget.onSubmit(
                          '',
                          extras: <String, DictionaryFeedback>{
                            'feedback': _feedbackBuilder.build()
                          },
                        );
                      }
                    : null,
                child: Text(i18n.submit.cap.get(context)),
              ),
              if (_failedSubmit && !_isValid)
                Text(
                  i18n.submitError.get(context),
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: kPad),
            ],
          ),
        ),
        if (_submitted)
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black12,
            alignment: Alignment.bottomCenter,
            child: const SizedBox(
              height: 4,
              child: LinearProgressIndicator(),
            ),
          ),
      ],
    );
  }

  bool get _isValid => EmailValidator.validate(_feedbackBuilder.email ?? '');

  // Gross hack to keep the keyboard opening from
  // resetting everything after a programmatic drag.
  void _simulateDrag() {
    (widget.controller.position as ScrollPositionWithSingleContext)
        .applyUserOffset(.1);
  }
}
