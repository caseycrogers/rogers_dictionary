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

class DictionaryTabBarView extends StatefulWidget {
  /// Creates a page view with one child per tab.
  ///
  /// The length of [children] must be the same as the [_controller]'s length.
  const DictionaryTabBarView({
    required this.children,
  });

  final LinkedHashMap<DictionaryTab, Widget> children;

  @override
  _DictionaryTabBarViewState createState() => _DictionaryTabBarViewState();
}

class _DictionaryTabBarViewState extends State<DictionaryTabBarView> {
  TabController? _controller;

  ValueNotifier<DictionaryTab> get currentTab =>
      DictionaryModel.instance.currentTab;

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
  void didUpdateWidget(DictionaryTabBarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateTabController();
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

  void _handleTabControllerAnimationTick() {
    if (!mounted) {
      return;
    }
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

    return NotificationListener<ImplicitNavigatorNotification<dynamic>>(
      onNotification: (notification) {
        return false;
      },
      child: ImplicitNavigator.fromValueNotifier<DictionaryTab>(
        key: const PageStorageKey('tab_selector'),
        maintainHistory: true,
        maintainState: false,
        valueNotifier: currentTab,
        builder: (context, tab, animation, secondaryAnimation) {
          // Save a reference earlier so that the listener can reference it.
          return widget.children[tab]!;
        },
        getDepth: (tab) => tab == DictionaryTab.search ? 0 : 1,
        transitionsBuilder: _getTransition,
      ),
    );
  }

  void _onIndexChanged() {
    if (_controller!.index != DictionaryTab.values.indexOf(currentTab.value)) {
      _controller!.animateTo(DictionaryTab.values.indexOf(currentTab.value));
    }
    setState(() {});
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
