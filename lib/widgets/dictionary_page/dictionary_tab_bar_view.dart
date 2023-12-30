// Dart imports:
import 'dart:collection';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:implicit_navigator/implicit_navigator.dart';

// Project imports:
import 'package:rogers_dictionary/models/dictionary_model.dart';
import 'package:rogers_dictionary/util/animation_utils.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_tab.dart';

class DictionaryTabBarView extends StatelessWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [_controller]'s length.
  const DictionaryTabBarView({
    required this.children,
  });

  final LinkedHashMap<DictionaryTab, Widget> children;

  ValueNotifier<DictionaryTab> get currentTab =>
      DictionaryModel.instance.currentTab;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ImplicitNavigatorNotification<dynamic>>(
      onNotification: (notification) {
        return false;
      },
      child: ImplicitNavigator.fromValueNotifier<DictionaryTab>(
        key: const PageStorageKey('tab_selector'),
        maintainHistory: true,
        maintainState: false,
        valueNotifier: currentTab,
        builder: (context, tab) {
          // Save a reference earlier so that the listener can reference it.
          return children[tab]!;
        },
        getDepth: (tab) => tab == DictionaryTab.search ? 0 : 1,
        transitionsBuilder: _getTransition,
      ),
    );
  }

  Widget _getTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(animation),
      child: Container(
        // The searchbar's background is transparent to avoid a mis-colored seam
        // from having two objects of the same color adjacent to each other.
        // Because of this, we need to temporarily put a primary color
        // background behind it when it's animating.
        color: animation.isRunning || secondaryAnimation.isRunning
            ? Theme.of(context).colorScheme.primary
            : Colors.transparent,
        child: SlideTransition(
          position: Tween(
            begin: Offset.zero,
            end: const Offset(0, 1),
          ).animate(
            CurvedAnimation(
                parent: secondaryAnimation,
                curve: const InstantOutCurve(atStart: false)),
          ),
          child: child,
        ),
      ),
    );
  }
}
