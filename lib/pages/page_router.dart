import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
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
    settings: settings.copyWith(arguments: DictionaryPageModel.empty()),
    builder: (context) {
      return DictionaryPage();
    },
  );
}

Route<dynamic> _serveEntryPage(RouteSettings settings) {
  var headword = settings.name.split('/').last;
  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, _) {
      //context
      //    .select<SelectedEntryModel, SelectedEntryModel>((value) => value)
      //    .selectEntry(MyApp.db.getEntry(headword), headword);
      return DictionaryPage(
          transitionAnimation: CurvedAnimation(curve: Curves.easeIn, parent: animation)
      );
    }
  );
}