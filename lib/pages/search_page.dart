import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/util/focus_utils.dart';

import 'package:rogers_dictionary/widgets/search_page/search_page_layout.dart';

class SearchPage extends StatelessWidget {
  static const String route = 'search';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return const _UnFocusOnDrag(
      child: SearchPageLayout(key: PageStorageKey('bookmarks')),
    );
  }
}

class _UnFocusOnDrag extends StatelessWidget {
  const _UnFocusOnDrag({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollUpdateNotification>(
      child: child,
      onNotification: (ScrollUpdateNotification notification) {
        if (notification.dragDetails != null) {
          unFocus();
        }
        return false;
      },
    );
  }
}
