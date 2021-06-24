import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rogers_dictionary/widgets/dictionary_page/dictionary_top_bar.dart';

class DictionaryTopBarDelegate extends SliverPersistentHeaderDelegate {
  const DictionaryTopBarDelegate();

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        Positioned(
          top: -shrinkOffset,
          width: MediaQuery.of(context).size.width,
          child: const DictionaryTopBar(),
        ),
      ],
    );
  }

  @override
  double get maxExtent => kToolbarHeight;

  @override
  double get minExtent => 0;

  @override
  bool shouldRebuild(covariant DictionaryTopBarDelegate oldDelegate) {
    return false;
  }
}
