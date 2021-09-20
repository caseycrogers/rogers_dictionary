import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:implicit_navigator/implicit_navigator.dart';
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
      DictionaryModel.of(context).currentTab;

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
    return ImplicitNavigator<DictionaryTab>.fromNotifier(
      key: const PageStorageKey('tab_selector'),
      valueNotifier: currentTab,
      builder: (context, tab, _, __) {
        void updateBackButton() {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            DictionaryModel.of(context).displayBackButton.value =
                ImplicitNavigator.of<dynamic>(context, root: true).canPop;
          });
        }

        updateBackButton();
        return NotificationListener(
          onNotification: (notification) {
            updateBackButton();
            return false;
          },
          child: widget.children[tab]!,
        );
      },
      getDepth: (tab) => tab == DictionaryTab.search ? 0 : 1,
      transitionsBuilder: _getTransition,
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
    );
  }
}
