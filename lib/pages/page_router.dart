import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/widgets/entry_page.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var name = settings.name;
    if (name == DictionaryPage.route) return _serveDictionaryPage(settings);
    if (name.startsWith(EntryPage.route)) return _serveEntryPage(settings);

    // Route not recognized, display 404 page
    return MaterialPageRoute(
      settings: settings,
      builder: (_) => Scaffold(
        body: Center(
            child: Text('No route defined for ${settings.name}')
        ),
      )
    );
  }
}

Route<dynamic> _serveDictionaryPage(RouteSettings settings) {
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => DictionaryPage(''),
  );
}

Route<dynamic> _serveEntryPage(RouteSettings settings) {
  String urlEncodedHeadword = settings.name.substring(EntryPage.route.length + 1, settings.name.length);
  return MaterialPageRoute(
    settings: settings,
    builder: (_) => DictionaryPage(urlEncodedHeadword),
  );
}