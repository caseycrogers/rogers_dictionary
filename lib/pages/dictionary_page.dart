import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';

class DictionaryPage extends StatelessWidget {
  static const String route = '/';

  final Animation<double> transitionAnimation;

  @override
  final key = PageStorageKey('dictionary_page');

  DictionaryPage({this.transitionAnimation: kAlwaysCompleteAnimation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        appBar: AppBar(
          title: Text('Dictionary'),
        ),
        body: AnimatedBuilder(
          animation: transitionAnimation,
          builder: (context, _) => _buildOrientedPage(context, constraints)
        ),
      ),
    );
  }

  Widget _buildOrientedPage(
      BuildContext context,
      BoxConstraints constraints) {
    DictionaryPageModel dictionaryPageModel = DictionaryPageModel.of(context);
    switch (MediaQuery.of(context).orientation) {
      case Orientation.portrait:
        return Stack(
          children: [
            Container(width: constraints.maxWidth, height: constraints.maxHeight),
            Positioned(
              child: SlideTransition(
                position: Tween<Offset>(
                    begin: Offset(1.0, 0.0),
                    end: dictionaryPageModel.hasSelection ? Offset(0.0, 0.0) : Offset(1.0, 0.0)
                ).animate(transitionAnimation),
                child: EntryPage.asPage(),
              ),
            ),
            Positioned(
              child: SlideTransition(
                  position: Tween<Offset>(
                      begin: Offset(0.0, 0.0),
                      end: dictionaryPageModel.hasSelection ? Offset(-1.0, 0.0) : Offset(0.0, 0.0)
                  ).animate(transitionAnimation),
                  child: EntrySearch(),
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
                child: EntryPage.asPage(),
              ),
            ),
            Positioned(
              width: constraints.maxWidth / 3.0,
              height: constraints.maxHeight,
              child: EntrySearch(),
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
