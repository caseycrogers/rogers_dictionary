import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/pages/entry_search_page.dart';
import 'package:rogers_dictionary/widgets/top_shadow.dart';

class FavoritesPage extends StatelessWidget {
  static const route = 'favorites';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) => TopShadow(child: EntrySearchPage());
}
