import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/dictionary/entry_search.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';

class DictionaryPage extends StatelessWidget {
  static bool matchesRoute(Uri uri) =>
      ListEquality().equals(uri.pathSegments, ['dictionary']);

  final Animation<double> animation;

  DictionaryPage({@required this.animation});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => Scaffold(
        appBar: AppBar(
          title: Text('Dictionary'),
        ),
        body: AnimatedBuilder(
            animation: ModalRoute.of(context).animation,
            builder: (context, _) => _buildOrientedPage(context, constraints)),
      ),
    );
  }

  Widget _buildOrientedPage(BuildContext context, BoxConstraints constraints) {
    DictionaryPageModel dictionaryPageModel = DictionaryPageModel.of(context);
    switch (MediaQuery.of(context).orientation) {
      case Orientation.portrait:
        return Stack(
          children: [
            Positioned(
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
            Positioned(
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset.zero,
                        end: dictionaryPageModel.hasSelection
                            ? Offset(-1.0, 0.0)
                            : Offset.zero)
                    .animate(animation),
                child: Container(child: EntrySearch()),
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
                color: Theme.of(context).scaffoldBackgroundColor),
            Positioned(
              left: constraints.maxWidth / 3.0,
              width: 2.0 * constraints.maxWidth / 3.0,
              child: SlideTransition(
                position: Tween<Offset>(
                        begin: Offset(-1.0, 0.0), end: Offset(-0.0, 0.0))
                    .animate(animation),
                child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).shadowColor,
                            spreadRadius: 2.0,
                            blurRadius: 2.0,
                            offset: Offset(0.0, 0.0)),
                      ],
                    ),
                    height: constraints.maxHeight,
                    width: 2.0 * constraints.maxWidth / 3.0,
                    child: EntryPage.asPage()),
              ),
            ),
            Positioned(
              child: SlideTransition(
                position: AlwaysStoppedAnimation(Offset.zero),
                child: Container(
                    width: constraints.maxWidth / 3.0,
                    height: constraints.maxHeight,
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      boxShadow: [
                        BoxShadow(
                            color: Theme.of(context).shadowColor,
                            spreadRadius: 2.0,
                            blurRadius: 2.0,
                            offset: Offset(0.0, 0.0)),
                      ],
                    ),
                    child: EntrySearch()),
              ),
            ),
          ],
        );
      default:
        return Container();
    }
  }
}
