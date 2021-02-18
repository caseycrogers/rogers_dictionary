import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DictionaryTabBar extends StatelessWidget {
  final List<DictionaryTab> primaryTabs;
  final List<DictionaryTab> secondaryTabs;
  final Color primaryColor;
  final Color secondaryColor;

  DictionaryTabBar({
    @required this.primaryTabs,
    @required this.secondaryTabs,
    @required this.primaryColor,
    @required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(),
      child: Row(
        children: [
          Expanded(
            child: Material(
              color: primaryColor,
              elevation: 0.0,
              child: Row(
                children: primaryTabs.map(_buildTab).toList(),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
              ),
            ),
          ),
          Material(
            color: primaryColor,
            elevation: 0.0,
            child: Row(
              children: secondaryTabs.map(_buildTab).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(DictionaryTab tab) => Container(
        constraints: BoxConstraints.expand(),
        child: DefaultTextStyle(
          child: tab.child,
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      );
}

class DictionaryTab {
  final Widget child;

  DictionaryTab({@required this.child});
}
