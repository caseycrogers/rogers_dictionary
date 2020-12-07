import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';
import 'package:rogers_dictionary/util/platform_utils.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name);
    print(uri.pathSegments);
    if (DictionaryPage.matchesRoute(uri) || uri.pathSegments.isEmpty)
      return _serveDictionaryPage(settings, uri);

    // Route not recognized, display 404 page
    return MaterialPageRoute(
        settings: settings,
        builder: (_) => Scaffold(
              body:
                  Center(child: Text('No route defined for ${settings.name}')),
            ));
  }
}

Route<dynamic> _serveDictionaryPage(RouteSettings settings, Uri uri) {
  if (uri.queryParameters
      .containsKey(DictionaryPage.selectedEntryQueryParameter)) {
    var newSettings = settings.copyWith(
        arguments: settings.arguments ??
            DictionaryPageModel.fromHeadword(uri
                .queryParameters[DictionaryPage.selectedEntryQueryParameter]));
    return PageRouteBuilder(
        settings: newSettings,
        pageBuilder: (context, animation, _) {
          //context
          //    .select<SelectedEntryModel, SelectedEntryModel>((value) => value)
          //    .selectEntry(MyApp.db.getEntry(headword), headword);
          return DictionaryPage(
            transitionAnimation: isMobile(context)
                ? CurvedAnimation(curve: Curves.easeIn, parent: animation)
                : AlwaysStoppedAnimation(1.0),
          );
        });
  }
  return MaterialPageRoute(
    settings: settings.copyWith(arguments: DictionaryPageModel.empty()),
    builder: (context) {
      return DictionaryPage();
    },
  );
}
