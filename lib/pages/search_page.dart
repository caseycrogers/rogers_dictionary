// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/util/focus_utils.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_layout.dart';

class SearchPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const _UnFocusOnDrag(
      child: SearchPageLayout(key: PageStorageKey('search')),
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
