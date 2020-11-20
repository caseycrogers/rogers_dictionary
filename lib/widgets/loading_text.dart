import 'package:flutter/material.dart';

_LoadingText LoadingText({String text: 'loading'}) => _LoadingText(text);

class _LoadingText extends StatelessWidget {
  final String _text;

  _LoadingText(this._text);

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
    while (true) {
      var txt = ['.', '..', '...'].map((e) => _text + e).toList();

      yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
      await Future<void>.delayed(Duration(milliseconds: 200));
    }
  }
}
