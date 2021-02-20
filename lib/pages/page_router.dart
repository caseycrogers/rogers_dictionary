import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    var uri = Uri.parse(settings.name);
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

Route<dynamic> _serveDictionaryPage(RouteSettings settings, Uri uri) =>
    _servePage(settings, uri, DictionaryPage());

Route<dynamic> _servePage(RouteSettings settings, Uri uri, Widget page) {
  return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      settings: settings.copyWith(
          name: settings.name,
          arguments: settings.arguments ?? DictionaryPageModel.empty()),
      pageBuilder: (context, animation, secondaryAnimation) {
        DictionaryPageModel.of(context).createSearchPageModel(context);
        return page;
      });
}
