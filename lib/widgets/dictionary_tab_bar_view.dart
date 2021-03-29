import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:rogers_dictionary/models/dictionary_page_model.dart';
import 'package:rogers_dictionary/pages/dictionary_page.dart';

import 'package:rogers_dictionary/util/local_history_value_notifier.dart';

class DictionaryTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const DictionaryTabBarView({
    @required this.children,
  }) : assert(children != null);

  final LinkedHashMap<DictionaryTab, Widget> children;

  @override
  _DictionaryTabBarViewState createState() => _DictionaryTabBarViewState();
}

class _DictionaryTabBarViewState extends State<DictionaryTabBarView> {
  TabController _controller;
  LinkedHashMap<DictionaryTab, Widget> _childrenWithKey;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

  LocalHistoryValueNotifier get currentTab =>
      DictionaryPageModel.readFrom(context).currentTab;

  void _updateTabController() {
    final TabController newController = DefaultTabController.of(context);
    assert(() {
      if (newController == null) {
        throw FlutterError('No TabController for ${widget.runtimeType}.\n'
            'When creating a ${widget.runtimeType}, you must either provide an explicit '
            'TabController using the "controller" property, or you must ensure that there '
            'is a DefaultTabController above the ${widget.runtimeType}.\n'
            'In this case, there was neither an explicit controller nor a default controller.');
      }
      return true;
    }());

    if (newController == _controller) return;

    if (_controllerIsValid) {
      _controller.animation.removeListener(_handleTabControllerAnimationTick);
    }
    _controller = newController;
    if (_controller != null)
      _controller.animation.addListener(_handleTabControllerAnimationTick);
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
    if (widget.children != oldWidget.children) _updateChildren();
  }

  @override
  void didChangeDependencies() {
    var shouldInit = _controller == null;
    super.didChangeDependencies();
    _updateTabController();
    if (shouldInit) {
      currentTab.addListener(_onIndexChanged);
    }
  }

  @override
  void dispose() {
    if (_controllerIsValid)
      _controller.animation.removeListener(_handleTabControllerAnimationTick);
    _controller = null;
    currentTab.removeListener(_onIndexChanged);
    super.dispose();
  }

  void _updateChildren() {
    _childrenWithKey = LinkedHashMap.fromEntries(widget.children.entries.map(
      (entry) => MapEntry(
        entry.key,
        KeyedSubtree(key: ValueKey(entry.key), child: entry.value),
      ),
    ));
  }

  void _handleTabControllerAnimationTick() {
    currentTab.value = widget.children.keys.toList()[_controller.index];
  }

  @override
  Widget build(BuildContext context) {
    assert(() {
      if (_controller.length != widget.children.length) {
        throw FlutterError(
            "Controller's length property (${_controller.length}) does not match the "
            "number of tabs (${widget.children.length}) present in TabBar's tabs property.");
      }
      return true;
    }());
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 200),
      reverseDuration: Duration(milliseconds: 1000),
      transitionBuilder: _getTransition,
      child: _childrenWithKey[currentTab.value],
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Interval(0.0, 0.1),
    );
  }

  _onIndexChanged() {
    DictionaryPageModel.readFrom(context).onTabChanged();
    if (_controller.index != currentTab.value) {
      _controller.animateTo(DictionaryTab.values.indexOf(currentTab.value));
    }
    setState(() {});
  }

  Widget _getTransition(Widget child, Animation<double> animation) =>
      SlideTransition(
        position: Tween(
          begin: Offset(0, -1.0),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      );
}
