import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/pages/entry_search_page.dart';

class SearchPage extends StatelessWidget {
  static const String route = 'search';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return EntrySearchPage();
  }
}
