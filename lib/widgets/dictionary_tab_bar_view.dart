import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:rogers_dictionary/util/local_history_value_notifier.dart';

class DictionaryTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [controller]'s length.
  const DictionaryTabBarView({
    @required this.children,
  }) : assert(children != null);

  final List<Widget> children;

  @override
  _DictionaryTabBarViewState createState() => _DictionaryTabBarViewState();
}

class _DictionaryTabBarViewState extends State<DictionaryTabBarView> {
  TabController _controller;
  List<Widget> _childrenWithKey;
  LocalHistoryValueNotifier<int> _currentIndex;

  // If the TabBarView is rebuilt with a new tab controller, the caller should
  // dispose the old one. In that case the old controller's animation will be
  // null and should not be accessed.
  bool get _controllerIsValid => _controller?.animation != null;

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateTabController();
    if (_currentIndex == null) {
      _currentIndex = LocalHistoryValueNotifier(
        context: context,
        initialValue: _controller?.index,
      );
      _currentIndex.addListener(() {
        if (_controller.index != _currentIndex.value)
          _controller.animateTo(_currentIndex.value);
        setState(() {});
      });
    }
    _currentIndex.value = _controller.index;
  }

  @override
  void didUpdateWidget(DictionaryTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.children != oldWidget.children) _updateChildren();
  }

  @override
  void dispose() {
    if (_controllerIsValid)
      _controller.animation.removeListener(_handleTabControllerAnimationTick);
    _controller = null;
    // We don't own the _controller Animation, so it's not disposed here.
    super.dispose();
  }

  void _updateChildren() {
    _childrenWithKey = KeyedSubtree.ensureUniqueKeysForList(widget.children);
  }

  void _handleTabControllerAnimationTick() {
    _currentIndex.value = _controller.index;
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
      child: _childrenWithKey[_currentIndex.value],
    );
  }
}
