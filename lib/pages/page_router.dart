import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

class PageRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final Uri uri = Uri.parse(settings.name ?? '');
    return _serveDictionaryPage(settings, uri);
  }
}

Route<dynamic> _serveDictionaryPage(RouteSettings settings, Uri uri) =>
    _servePage(settings, uri, DictionaryPage());

Route<dynamic> _servePage(RouteSettings settings, Uri uri, Widget page) {
  return PageRouteBuilder<DictionaryPageModel>(
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (BuildContext context, Animation<double> animation,
        Animation<double> secondaryAnimation) {
      return Provider<DictionaryPageModel>(
        create: (_) => DictionaryPageModel.empty(context),
        builder: (BuildContext context, _) {
          return page;
        },
      );
    },
  );
}
