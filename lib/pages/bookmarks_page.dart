// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Project imports:
import 'package:rogers_dictionary/widgets/adaptive_material.dart';
import 'package:rogers_dictionary/widgets/search_page/search_page_layout.dart';

class BookmarksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const AdaptiveMaterial(
      adaptiveColor: AdaptiveColor.surface,
      child: SearchPageLayout(key: PageStorageKey('bookmarks')),
    );
  }
}
