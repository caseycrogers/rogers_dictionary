import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/main.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';
import 'package:rogers_dictionary/widgets/loading_text.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var name = settings.name;
    if (name == DictionaryPage.route) return _serveDictionaryPage(settings);
    if (name.startsWith(EntryPage.route)) return _serveEntryPage(settings);

    // Route not recognized, display 404 page
    return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
              child: Text('No route defined for ${settings.name}')
          ),
        )
    );
  }
}

MaterialPageRoute _serveDictionaryPage(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => DictionaryPage(),
  );
}

MaterialPageRoute _serveEntryPage(RouteSettings settings) {
  String urlEncodedHeadword = settings.name.substring(EntryPage.route.length + 1, settings.name.length);
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => FutureBuilder(
      future: MyApp.db.getEntry(urlEncodedHeadword),
      builder: (context, snap) {
        if (!snap.hasData) return Center(child: LoadingText());
        return EntryPage.asPage(snap.data);
      },
    ),
  );
}