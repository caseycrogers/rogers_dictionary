import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

class DictionaryPage extends StatelessWidget {
  static const String route = '/';
  final String _urlEncodedHeadword;

  DictionaryPage(this._urlEncodedHeadword);

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
              body: _urlEncodedHeadword != '' ? EntryPage.asPage(_urlEncodedHeadword) : EntrySearch(),
            );
          case Orientation.landscape:
            return Scaffold(
              appBar: AppBar(
                title: Text('Dictionary'),
              ),
              body: Row(
                children: [
                  Expanded(flex: 1, child: EntrySearch()),
                  Expanded(flex: 2, child: _urlEncodedHeadword != '' ? EntryPage.asPage(_urlEncodedHeadword) : Container()),
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
