import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class StackNavigatorObserver extends NavigatorObserver {
  static List<Route<dynamic>> routeStack = [];

  void didPush(Route<dynamic> route, Route<dynamic> previousRoute) {
    routeStack.add(route);
  }

  void didPop(Route<dynamic> route, Route<dynamic> previousRoute) {
    routeStack.removeLast();
  }

  @override
  void didRemove(Route route, Route previousRoute) {
    routeStack.remove(route);
  }

  @override
  void didReplace({Route newRoute, Route oldRoute}) {
    routeStack.replaceRange(routeStack.indexOf(oldRoute),
        routeStack.indexOf(oldRoute) + 1, [newRoute]);
  }
}
