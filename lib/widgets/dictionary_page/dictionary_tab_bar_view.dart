import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

import 'package:rogers_dictionary/dictionary_navigator/local_history_value_notifier.dart';

class DictionaryTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const DictionaryTabBarView({
    required this.children,
  });

  final LinkedHashMap<DictionaryTab, Widget> children;

  @override
  _DictionaryTabBarViewState createState() => _DictionaryTabBarViewState();
}

class _DictionaryTabBarViewState extends State<DictionaryTabBarView> {
  TabController? _controller;
  late LinkedHashMap<DictionaryTab, Widget> _childrenWithKey;

  LocalHistoryValueNotifier<DictionaryTab> get currentTab =>
      DictionaryPageModel.readFrom(context).currentTab;

  void _updateTabController() {
    final TabController newController = DefaultTabController.of(context)!;

    if (newController == _controller) {
      return;
    }

    _controller?.animation?.removeListener(_handleTabControllerAnimationTick);
    _controller = newController;
    _controller?.animation?.addListener(_handleTabControllerAnimationTick);
  }

  @override
  void initState() {
    super.initState();
    _updateChildren();
  }

  @override
  void didUpdateWidget(DictionaryTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabController();
    if (widget.children != oldWidget.children) {
      _updateChildren();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final bool shouldInit = _controller == null;
    _updateTabController();
    if (shouldInit) {
      currentTab.addListener(_onIndexChanged);
    }
  }

  @override
  void dispose() {
    _controller?.animation?.removeListener(_handleTabControllerAnimationTick);
    currentTab.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _updateChildren() {
    _childrenWithKey = LinkedHashMap<DictionaryTab, Widget>.fromEntries(
        widget.children.entries.map(
      (MapEntry<DictionaryTab, Widget> entry) => MapEntry(
        entry.key,
        KeyedSubtree(
          key: ValueKey<DictionaryTab>(entry.key),
          child: entry.value,
        ),
      ),
    ));
  }

  void _handleTabControllerAnimationTick() {
    currentTab.value = widget.children.keys.toList()[_controller!.index];
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller!.length != widget.children.length) {
        throw FlutterError(
            'Controller\'s length property (${_controller!.length}) does not '
            'match the number of tabs (${widget.children.length}) present in '
            'TabBar\'s tabs property.');
      }
      return true;
    }());
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      reverseDuration: const Duration(milliseconds: 1000),
      transitionBuilder: _getTransition,
      child: _childrenWithKey[currentTab.value],
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: const Interval(0, 0.1),
    );
  }

  void _onIndexChanged() {
    if (_controller!.index != DictionaryTab.values.indexOf(currentTab.value)) {
      _controller!.animateTo(DictionaryTab.values.indexOf(currentTab.value));
    }
    setState(() {});
  }

  Widget _getTransition(Widget child, Animation<double> animation) =>
      SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}
