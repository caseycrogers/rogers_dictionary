import 'package:flutter/material.dart';

import 'package:rogers_dictionary/i18n.dart' as i18n;
import 'package:rogers_dictionary/util/text_utils.dart';
import 'package:rogers_dictionary/widgets/on_error_stream_builder.dart';

class LoadingText extends StatelessWidget {
  const LoadingText({this.delay = false});

  final bool delay;

  @override
  Widget build(BuildContext context) {
    final String text = i18n.loading.get(context);
    return LoggingStreamBuilder<String>(
      builder: (context, snap) => Text(
        snap.data ?? '',
        style: normal1(context).copyWith(color: Colors.black45),
      ),
      stream: _infiniteTextStream(text),
    );
  }

  Stream<String> _infiniteTextStream(String text) async* {
    var i = 0;
    while (true) {
      // If _delay is true, display an empty text box for the first three tics
      // to reduce visual disruption for short loading times
      var txt = [''];
      if (!delay || i == 3)
        txt = ['.', '..', '...']
            .map((e) => text + e)
            .toList();

      yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
      await Future<void>.delayed(const Duration(milliseconds: 200));
      i++;
    }
  }
}
