import 'package:flutter/material.dart';

_LoadingText LoadingText({
  String text: 'loading',
  bool delay: false,
}) => _LoadingText(text, delay);

class _LoadingText extends StatelessWidget {
  final String _text;
  final bool _delay;

  _LoadingText(this._text, this._delay);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      builder: (context, snap) => Text(
        snap.data ?? '',
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.black45,
        ),
      ),
      stream: _infiniteTextStream(),
    );
  }

  _infiniteTextStream() async* {
    var i = 0;
    while (true) {
      // If _delay is true, display an empty text box for the first three tics
      // to reduce visual disruption for short loading times
      var txt = [''];
      if (!_delay || i == 3) txt = ['.', '..', '...'].map((e) => _text + e).toList();

      yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
      await Future<void>.delayed(Duration(milliseconds: 200));
      i++;
    }
  }
}
