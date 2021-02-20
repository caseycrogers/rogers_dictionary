import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:rogers_dictionary/pages/dictionary_page.dart';

class FavoritesPage extends StatelessWidget {
  static const route = 'favorites';

  static bool matchesUri(Uri uri) => uri.pathSegments.contains(route);

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.red);
  }
}
