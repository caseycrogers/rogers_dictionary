import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';

class DictionaryPage extends StatelessWidget {
  static const String route = '/';

  @override
  Widget build(BuildContext context) {
    return OrientationBuilder(
      builder: (context, orientation) {
        switch (orientation) {
          case Orientation.portrait:
            return Scaffold(
              appBar: AppBar(
                title: Text('Dictionary'),
              ),
              body: EntrySearch(),
            );
          case Orientation.landscape:
            return Scaffold(
              appBar: AppBar(
                title: Text('Dictionary'),
              ),
              body: Row(
                children: [
                  Expanded(flex: 1, child: EntrySearch()),
                  Expanded(flex: 2, child: Container()),
                ],
              ),
            );
          default:
            return Container();
        }
      },
    );
  }
}
