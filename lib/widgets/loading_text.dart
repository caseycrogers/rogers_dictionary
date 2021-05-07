import 'package:flutter/material.dart';
import 'package:rogers_dictionary/util/text_utils.dart';

class LoadingText extends StatelessWidget {
  final String text;
  final bool delay;

  LoadingText({this.text: 'loading', this.delay: false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<String>(
      builder: (context, snap) => Text(
        snap.data ?? '',
        style: normal1(context).copyWith(color: Colors.black45),
      ),
      stream: _infiniteTextStream(),
    );
  }

  Stream<String> _infiniteTextStream() async* {
    var i = 0;
    while (true) {
      // If _delay is true, display an empty text box for the first three tics
      // to reduce visual disruption for short loading times
      var txt = [''];
      if (!delay || i == 3)
        txt = ['.', '..', '...'].map((e) => text + e).toList();

      yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
      await Future<void>.delayed(Duration(milliseconds: 200));
      i++;
    }
  }
}
