import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
  final String text;
  final bool delay;

  LoadingText({this.text: 'loading', this.delay: false});

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
      if (!delay || i == 3) txt = ['.', '..', '...'].map((e) => text + e).toList();

      yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
      await Future<void>.delayed(Duration(milliseconds: 200));
      i++;
    }
  }
}
