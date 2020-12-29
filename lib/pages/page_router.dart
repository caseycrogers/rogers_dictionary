import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name);
    if (DictionaryPage.matchesRoute(uri) || uri.pathSegments.isEmpty)
      return _serveDictionaryPage(settings, uri);

    // Route not recognized, display 404 page
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, _) => Scaffold(
        body: Center(child: Text('No route defined for ${settings.name}')),
      ),
    );
  }
}

Route<dynamic> _serveDictionaryPage(RouteSettings settings, Uri uri) {
  //var newArguments = DictionaryPageModel.fromQueryParams(uri.queryParameters);
  return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 200),
      settings: settings.copyWith(
          name: settings.name,
          arguments: settings.arguments ??
              DictionaryPageModel.empty(
                  translationMode: DEFAULT_TRANSLATION_MODE)),
      pageBuilder: (context, animation, secondaryAnimation) {
        return DictionaryPage();
      });
}
