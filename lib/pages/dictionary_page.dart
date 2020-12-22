import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';

class DictionaryPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['dictionary']);

  DictionaryPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Dictionary'),
      ),
      body: _buildOrientedPage(context, EntrySearch()),
    );
  }

  Widget _buildOrientedPage(BuildContext context, EntrySearch entrySearch) {
    final animation = ModalRoute.of(context).animation;
    final exitAnimation = ModalRoute.of(context).secondaryAnimation;
    final dictionaryPageModel = DictionaryPageModel.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        switch (MediaQuery.of(context).orientation) {
          case Orientation.portrait:
            return Stack(
              children: [
                Container(
                  color: Colors.transparent,
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
                Positioned(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(1.0, 0.0),
                            end: dictionaryPageModel.hasSelection
                                ? Offset(0.0, 0.0)
                                : Offset(1.0, 0.0))
                        .animate(animation),
                    child: EntryPage.asPage(),
                  ),
                ),
                if (!dictionaryPageModel.hasSelection)
                  Positioned(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: SlideTransition(
                      position: Tween<Offset>(
                              begin: Offset(0.0, 0.0), end: Offset(-1.0, 0.0))
                          .animate(exitAnimation),
                      // Need to keep entry search in the same position in the widget tree
                      // to maintain state across screen rotation
                      child: DecoratedBox(
                        child: Row(
                          children: [
                            Expanded(child: entrySearch),
                          ],
                        ),
                        decoration: BoxDecoration(),
                      ),
                    ),
                  ),
              ],
            );
          case Orientation.landscape:
            return Stack(
              children: [
                Container(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    color: Colors.transparent),
                Positioned(
                  left: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  width: 2.0 * constraints.maxWidth / 3.0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                            begin: Offset(-1.0, 0.0), end: Offset(-0.0, 0.0))
                        .animate(animation),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: EntryPage.asPage()),
                  ),
                ),
                Positioned(
                  width: constraints.maxWidth / 3.0,
                  height: constraints.maxHeight,
                  child: SlideTransition(
                    position: AlwaysStoppedAnimation(Offset.zero),
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                        ),
                        child: Row(
                          children: [
                            Expanded(child: entrySearch),
                            VerticalDivider(width: 0.0),
                          ],
                        )),
                  ),
                ),
              ],
            );
          default:
            return Container();
        }
      },
    );
  }
}
