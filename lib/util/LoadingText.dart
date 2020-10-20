import 'package:flutter/material.dart';

class LoadingText extends StatelessWidget {
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
}

_infiniteTextStream() async* {
  while (true) {
    var txt = ["loading", "loading.", "loading..", "loading..."];
    var now = DateTime.now();

    yield txt[DateTime.now().millisecondsSinceEpoch ~/ 200 % txt.length];
    await Future<void>.delayed(Duration(milliseconds: 200));
  }
}
