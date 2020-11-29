import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';

class DictionaryPage extends StatelessWidget {
  static const String route = '/';
  final String _urlEncodedHeadword;

  final Animation<double> transitionAnimation;

  @override
  final key = PageStorageKey('dictionary_page');

  DictionaryPage(this._urlEncodedHeadword,
      {this.transitionAnimation: kAlwaysCompleteAnimation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        appBar: AppBar(
          title: Text('Dictionary'),
        ),
        body: AnimatedBuilder(
          animation: transitionAnimation,
          child: EntrySearch(),
          builder: (context, child) => _buildOrientedPage(context, constraints, child)
        ),
      ),
    );
  }

  Widget _buildOrientedPage(BuildContext context, BoxConstraints constraints, Widget prebuiltEntrySearch) {
    switch (MediaQuery.of(context).orientation) {
      case Orientation.portrait:
        return Stack(
          children: [
            Container(width: constraints.maxWidth, height: constraints.maxHeight),
            Positioned(
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: _urlEncodedHeadword.isEmpty ? Offset(1.0, 0.0) : Offset(0.0, 0.0)
                ).animate(transitionAnimation),
                child: EntryPage.asPage(_urlEncodedHeadword)
              ),
            ),
            Positioned(
              child: SlideTransition(
                  position: Tween<Offset>(
                      begin: Offset(0.0, 0.0),
                      end: _urlEncodedHeadword.isEmpty ? Offset(0.0, 0.0) : Offset(-1.0, 0.0)
                  ).animate(transitionAnimation),
                  child: prebuiltEntrySearch,
              ),
            ),
          ],
        );
      case Orientation.landscape:
        return Stack(
          children: [
            Container(width: constraints.maxWidth, height: constraints.maxHeight),
            Positioned(
              left: constraints.maxWidth / 3.0,
              width: 2.0*constraints.maxWidth / 3.0,
              child: SlideTransition(
                position: Tween<Offset>(begin: Offset(-1.0, 0.0), end: Offset(0.0, 0.0)).animate(transitionAnimation),
                child: EntryPage.asPage(_urlEncodedHeadword)
              ),
            ),
            Positioned(
              width: constraints.maxWidth / 3.0,
              height: constraints.maxHeight,
              child: prebuiltEntrySearch,
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
