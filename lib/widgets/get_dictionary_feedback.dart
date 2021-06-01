import 'package:feedback/feedback.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryFeedback {
  DictionaryFeedback(this.subject, this.body, this.type);

  final String subject;
  final String body;
  final DictionaryFeedbackType type;
}

class _DictionaryFeedbackBuilder {
  String? subject;
  String? body;
  DictionaryFeedbackType? type;

  DictionaryFeedback build() => DictionaryFeedback(
        subject ?? '',
        body ?? '',
        type!,
      );
}

enum DictionaryFeedbackType {
  translation_error,
  bug_report,
  feature_request,
  other,
}

String typeToString(DictionaryFeedbackType type) =>
    type.toString().split('.').last.replaceAll('_', ' ');

class GetDictionaryFeedback extends StatefulWidget {
  const GetDictionaryFeedback(this.onSubmit, {Key? key}) : super(key: key);

  final OnSubmit onSubmit;

  @override
  _GetDictionaryFeedbackState createState() => _GetDictionaryFeedbackState();
}

class _GetDictionaryFeedbackState extends State<GetDictionaryFeedback> {
  final _feedbackBuilder = _DictionaryFeedbackBuilder();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                Row(
                  children: [
                    const Text('Feedback type: '),
                    DropdownButton<DictionaryFeedbackType>(
                      value: _feedbackBuilder.type,
                      items: DictionaryFeedbackType.values
                          .map(
                            (type) => DropdownMenuItem<DictionaryFeedbackType>(
                              child: Text(typeToString(type)),
                              value: type,
                            ),
                          )
                          .toList(),
                      onChanged: (type) {
                        setState(() => _feedbackBuilder.type = type);
                      },
                    ),
                    const Text(' *'),
                  ],
                ),
                TextField(
                  maxLength: 60,
                  decoration: const InputDecoration(helperText: 'Summary'),
                  onChanged: (value) => _feedbackBuilder.subject = value,
                ),
                TextField(
                  minLines: 2,
                  maxLines: 10,
                  decoration: const InputDecoration(helperText: 'Feedback'),
                  onChanged: (value) => _feedbackBuilder.body = value,
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _feedbackBuilder.type != null
                ? () => widget.onSubmit(
                      '',
                      extras: <String, DictionaryFeedback>{
                        'feedback': _feedbackBuilder.build()
                      },
                    )
                : null,
            child: const Text('submit'),
          ),
          const Text('(opens your email app)'),
        ],
      ),
    );
  }
}
